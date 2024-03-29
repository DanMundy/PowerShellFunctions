### DanMundyPSFunctions: Filesystem
### Filename: DM-Filesystem.ps1
### Version: 20220616T1729
# List of functions included in this file:
#     Get-DMUsersWithHomeDrive
#     Get-DMSmbSharePaths
#     Get-DMDirectoryUsage
#     Get-DMFilesOlderThan and Get-DMFilesModifiedWithin

## ----------------------------------------------------------------------------

# Function: Get-DMUsersWithHomeDrive
# Purpose:  For list of folders, get the folder size, and number of items:
# Usage:    Get-DMFolderSizeAndItems -inFile ListOfFoldersToScan.txt -outFile "C:\DM\Results.csv"

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

# Function: touch
# Purpose:  Windows version of the Linux "touch" utility
#           (note touch may actually function differently, not 100% sure,
#           so take this with a grain of salt and verify that it does what you need)
# Usage:    touch filename.txt (or full path, or touch -file "C:\Path To\filename.txt")
# Note:     I'd usually call it DM-Something but since touch doesn't exist in Windows or PowerShell,
#           thought it made more sense in this case
function touch ($file){
    (Get-Item "$file").CreationTime=$(Get-Date -format o)
    (Get-Item "$file").LastWriteTime=$(Get-Date -format o)
    (Get-Item "$file").LastAccessTime=$(Get-Date -format o)
}