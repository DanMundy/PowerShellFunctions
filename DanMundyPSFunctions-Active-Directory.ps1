### DanMundyPSFunctions: Active Directory
### Version: 20220614T1650

# Function: Get-DMUsersWithHomeDrive
# Purpose:  List all users with a home drive, output to CSV
# Usage:    Get-DMUsersWithHomeDrive -outFile "C:\DM\Results.csv"

function Get-DMUsersWithHomeDrive ($outFile) {
    Import-Module ActiveDirectory
    Get-ADUser -Filter 'HomeDrive -ne "$Null"' `
    -Property Name,CanonicalName,CN,DisplayName,DistinguishedName,HomeDirectory,HomeDrive,SamAccountName,UserPrincipalName `
    | export-csv -path $outFile -encoding ascii -NoTypeInformation
}