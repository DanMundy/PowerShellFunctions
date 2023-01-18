# Migration usage

## Figure out the data paths you need to scan

- [ ] Check group policy for drive mappings
- [ ] Check any logon scripts assigned by group policy
- [ ] Check AD users for any account with per-user logon script or home drive

```powershell
Get-DMADUsersWithLogonScriptOrHomeDrive -outFile "C:\DM\Users-With-Home-Drive-Or-Logon-Script.csv"
```

- [ ] Find the SMB shares on relevant servers: 

```powershell
Get-DMSmbSharePaths -ComputerName ("SERVER1","SERVER2") -OutFile "C:\DM\SmbShares.csv"
```

## Scan

- [ ] Scan the locations (see next heading)

Do this as "domain\Administrator",
ie not any other account even if it's in "Domain Admins".
Reason is so that UAC doesn't get in the way.

Probably just append this all at the end of the DM-SharePointMigrationPreChecks.ps1 file,
re-upload, and run it again:

```powershell
Scan-DMTarget -ReportsDir "C:\DM" -Name "D-Data" -Path "D:\Data"
Scan-DMTarget -ReportsDir "C:\DM" -Name "F-" -Path "F:\"
Scan-DMTarget -ReportsDir "C:\DM" -Name "E-" -Path "E:\"
Scan-DMTarget -ReportsDir "C:\DM" -Name "D-Home" -Path "D:\Home"
Scan-DMTarget -ReportsDir "C:\DM" -Name "D-test" -Path "D:\test"
Scan-DMTarget -ReportsDir "C:\DM" -Name "D-Signatures" -Path "D:\Signatures"
Scan-DMTarget -ReportsDir "C:\DM" -Name "D-Profiles" -Path "D:\Profiles"
```

- [ ] Check for recent files, if you think some of this is very old and not used any more:

```powershell
Get-DMFilesModifiedWithin -folder "D:\Signatures" -Days 366
Get-DMFilesModifiedWithin -folder "D:\Profiles" -Days 366
Get-DMFilesModifiedWithin -folder "D:\Home" -Days 366

Get-DMFilesModifiedWithin -folder "D:\Data" -Days 90
Get-DMFilesModifiedWithin -folder "F:\" -Days 90
Get-DMFilesModifiedWithin -folder "E:\" -Days 90
Get-DMFilesModifiedWithin -folder "D:\test" -Days 90
```

## Prepare report

- [ ] Zip it all up and download to my computer
- [ ] Combine the data, esp "FolderSizeAndItems.csv"

```shell
mkdir ../Combined
find . -name "Folder-Size-And-Items.csv" -exec cat {} >> ../Combined/Folder-Size-And-Items.csv \;
find . -name "File-Access-Denied.csv" -exec cat {} >> ../Combined/File-Access-Denied.csv \;
find . -name "File-Path-Length-Over-256-Characters.txt" -exec cat {} >> ../Combined/File-Path-Length-Over-256-Characters.txt \;
find . -name "Unsupported-File-Extensions.txt" -exec cat {} >> ../Combined/Unsupported-File-Extensions.txt \;
```

- [ ] Edit Folder-Size-And-Items.csv in Excel
	* Add table
	* Delete un-needed rows
	* Add a row for "Gb" with formula "=[@Bytes]/1024/1024/1024"
	* Format the Items row as Number, with comma for the thousands, and zero decimal points

- [ ] Add it to my planner document