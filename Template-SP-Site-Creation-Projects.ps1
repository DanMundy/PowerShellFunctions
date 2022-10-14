# SharePoint Site + DLs Creation Script Template

# ----------
# Load the functions, connect to site
# ----------

# Required functions: (All in DM-SharePoint.ps1)
#     New-DM-SPSite
#     New-DM-SPGroupForSite
#     New-DM-SPGroupsForDL
#     New-DM-SPDocumentLibrary
#     Set-DM-SPDLPermissions
#     Reset-DM-AzureADGroupMember
#     Add-DM-AzureADGroupMember
#     Get-DM-AzureADGroupMember
# No need to specifically connect, the New-X functions do that
. ./DM-SharePoint.ps1

# ----------
# Create Sites, Document Libraries, and AAD Groups
# ----------

## Template Variables #1 - Stuff that's the same for everything:
### Admin Center URL: <AdminCenterURL eg https://mundy-Admin.sharepoint.com>
### Owner: <Owner eg admin@mundy.onmicrosoft.com>

## Template Variables #2 - Stuff that's unique per site (but the same for all DLs in this site):
### Site Name: <SiteName eg Company>
### Site URL: <SiteURL eg https://mundy.sharepoint.com/sites/Company>
### Site Template: <SiteTemplate eg STS#3 for Team Site>

# Create Team Site:
New-DM-SPSite -SiteName "<SiteName eg Company>"  -SiteURL "<SiteURL eg https://mundy.sharepoint.com/sites/Company>" -AdminCenterURL "<AdminCenterURL eg https://mundy-Admin.sharepoint.com>" -SiteOwner "<Owner eg admin@mundy.onmicrosoft.com>" -Timezone 19 -Template "<SiteTemplate eg STS#3 for Team Site>"
# Create AAD security groups for Team Site:
New-DM-SPGroupForSite -SiteName "<SiteName eg Company>" -GroupOwner "<Owner eg admin@mundy.onmicrosoft.com>"

### !!! INSTRUCTION !!!
### Do the template replacements for everything above,
### then copy-paste the above to a new file (that file will become the script for creating everything)
### Then do the template replacement for the document library below, append to the new file, ⌘Z to undo, do it again for the next DL, repeat, repeat

### Document Library Name: <DocumentLibraryName eg Management>

# Create AAD security group for Document Library:
New-DM-SPGroupsForDL -SiteName "<SiteName eg Company>" -LibraryName "<DocumentLibraryName eg Management>" -GroupOwner "<Owner eg admin@mundy.onmicrosoft.com>"
# Create DL in Team Site:
New-DM-SPDocumentLibrary -SiteURL "<SiteURL eg https://mundy.sharepoint.com/sites/Company>" -LibraryName "<DocumentLibraryName eg Management>"
# For DLs, break permission inheritance, set new permissions:
Set-DM-SPDLPermissions -SiteURL "<SiteURL eg https://mundy.sharepoint.com/sites/Company>" -SiteName "<SiteName eg Company>" -Library "<DocumentLibraryName eg Management>" -UserID "<Owner eg admin@mundy.onmicrosoft.com>" -ReadGroupName "SP-S-<SiteName eg Company>-DL-<DocumentLibraryName eg Management>-P-READ" -ContribGroupName "SP-S-<SiteName eg Company>-DL-<DocumentLibraryName eg Management>-P-CONTRIB"

# ----------
# Add users to AAD Groups
# ----------

# For each group:

# Reset group members
Reset-DM-AzureADGroupMember -GroupName "SP-S-ARCHIVE-DL-ADMIN-P-CONTRIB"
# Add group members
Add-DM-AzureADGroupMember -GroupName "SP-S-ARCHIVE-DL-ADMIN-P-CONTRIB" -UserUPN "avassallo@mullins.com.au"
Add-DM-AzureADGroupMember -GroupName "SP-S-ARCHIVE-DL-ADMIN-P-CONTRIB" -UserUPN "aretallack@mullins.com.au"
Add-DM-AzureADGroupMember -GroupName "SP-S-ARCHIVE-DL-ADMIN-P-CONTRIB" -UserUPN "dsantos@mullins.com.au"
# List group members to confirm changes
echo "Members of group SP-S-ARCHIVE-DL-ADMIN-P-CONTRIB:"
Get-DM-AzureADGroupMember -GroupName "SP-S-ARCHIVE-DL-ADMIN-P-CONTRIB"
echo "Members of = Sgroup-S-ARCHIVE-DL-HR-ADMIN-P-CONTRIB:"
Get-DM-AzureADGroupMember -GroupName "SP-S-ARCHIVE-DL-HR-ADMIN-P-CONTRIB"
echo "Members of group SP-S-ARCHIVE-DL-MARKETING-P-CONTRIB:"
Get-DM-AzureADGroupMember -GroupName "SP-S-ARCHIVE-DL-MARKETING-P-CONTRIB"