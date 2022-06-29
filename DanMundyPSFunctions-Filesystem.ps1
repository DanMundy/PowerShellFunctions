### DanMundyPSFunctions: Filesystem
### Version: 20220616T1729

# Function: Get-DMUsersWithHomeDrive
# Purpose:  For list of folders, get the folder size, and number of items:
# Usage:    Get-DM-FolderSizeAndItems -inFile ListOfFoldersToScan.txt -outFile "C:\DM\Results.csv"

function Get-DM-FolderSizeAndItems ($inFile, $OutFile) {
    $foldersToScan = Get-Content -Path $InFile
    $result = foreach ($folder in $foldersToScan) {
        dir $folder -Recurse | Measure-Object length -Sum | % {
    New-Object psobject -prop @{
        Name = $folder
        Size = $_.sum
        Items = (Get-ChildItem -Path $folder -Recurse | Measure-Object).Count
    }
        }
    }
    $result | Export-CSV -NoTypeInformation -Path $OutFile
}

## Function: Get-DMSmbSharePaths
## Purpose:  Exports CSV of all fileshares and their path
##           Does a better job than just "net share" as you can just open it in Excel
##           Created this for Windows Server 2008 R2 where Get-SmbShare isn't available
## Usage:    Get-DMSmbSharePaths -ServerName "SERVER01" -OutFile "C:\DM\Results.csv"

function Get-DMSmbSharePaths ($ServerName,$OutFile) {
    $Shares = gwmi -class win32_share
    #$Shares | ForEach-Object {
    #    ("\\"+$ServerName + "\" + $_.Name +"," +$_.Path)
    #}
    $Shares | Select __Server,Name,Path | Export-Csv -NoTypeInformation -Path $OutFile
    #$Shares | Export-Csv -Path $OutFile
}
Get-DMSmbSharePaths -ServerName "MULLINS-FILES01" -OutFile C:\C1\mullins-shares-files01.csv