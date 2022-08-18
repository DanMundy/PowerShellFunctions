### DanMundyPSFunctions: Filesystem
### Version: 20220616T1729
# List of functions included in this file:
#     Get-DMUsersWithHomeDrive
#     Get-DMSmbSharePaths
#     Get-DM-DirectoryUsage
#     Get-DMFilesOlderThan and Get-DMFilesModifiedWithin

## ----------------------------------------------------------------------------

# Function: Get-DMUsersWithHomeDrive
# Purpose:  For list of folders, get the folder size, and number of items:
# Usage:    Get-DM-FolderSizeAndItems -inFile ListOfFoldersToScan.txt -outFile "C:\DM\Results.csv"

Function Get-DM-FolderSizeAndItems {
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

## Function: Get-DMSmbSharePaths
## Purpose:  Exports CSV of all fileshares and their path
##           Does a better job than just "net share" as you can just open it in Excel
##           Created this for Windows Server 2008 R2 where Get-SmbShare isn't available
## Usage:
##           # Basic, display only:
##           Get-DMSmbSharePaths
##           # Export to CSV:
##           Get-DMSmbSharePaths -OutFile "C:\DM\Results.csv"
##           # Remote computer:
##           Get-DMSmbSharePaths -ComputerName SERVER1
##           # Multiple servers:
##           Get-DMSmbSharePaths -ComputerName ("SERVER1","SERVER2") -OutFile "C:\DM\Results.csv"

# Version 1.1

Function Get-DMSmbSharePaths {
    
    param (
        $ComputerName,
        $OutFile,
        [Switch] $AppendFile
    )

    $WMIParams = @{}

    If ($ComputerName) { $WMIParams.Add('ComputerName',$ComputerName)}

    If ($AppendFile -eq $True) { $AppendIfTrue = "1"
    } Else { $AppendIfTrue = "0" }

    $Shares = Get-WmiObject -class win32_share @WMIParams

    If ($OutFile -ne $Null) {
        $Shares | Select __Server,Name,Path,Description | Export-Csv -NoTypeInformation -Delimiter ',' -Path $OutFile -Append $AppendIfTrue
    } Else {
        $Shares | Select __Server,Name,Path,Description
    }
}

## ----------------------------------------------------------------------------

# Function: Get-DM-DirectoryUsage
# Purpose: Show size of subdirectories, 1 level deep
#          (like Linux's 'du --max-depth=1')
# Usage: Get-DM-DirectoryUsage C:\ClusterStorage\CSV01
#        Get-DM-DirectoryUsage C:\ClusterStorage\CSV01\Servers
Function Get-DM-DirectoryUsage ($startFolder) {
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