### DanMundyPSFunctions: SharePoint
### Version: 20220623T1133

## ----------------------------------------------------------------------------

# Function: Connect-DMsSPSite
# Purpose:  Uses PnP PowerShell to connect to a given URL
# Usage: (eg)
# Connect-DMsSPSite https://companyname.sharepoint.com
# Connect-DMsSPSite https://companyname.sharepoint.com/sites/Sitename

function Connect-DMsSPSite {
    [CmdletBinding()]
    param (
        $url
    )
    if (!$(get-pnpcontext)) {
        Write-Verbose "Was not already connected - Connecting to $url"
        Connect-PnPOnline -Url $url -Interactive
     } else {
        if ($(get-pnpcontext).url -ne $url) {
            $ConnectionWas = $(get-pnpcontext).url
            Write-Verbose "Was already connected, but changing context from $ConnectionWas to $url"
            Set-PnPContext $url
        } else {
            Write-Verbose "Was already connected, no change."
        }
     }
    if ($(get-pnpcontext).url) { Write-Verbose "! Connected to: "; Write-Verbose (Get-PnPContext).url } else { "! Not connected" }
}

## ----------------------------------------------------------------------------
##           ONEDRIVE
## ----------------------------------------------------------------------------

## ----------------------------------------------------------------------------

# Function:
# Purpose:
# Usage: Get-DMOneDriveSites --tenant "companyname" --outFile "C:\DM\Results.csv"
# 
# (if eg SharePoint URL is "https://companyname.sharepoint.com" then Tenant is "companyname")

function Get-DMOneDriveSites ($tenant, $outFile) { 
    if($azureConnection.Account -eq $null){ $global:azureConnection = Connect-AzureAD } # Connect to AAD
     
    #Get OneDrive Site Details and export to CSV
    Get-PnPTenantSite -IncludeOneDriveSites -Filter "Url -like 'https://$tenant-my.sharepoint.com/personal/'" |
        Select Title, URL, Owner, LastContentModifiedDate, StorageUsage | 
            Export-Csv -Path $outFile -NoTypeInformation
}

## ----------------------------------------------------------------------------

## ----------------------------------------------------------------------------
##           AZURE AD GROUPS
## ----------------------------------------------------------------------------

## ----------------------------------------------------------------------------

# Function:
# Purpose:
# Usage: Get-DM-AzureADGroupMember -GroupName "SP-S-SITENAME-DL-LIBRARYNAME-P-CONTRIB"
function Get-DM-AzureADGroupMember ($GroupName) {
    if($azureConnection.Account -eq $null){ $global:azureConnection = Connect-AzureAD } # Connect to AAD
    $GroupID = (Get-AzureADGroup -Filter "DisplayName eq '$GroupName'").ObjectId
    Get-AzureADGroupMember -ObjectId $GroupId
}

## ----------------------------------------------------------------------------

# Function:
# Purpose:
# Usage: Add-DM-AzureADGroupMember -GroupName "SP-S-SITENAME-DL-LIBRARYNAME-P-CONTRIB" -UserUPN "user@mundy.co"
function Add-DM-AzureADGroupMember ($GroupName, $UserUPN) {
    if($azureConnection.Account -eq $null){ $global:azureConnection = Connect-AzureAD } # Connect to AAD
    $GroupID = (Get-AzureADGroup -Filter "DisplayName eq '$GroupName'").ObjectId
    $UserID = (Get-AzureADUser -Filter "UserPrincipalName eq '$UserUPN'").ObjectId
    Add-AzureADGroupMember -ObjectId $GroupId -RefObjectId $UserId
}

## ----------------------------------------------------------------------------

# Function:
# Purpose:
# Usage: Remove-DM-AzureADGroupMember
function Remove-DM-AzureADGroupMember ($GroupName, $UserUPN) {
    if($azureConnection.Account -eq $null){ $global:azureConnection = Connect-AzureAD } # Connect to AAD
    $GroupID = (Get-AzureADGroup -Filter "DisplayName eq '$GroupName'").ObjectId
    $UserID = (Get-AzureADUser -Filter "UserPrincipalName eq '$UserUPN'").ObjectId
    Remove-AzureADGroupMember -ObjectId $GroupId -MemberId $UserId
}

## ----------------------------------------------------------------------------

# Function:
# Purpose:
# Usage: Reset-DM-AzureADGroupMember -GroupName "SP-S-SITENAME-DL-LIBRARYNAME-P-CONTRIB"
function Reset-DM-AzureADGroupMember ($GroupName) {
    if($azureConnection.Account -eq $null){ $global:azureConnection = Connect-AzureAD } # Connect to AAD
    $GroupID = (Get-AzureADGroup -Filter "DisplayName eq '$GroupName'").ObjectId
    $users=Get-AzureADGroupMember -ObjectId $GroupId -All $true |where {$_.ObjectType -eq 'User'}
    foreach ($user in $users) {
        Remove-AzureADGroupMember -ObjectId $GroupId -MemberId $user.objectId
    }
}

## ----------------------------------------------------------------------------

## ----------------------------------------------------------------------------
##           SITES
## ----------------------------------------------------------------------------

## ----------------------------------------------------------------------------

# !!! Check this - it looks the same as Team site function?? May have pasted the wrong thing?
# Function: New-DM-SPCommSite
# Purpose:  Create Communication Site
# Usage:    New-DM-SPCommSite -SiteName "SITENAME"  -SiteURL "https://mundy.sharepoint.com/sites/SITENAME" -AdminCenterURL "https://mundy-Admin.sharepoint.com" -SiteOwner "admin@mundy.onmicrosoft.com" -Timezone 19 -Template "STS#3"
#Function New-DM-SPCommSite ($AdminCenterURL, $SiteURL, $SiteName, $SiteOwner, $Template, $Timezone) { 
#  Try
#  {
#      #Connect to Tenant Admin
#      Connect-PnPOnline -URL $AdminCenterURL -Interactive
#        
#      #Check if the site exists already
#      $Site = Get-PnPTenantSite | Where {$_.Url -eq $SiteURL}
#    
#      If ($Site -eq $null)
#      {
#          #sharepoint online pnp powershell to create communication site
#          New-PnPTenantSite -Url $SiteURL -Owner $SiteOwner -Title $SiteName -Template $Template -TimeZone $TimeZone -RemoveDeletedSite
#          write-host "Site Collection $($SiteURL) Created Successfully!" -foregroundcolor Green
#      }
#      else
#      {
#          write-host "Site $($SiteURL) exists already!" -foregroundcolor Yellow
#      }
#  }
#  catch {
#      write-host "Error: $($_.Exception.Message)" -foregroundcolor Red
#  }
#}

## ----------------------------------------------------------------------------


# Function: New-DM-SPSite
# Purpose:  Create Team Site
# Usage:    New-DM-SPSite -SiteName "SITENAME"  -SiteURL "https://mundy.sharepoint.com/sites/SITENAME" -AdminCenterURL "https://mundy-Admin.sharepoint.com" -SiteOwner "admin@mundy.onmicrosoft.com" -Timezone 19 -Template "STS#3"
Function New-DM-SPSite ($AdminCenterURL, $SiteURL, $SiteName, $SiteOwner, $Template, $Timezone) {
  Try
  {
      #Connect to Tenant Admin
      Connect-PnPOnline -URL $AdminCenterURL -Interactive
        
      #Check if site exists already
      $Site = Get-PnPTenantSite | Where {$_.Url -eq $SiteURL}
    
      If ($Site -eq $null)
      {
          #sharepoint online pnp powershell to create modern team site without group
          New-PnPTenantSite -Url $SiteURL -Owner $SiteOwner -Title $SiteName -Template $Template -TimeZone $TimeZone -RemoveDeletedSite
          write-host "Site Collection $($SiteURL) Created Successfully!" -foregroundcolor Green
      }
      else
      {
          write-host "Site $($SiteURL) exists already!" -foregroundcolor Yellow
      }
  }
  catch {
      write-host "Error: $($_.Exception.Message)" -foregroundcolor Red
  }   
}

## ----------------------------------------------------------------------------

# Function: Set-DMSPSitePermission
# Purpose:  Grant access to SharePoint Online site
# Usage:    Set-DMSPSitePermission -SiteURL "https://crescent.sharepoint.com/sites/Warehouse" -UserID "Salaudeen@crescent.com" -PermissionLevel "Full Control"

Function Set-DMSPSitePermission ($SiteURL, $SiteName, $UserID, $ReadGroupName, $ContribGroupName,$OwnerGroupName)
{
  Try
  {
    #Connect PnP Online
    Write-Host "Connecting to PnP Online"
    Connect-PnPOnline -URL $SiteURL -Interactive   

    # Grant Permissions
    Set-PnPWebPermission -User $UserAccount -AddRole $PermissionLevel
  }
  Catch {
     write-host -f Red "`tError setting Permissions" $_.Exception.Message
  } 
}

## ----------------------------------------------------------------------------

## ----------------------------------------------------------------------------
##           DOCUMENT LIBRARIES
## ----------------------------------------------------------------------------

## ----------------------------------------------------------------------------

# Function: 
# Purpose:  Create Document Library
# Usage:    New-DM-SPDocumentLibrary -SiteURL "https://mundy.sharepoint.com/sites/SITENAME" -LibraryName "LIBRARYNAME"
Function New-DM-SPDocumentLibrary($SiteURL, $LibraryName)
{ 
  Try
  {
      #Connect to SharePoint Online
      Connect-PnPOnline -URL $SiteURL -Interactive

      Write-host -f Yellow "`nEnsuring Library '$LibraryName'"
        
      #Check if the Library exist already
      $List = Get-PnPList | Where {$_.Title -eq $LibraryName} 
      If($List -eq $Null)
      {
          #Create Document Library
          $List = New-PnPList -Title $LibraryName -Template DocumentLibrary -OnQuickLaunch 
          write-host  -f Green "`tNew Document Library '$LibraryName' has been created!"
      }
      Else
      {
          Write-Host -f Magenta "`tA Document Library '$LibraryName' Already exist!"
      }
  }
  Catch {
      write-host -f Red "`tError Creating Document Library!" $_.Exception.Message
  }
}

## ----------------------------------------------------------------------------

## ----------------------------------------------------------------------------
##           STANDARD GROUP NAMING CONVENTION
## ----------------------------------------------------------------------------

# ------------------------------
#
# Example of all the bits I run during a new site creation project:
# (where doing multiples, eg multiple sites/DLs, call the function on a new line for each one. It doesn't take a list as input (yet))
#
# 1 (Todo) = Create the comms site
#
# 2 = Create the Team site(s)
# New-DM-SPSite -SiteName "SITENAME"  -SiteURL "https://mundy.sharepoint.com/sites/SITENAME" -AdminCenterURL "https://mundy-Admin.sharepoint.com" -SiteOwner "admin@mundy.onmicrosoft.com" -Timezone 19 -Template "STS#3"
# New-DM-SPSite -SiteName "SITENAME2"  -SiteURL "https://mundy.sharepoint.com/sites/SITENAME2" -AdminCenterURL "https://mundy-Admin.sharepoint.com" -SiteOwner "admin@mundy.onmicrosoft.com" -Timezone 19 -Template "STS#3"
# (wait 5 minutes)
#
# 3 = Create AAD security groups for Team Sites
# New-DM-SPGroupsForSite -SiteName "SITENAME" -GroupOwner "admin@mundy.onmicrosoft.com"
# New-DM-SPGroupsForSite -SiteName "SITENAME2" -GroupOwner "admin@mundy.onmicrosoft.com"
#
# 4 = Purpose: Create AAD security groups for Document Library
# New-DM-SPGroupsForDL -SiteName "SITENAME" -LibraryName "Sales" -GroupOwner "admin@mundy.onmicrosoft.com"
# New-DM-SPGroupsForDL -SiteName "SITENAME2" -LibraryName "Finance" -GroupOwner "admin@mundy.onmicrosoft.com"
# (wait 5 minutes)
#
# 5 = Create DL in Team Site
# Usage (note: Wait 5 minutes after creating the AAD groups, or this function may fail)
# Usage: New-DM-SPDocumentLibrary -SiteURL "https://mundy.sharepoint.com/sites/SITENAME" -LibraryName "Sales"
# Usage: New-DM-SPDocumentLibrary -SiteURL "https://mundy.sharepoint.com/sites/SITENAME2" -LibraryName "Finance"
# (wait 5 minutes)
# 6 = For DLs, break permission inheritance, set new permissions
# Usage (note: Wait 5 minutes after creating the DLs, or this function may fail)
# Usage: Set-DM-SPDLPermissions -SiteURL "https://mundy.sharepoint.com/sites/SITENAME" -SiteName "SITENAME" -Library "Sales" -UserID "admin@mundy.onmicrosoft.com" -ReadGroupName "SP-S-SITENAME-DL-Sales-P-READ" -ContribGroupName "SP-S-SITENAME-DL-Salez-P-CONTRIB"
# Usage: Set-DM-SPDLPermissions -SiteURL "https://mundy.sharepoint.com/sites/SITENAME2" -SiteName "SITENAME2" -Library "Finance" -UserID "admin@mundy.onmicrosoft.com" -ReadGroupName "SP-S-SITENAME2-DL-Finance-P-READ" -ContribGroupName "SP-S-SITENAME-DL-Finance-P-CONTRIB"
#
# ------------------------------

## ----------------------------------------------------------------------------

# Function: New-DM-SPGroupsForSite
# Purpose:  Create AAD security groups for Team Site
# Usage:    New-DM-SPGroupsForSite -SiteName "SITENAME" -GroupOwner "admin@mundy.onmicrosoft.com"
Function New-DM-SPGroupsForSite ($SiteName, $GroupOwner) {
  if($azureConnection.Account -eq $null){ $global:azureConnection = Connect-AzureAD } # Connect to AAD

  $AADGroupOwner = (Get-AzureADUser -Filter "UserPrincipalName eq '$GroupOwner'")

  # Create READ group:
  $AADGroupForSiteRead = "SP-S-$SiteName-P-READ"    
  New-AzureADGroup -DisplayName "$AADGroupForSiteRead" -MailEnabled $false -SecurityEnabled $true -MailNickName "NotSet"
  $AADGroup = (Get-AzureADGroup -Filter "Displayname eq '$AADGroupForSiteRead'")
  Add-AzureADGroupOwner -ObjectId $AADGroup.ObjectId -RefObjectId $AADGroupOwner.ObjectId

  # Create CONTRIB group:
  $AADGroupForSiteContrib = "SP-S-$SiteName-P-CONTRIB"    
  New-AzureADGroup -DisplayName "$AADGroupForSiteContrib" -MailEnabled $false -SecurityEnabled $true -MailNickName "NotSet"
  $AADGroup = (Get-AzureADGroup -Filter "Displayname eq '$AADGroupForSiteContrib'")
  Add-AzureADGroupOwner -ObjectId $AADGroup.ObjectId -RefObjectId $AADGroupOwner.ObjectId

  # Create OWNER group:
  $AADGroupForSiteOwner = "SP-S-$SiteName-P-OWNER"    
  New-AzureADGroup -DisplayName "$AADGroupForSiteOwner" -MailEnabled $false -SecurityEnabled $true -MailNickName "NotSet"
  $AADGroup = (Get-AzureADGroup -Filter "Displayname eq '$AADGroupForSiteOwner'")
  Add-AzureADGroupOwner -ObjectId $AADGroup.ObjectId -RefObjectId $AADGroupOwner.ObjectId
}

## ----------------------------------------------------------------------------


# Function: New-DM-SPGroupsForDL
# Purpose:  Create AAD security groups for Document Library
# Usage:    New-DM-SPGroupsForDL -SiteName "SITENAME" -LibraryName "LIBRARYNAME" -GroupOwner "admin@mundy.onmicrosoft.com"
Function New-DM-SPGroupsForDL ($SiteName, $LibraryName, $GroupOwner) {
  
  if($azureConnection.Account -eq $null){ $global:azureConnection = Connect-AzureAD } # Connect to AAD

  $AADGroupOwner = (Get-AzureADUser -Filter "UserPrincipalName eq '$GroupOwner'")

  # Create READ group
  $AADGroupForDLRead = "SP-S-$SiteName-DL-$LibraryName-P-READ"
  New-AzureADGroup -DisplayName "$AADGroupForDLRead" -MailEnabled $false -SecurityEnabled $true -MailNickName "NotSet"
  $AADGroup = (Get-AzureADGroup -Filter "Displayname eq '$AADGroupForDLRead'")
  Add-AzureADGroupOwner -ObjectId $AADGroup.ObjectId -RefObjectId $AADGroupOwner.ObjectId
  
  # Create CONTRIB group
  $AADGroupForDLContrib = "SP-S-$SiteName-DL-$LibraryName-P-CONTRIB"
  New-AzureADGroup -DisplayName "$AADGroupForDLContrib" -MailEnabled $false -SecurityEnabled $true -MailNickName "NotSet"
  $AADGroup = (Get-AzureADGroup -Filter "Displayname eq '$AADGroupForDLContrib'")
  Add-AzureADGroupOwner -ObjectId $AADGroup.ObjectId -RefObjectId $AADGroupOwner.ObjectId
  
  # Create OWNER group
  $AADGroupForDLOwner = "SP-S-$SiteName-DL-$LibraryName-P-OWNER"
  New-AzureADGroup -DisplayName "$AADGroupForDLOwner" -MailEnabled $false -SecurityEnabled $true -MailNickName "NotSet"
  $AADGroup = (Get-AzureADGroup -Filter "Displayname eq '$AADGroupForDLOwner'")
  Add-AzureADGroupOwner -ObjectId $AADGroup.ObjectId -RefObjectId $AADGroupOwner.ObjectId
}

## ----------------------------------------------------------------------------

# Function: Set-DM-SPDLPermissions
# Purpose: Break inheritance and Set New Permissions on Document Library
# Usage: Set-DM-SPDLPermissions -SiteURL "https://mundy.sharepoint.com/sites/SITENAME" -SiteName "SITENAME" -Library "LIBRARYNAME" -UserID "admin@mundy.onmicrosoft.com" -ReadGroupName "SP-S-SITENAME-DL-LIBRARYNAME-P-READ" -ContribGroupName "SP-S-SITENAME-DL-LIBRARYNAME-P-CONTRIB"
Function Set-DM-SPDLPermissions ($SiteURL, $SiteName, $Library, $UserID, $ReadGroupName, $ContribGroupName,$OwnerGroupName)
{ 
  Try
  {
      #Connect PnP Online
      Connect-PnPOnline -URL $SiteURL -Interactive
      
      #Break Permission Inheritance of the List
      Write-Host "Breaking inheritance"
      Set-PnPList -Identity $Library -BreakRoleInheritance -CopyRoleAssignments
       
      #Grant permission on List to User
      Write-Host "Granting permissions to $UserID"
      Set-PnPListPermission -Identity $Library -AddRole "Full Control" -User $UserID
       
      #Grant permission on list to Group
      Write-Host "Granting permissions to groups"
      $ReadGroupID = (Get-AzureADGroup -Filter "DisplayName eq '$ReadGroupName'").ObjectId
      $ContribGroupID = (Get-AzureADGroup -Filter "DisplayName eq '$ContribGroupName'").ObjectId
      #$OwnerGroupID = (Get-AzureADGroup -Filter "DisplayName eq '$OwnerGroupName'").ObjectId
      Set-PnPListPermission -Identity $Library -User "c:0t.c|tenant|$ReadGroupId" -AddRole 'Read'
      Set-PnPListPermission -Identity $Library -User "c:0t.c|tenant|$ContribGroupId" -AddRole 'Contribute'
      #Set-PnPListPermission -Identity $Library -User "c:0t.c|tenant|$OwnerGroupId" -AddRole 'Owner'

      # Remove the permissions for built-in groups
      Write-Host "Removing built-in permissions"
      $GroupName = "$SiteName Visitors"
      $Context = Get-PnPContext
      $List = Get-PnPList -Identity $Library
      $Group = Get-PnPGroup -Identity $GroupName
      $List.RoleAssignments.GetByPrincipal($Group).DeleteObject()
      $Context.ExecuteQuery()
      $GroupName = "$SiteName Members"
      $Context = Get-PnPContext
      $List = Get-PnPList -Identity $Library
      $Group = Get-PnPGroup -Identity $GroupName
      $List.RoleAssignments.GetByPrincipal($Group).DeleteObject()
      $Context.ExecuteQuery()
      $GroupName = "$SiteName Owners"
      $Context = Get-PnPContext
      $List = Get-PnPList -Identity $Library
      $Group = Get-PnPGroup -Identity $GroupName
      $List.RoleAssignments.GetByPrincipal($Group).DeleteObject()
      $Context.ExecuteQuery() 
  }
  Catch {
      write-host -f Red "`tError setting DL Permissions, probably just need to try again" $_.Exception.Message
  }
}

## ----------------------------------------------------------------------------

