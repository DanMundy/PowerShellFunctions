### DanMundyPSFunctions: SharePoint
### Filename: DM-SharePointMigrationPreChecks.md
### Version: 20220623T1133

Function Get-DMFolderSizeAndItems {
    [CmdletBinding()]
    param(
        [parameter(Position=0,Mandatory=$true)]
        $InFile,
        $OutFile
    )
    $FoldersToScan = Get-Content -Path $InFile
    $result = foreach ($Folder in $FoldersToScan) {
        dir $Folder -Recurse | Measure-Object length -Sum | % {
            New-Object psobject -prop @{
                Name = $Folder
                Size = $_.sum
                Items = (Get-ChildItem -Path $Folder -Recurse | Measure-Object).Count
            }
        }
    }
    $result | Export-CSV -NoTypeInformation -Path $OutFile
}

## ----------------------------------------------------------------------------

Function Get-DMSmbSharePaths {
    
    param (
        $ComputerName,
        $OutFile
    )

    $WMIParams = @{}

    If ($ComputerName) { $WMIParams.Add('ComputerName',$ComputerName)}

    $Shares = Get-WmiObject -class win32_share @WMIParams

    If ($OutFile -ne $Null) {
        $Shares | Select __Server,Name,Path,Description | Export-Csv -NoTypeInformation -Path "$OutFile" -Append
    } Else {
        $Shares | Select __Server,Name,Path,Description
    }
}

## ----------------------------------------------------------------------------

# Function: Get-DMDirectoryUsage
# Purpose: Show size of subdirectories, 1 level deep
#          (like Linux's 'du --max-depth=1')
# Usage: Get-DMDirectoryUsage C:\ClusterStorage\CSV01
#        Get-DMDirectoryUsage C:\ClusterStorage\CSV01\Servers
Function Get-DMDirectoryUsage ($startFolder) {
    $colItems = Get-ChildItem $startFolder | Where-Object {$_.PSIsContainer -eq $true} | Sort-Object
    foreach ($i in $colItems)
    {
        $subFolderItems = Get-ChildItem $i.FullName -recurse -force | Where-Object {$_.PSIsContainer -eq $false} | Measure-Object -property Length -sum | Select-Object Sum
        $i.FullName + " -- " + "{0:N2}" -f ($subFolderItems.sum / 1MB) + " MB"
    }
}

## ----------------------------------------------------------------------------

# Function: Get-DMFilesOlderThan and Get-DMFilesModifiedWithin
#           (so similar, may as well be considered as one. Usage examples apply to both)
# Usage:    Get-DMFilesModifiedWithin -folder "C:\Folder1" -Days 30
#           Get-DMFilesModifiedWithin -folder ("C:\Folder1","C:\Folder2") -Days 30
Function Get-DMFilesOlderThan ($Folder,$Days) {
    $xDaysAgo = (Get-Date).AddDays(-$Days)
    Get-ChildItem $Folder | Where-Object {$_.LastWriteTime -lt $xDaysAgo} | % { Write-Host $_.FullName }
}

Function Get-DMFilesModifiedWithin ($Folder,$Days) {
    $xDaysAgo = (Get-Date).AddDays(-$Days)
    #todo - I think it probably should be X days minus another 1, will probably add that, but needs testing
    Get-ChildItem $Folder | Where-Object {$_.LastWriteTime -gt $xDaysAgo} | % { Write-Host $_.FullName }
}

## ----------------------------------------------------------------------------



## ----------------------------------------------------------------------------

Function Get-DMFolderItem {
    [cmdletbinding(DefaultParameterSetName='Filter')]
    Param (
        [parameter(Position=0,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
        [Alias('FullName')]
        [string[]]$Path = $PWD,
        [parameter(ParameterSetName='Filter')]
        [string[]]$Filter = '*.*',    
        [parameter(ParameterSetName='Exclude')]
        [string[]]$ExcludeFile,              
        [parameter()]
        [int]$MaxAge,
        [parameter()]
        [int]$MinAge
        )
    Begin {
        $params = New-Object System.Collections.Arraylist
        $params.AddRange(@("/L","/S","/NJH","/BYTES","/FP","/NC","/NDL","/TS","/XJ","/R:0","/W:0"))
        If ($PSBoundParameters['MaxAge']) {
            $params.Add("/MaxAge:$MaxAge") | Out-Null
        }
        If ($PSBoundParameters['MinAge']) {
            $params.Add("/MinAge:$MinAge") | Out-Null
        }
    }
    Process {
        ForEach ($item in $Path) {
            Try {
                $item = (Resolve-Path -LiteralPath $item -ErrorAction Stop).ProviderPath
                If (-Not (Test-Path -LiteralPath $item -Type Container -ErrorAction Stop)) {
                    Write-Warning ("{0} is not a directory and will be skipped" -f $item)
                    Return
                }
                If ($PSBoundParameters['ExcludeFile']) {
                    $Script = "robocopy `"$item`" NULL $Filter $params /XF $($ExcludeFile  -join ',')"
                } Else {
                    $Script = "robocopy `"$item`" NULL $Filter $params"
                }
                Write-Verbose ("Scanning {0}" -f $item)
                Invoke-Expression $Script | ForEach {
                    Try {
                        If ($_.Trim() -match "^(?<Size>\d+)\s(?<Date>\S+\s\S+)\s+(?<FullName>.*)") {
                            $object = New-Object PSObject -Property @{
                                ParentFolder = $matches.fullname -replace '(.*\\).*','$1'
                                FullName = $matches.FullName
                                Name = $matches.fullname -replace '.*\\(.*)','$1'
                                Length = [int64]$matches.Size
                                LastWriteTime = [datetime]$matches.Date
                                Extension = $matches.fullname -replace '.*\.(.*)','$1'
                                FullPathLength = [int] $matches.FullName.Length
                        }
                        $object.pstypenames.insert(0,'System.IO.RobocopyDirectoryInfo')
                        Write-Output $object
                        } Else {
                            Write-Verbose ("Not matched: {0}" -f $_)
                        }
                        } Catch {
                            Write-Warning ("{0}" -f $_.Exception.Message)
                            Return
                        }
                }
            } Catch {
                Write-Warning ("{0}" -f $_.Exception.Message)
                Return
            }
        }
    }
}

## ----------------------------------------------------------------------------


function Get-DMFileAccessDenied ($Path, $OutFile) {
    $errors=@()
    get-childitem -recurse $Path -ea silentlycontinue -ErrorVariable +errors | Out-Null
    $errors.Count
    $errors | select -expand categoryinfo | select reason,targetname | export-csv -NoTypeInformation -Delimiter ";" $OutFile
}
# Usage: Get-DMFileAccessDenied -Path "D:\test" -OutFile "C:\Users\c1admin\results.csv"

## ----------------------------------------------------------------------------

function Get-DMFilePathLengthOver256Characters ($Path) {
    cmd /c dir /A /s /b $Path |? {$_.length -gt 255} | Out-File $($WorkingDir + "\File-Path-Length-Over-256-Characters.txt")
}

## ----------------------------------------------------------------------------

function Get-DMUnsupportedFileExtensions ($Path) {
    # Run this manually: $Path="D:\Shares\Global\Test\"
    Get-DMFolderItem -Path $Path | where {$_.extension -in "pst","myo","mdb","one"} | Select-Object -Property FullName | Format-Table -AutoSize | Out-File $($WorkingDir + "\Unsupported-File-Extensions.txt") -Width 600
}

function Get-DMADUsersWithLogonScriptOrHomeDrive ($outFile) {
    Import-Module ActiveDirectory
    Get-ADUser -Filter 'HomeDrive -ne "$Null" -or ScriptPath -ne "$Null"' `
    -Property Name,CanonicalName,CN,DisplayName,DistinguishedName,HomeDirectory,HomeDrive,ScriptPath,SamAccountName,UserPrincipalName `
    | export-csv -path $outFile -encoding ascii -NoTypeInformation
}

## ----------------------------------------------------------------------------

function Scan-DMTarget ($Name, $Path, $ReportsDir) {
    $Timestamp = (Get-Date -Format yyyymmdd-hhmm)
    $WorkingDir = $($ReportsDir + "\" + $Name + "-" + $Timestamp)
    New-Item -ItemType Directory -Path $WorkingDir -Force
    # Include trailing slash in the $Path, eg D:\Company\  
    Get-DMFileAccessDenied $Path
    Get-DMFilePathLengthOver256Characters $Path
    Get-DMUnsupportedFileExtensions $Path
    $FoldersToScan = $($WorkingDir + "\ListOfFoldersToScan.txt")
    $Path | Out-String | Out-File $FoldersToScan
    Get-DMFolderSizeAndItems -inFile $FoldersToScan -outFile $($WorkingDir + "\Folder-Size-And-Items.csv")
}

## ----------------------------------------------------------------------------