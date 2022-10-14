# SharePoint Site + DLs Creation Script Template

## Template Variables #1 - Stuff that's the same for everything:
### Admin Center URL: <AdminCenterURL eg https://mundy-Admin.sharepoint.com>
### Owner: <Owner eg admin@mundy.onmicrosoft.com>

## Template Variables #2 - Stuff that's unique per site (but the same for all DLs in this site):
### Site Name: <SiteName eg Company>
### Site URL: <SiteURL eg https://mundy.sharepoint.com/sites/Company>
### Site Template: <SiteTemplate eg STS#3 for Team Site>

# Create Team Site:
New-C1-SPSite -SiteName "<SiteName eg Company>"  -SiteURL "<SiteURL eg https://mundy.sharepoint.com/sites/Company>" -AdminCenterURL "<AdminCenterURL eg https://mundy-Admin.sharepoint.com>" -SiteOwner "<Owner eg admin@mundy.onmicrosoft.com>" -Timezone 19 -Template "<SiteTemplate eg STS#3 for Team Site>"
# Create AAD security groups for Team Site:
New-C1-SPGroupForSite -SiteName "<SiteName eg Company>" -GroupOwner "<Owner eg admin@mundy.onmicrosoft.com>"

### !!! INSTRUCTION !!!
### Do the template replacements for everything above,
### then copy-paste the above to a new file (that file will become the script for creating everything)
### Then do the template replacement for the document library below, append to the new file, ⌘Z to undo, do it again for the next DL, repeat, repeat


### Document Library Name: <DocumentLibraryName eg Management>

# Create AAD security group for Document Library:
New-C1-SPGroupsForDL -SiteName "<SiteName eg Company>" -LibraryName "<DocumentLibraryName eg Management>" -GroupOwner "<Owner eg admin@mundy.onmicrosoft.com>"
# Create DL in Team Site:
New-C1-SPDocumentLibrary -SiteURL "<SiteURL eg https://mundy.sharepoint.com/sites/Company>" -LibraryName "<DocumentLibraryName eg Management>"
# For DLs, break permission inheritance, set new permissions:
Set-C1-SPDLPermissions -SiteURL "<SiteURL eg https://mundy.sharepoint.com/sites/Company>" -SiteName "<SiteName eg Company>" -Library "<DocumentLibraryName eg Management>" -UserID "<Owner eg admin@mundy.onmicrosoft.com>" -ReadGroupName "SP-S-<SiteName eg Company>-DL-<DocumentLibraryName eg Management>-P-READ" -ContribGroupName "SP-S-<SiteName eg Company>-DL-<DocumentLibraryName eg Management>-P-CONTRIB"

