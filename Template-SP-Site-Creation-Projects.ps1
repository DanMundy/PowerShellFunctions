# SharePoint Site + DLs Creation Script Template

# ----------
# Create Sites, Document Libraries, and AAD Groups (Script #1)
# ----------

## Template Variables #1 - Stuff that's the same for everything:
### Admin Center URL: <AdminCenterURL eg https://mundy-Admin.sharepoint.com>
### Owner: <Owner eg admin@mundy.onmicrosoft.com>

## Template Variables #2 - Stuff that's unique per site (but the same for all DLs in this site):
### Site Name: <SiteName eg Company>
### Site URL: <SiteURL eg https://mundy.sharepoint.com/sites/Company>
### Site Template: <SiteTemplate eg STS#3 for Team Site>

# Create Team Site:
New-DMSPSite -SiteName "<SiteName eg Company>"  -SiteURL "<SiteURL eg https://mundy.sharepoint.com/sites/Company>" -AdminCenterURL "<AdminCenterURL eg https://mundy-Admin.sharepoint.com>" -SiteOwner "<Owner eg admin@mundy.onmicrosoft.com>" -Timezone 19 -Template "<SiteTemplate eg STS#3 for Team Site>"
# Create AAD security groups for Team Site:
New-DMSPGroupForSite -SiteName "<SiteName eg Company>" -GroupOwner "<Owner eg admin@mundy.onmicrosoft.com>"

### !!! INSTRUCTION !!!
### Do the template replacements for everything above,
### then copy-paste the above to a new file (that file will become the script for creating everything)
### Then do the template replacement for the document library below, append to the new file, ⌘Z to undo, do it again for the next DL, repeat, repeat

### Document Library Name: <DocumentLibraryName eg Management>

# Create AAD security group for Document Library:
New-DMSPGroupsForDL -SiteName "<SiteName eg Company>" -LibraryName "<DocumentLibraryName eg Management>" -GroupOwner "<Owner eg admin@mundy.onmicrosoft.com>"
# Create DL in Team Site:
New-DMSPDocumentLibrary -SiteURL "<SiteURL eg https://mundy.sharepoint.com/sites/Company>" -LibraryName "<DocumentLibraryName eg Management>"
# For DLs, break permission inheritance, set new permissions:
Set-DMSPDLPermissions -SiteURL "<SiteURL eg https://mundy.sharepoint.com/sites/Company>" -SiteName "<SiteName eg Company>" -Library "<DocumentLibraryName eg Management>" -UserID "<Owner eg admin@mundy.onmicrosoft.com>" -ReadGroupName "SP-S-<SiteName eg Company>-DL-<DocumentLibraryName eg Management>-P-READ" -ContribGroupName "SP-S-<SiteName eg Company>-DL-<DocumentLibraryName eg Management>-P-CONTRIB"

### --------------------------------------------------------------------------------
### !!! EXAMPLE COMPLETE SCRIPT !!!
### After all of the sites and DLs are added to the script,
### re-order it like the following:
### Tip: Put a pause after (eg) the first New-DMSPGroupsForDL, the first New-DMSPDocumentLibrary, etc
###     (no need to pause between each command instance, just the first time so I can catch any error and adjust the script as required)
### --------------------------------------------------------------------------------
### 
### # Download & install latest versions of everything:
### Set-Location C:\DM
### Install-DMFunctionsFromGithub
### Import-Module C:\DM\PowerShellFunctions-main\DM-PowerShell.ps1
### Install-DMModule PnP.PowerShell
### Install-DMModule AzureAD
### Import-Module C:\DM\PowerShellFunctions-main\DM-SharePoint.ps1
### 
### # Group all of the sites together:
### New-DMSPSite -SiteName "Company"  -SiteURL "https://mundy.sharepoint.com/sites/Company" -AdminCenterURL "https://mundy-Admin.sharepoint.com" -SiteOwner "admin@mundy.onmicrosoft.com" -Timezone 19 -Template "STS#3"
### Read-Host -Prompt "Press a key to continue"
### 
### # Group all of the AAD groups together:
### New-DMSPGroupsForSite -SiteName "Company" -GroupOwner "admin@mundy.onmicrosoft.com"
### Read-Host -Prompt "Press a key to continue"
### New-DMSPGroupsForDL -SiteName "Company" -LibraryName "Finance" -GroupOwner "admin@mundy.onmicrosoft.com"
### Read-Host -Prompt "Press a key to continue"
### New-DMSPGroupsForDL -SiteName "Company" -LibraryName "Archive" -GroupOwner "admin@mundy.onmicrosoft.com"
### New-DMSPGroupsForDL -SiteName "Company" -LibraryName "Test" -GroupOwner "admin@mundy.onmicrosoft.com"
### 
### # Group all of the document libraries together:
### New-DMSPDocumentLibrary -SiteURL "https://mundy.sharepoint.com/sites/Company" -LibraryName "Finance"
### Read-Host -Prompt "Press a key to continue"
### New-DMSPDocumentLibrary -SiteURL "https://mundy.sharepoint.com/sites/Company" -LibraryName "Archive"
### New-DMSPDocumentLibrary -SiteURL "https://mundy.sharepoint.com/sites/Company" -LibraryName "Test"
### 
### 
### # Group all of the permissions changes together
### # (wait a while first though, for the resources created above to be provisioned)
### 
### Write-Host "Wait a while before proceeding with permissions assignment, so the groups and lists have had enough time to be created:"
### Start-Sleep -Seconds 300
### Read-Host -Prompt "Press a key to continue"
### 
### Set-DMSPDLPermissions -SiteURL "https://mundy.sharepoint.com/sites/Company" -SiteName "Company" -Library "Finance" -UserID "admin@mundy.onmicrosoft.com" -ReadGroupName "SP-S-Company-DL-Finance-P-READ" -ContribGroupName "SP-S-Company-DL-Finance-P-CONTRIB"
### Read-Host -Prompt "Press a key to continue"
### Set-DMSPDLPermissions -SiteURL "https://mundy.sharepoint.com/sites/Company" -SiteName "Company" -Library "Archive" -UserID "admin@mundy.onmicrosoft.com" -ReadGroupName "SP-S-Company-DL-Archive-P-READ" -ContribGroupName "SP-S-Company-DL-Archive-P-CONTRIB"
### Set-DMSPDLPermissions -SiteURL "https://mundy.sharepoint.com/sites/Company" -SiteName "Company" -Library "Test" -UserID "admin@mundy.onmicrosoft.com" -ReadGroupName "SP-S-Company-DL-Test-P-READ" -ContribGroupName "SP-S-Company-DL-Test-P-CONTRIB"
### --------------------------------------------------------------------------------





# ----------
# Add users to AAD Groups (Script #2, I usually do the below later:)
# ----------

# For each group:

# Reset group members
Reset-DMAzureADGroupMember -GroupName "SP-S-ARCHIVE-DL-ADMIN-P-CONTRIB"
# Add group members
Add-DMAzureADGroupMember -GroupName "SP-S-ARCHIVE-DL-ADMIN-P-CONTRIB" -UserUPN "avassallo@mullins.com.au"
Add-DMAzureADGroupMember -GroupName "SP-S-ARCHIVE-DL-ADMIN-P-CONTRIB" -UserUPN "aretallack@mullins.com.au"
Add-DMAzureADGroupMember -GroupName "SP-S-ARCHIVE-DL-ADMIN-P-CONTRIB" -UserUPN "dsantos@mullins.com.au"
# List group members to confirm changes
echo "Members of group SP-S-ARCHIVE-DL-ADMIN-P-CONTRIB:"
Get-DMAzureADGroupMember -GroupName "SP-S-ARCHIVE-DL-ADMIN-P-CONTRIB"
echo "Members of = Sgroup-S-ARCHIVE-DL-HR-ADMIN-P-CONTRIB:"
Get-DMAzureADGroupMember -GroupName "SP-S-ARCHIVE-DL-HR-ADMIN-P-CONTRIB"
echo "Members of group SP-S-ARCHIVE-DL-MARKETING-P-CONTRIB:"
Get-DMAzureADGroupMember -GroupName "SP-S-ARCHIVE-DL-MARKETING-P-CONTRIB"