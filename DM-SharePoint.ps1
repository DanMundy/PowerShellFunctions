### DanMundyPSFunctions: SharePoint
### Version: 20220623T1133
#
# Functions in this file:
# ----------
# Connect-DMSPSite
# Get-DMAzureADGroupMember
# Add-DMAzureADGroupMember
# Remove-DMAzureADGroupMember
# Reset-DMAzureADGroupMember
# New-DMSPSite
# Set-DMSPSitePermission
# New-DMSPDocumentLibrary
# New-DMSPGroupsForSite
# New-DMSPGroupsForDL
# Set-DMSPDLPermissions

## ----------------------------------------------------------------------------

# Function: Connect-DMSPSite
# Purpose:  Uses PnP PowerShell to connect to a given URL
# Usage: (eg)
# Connect-DMSPSite -Url https://companyname.sharepoint.com
# Connect-DMSPSite -Url https://companyname.sharepoint.com/sites/Sitename

function Connect-DMSPSite {
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
##           AZURE AD GROUPS
## ----------------------------------------------------------------------------

## ----------------------------------------------------------------------------

# Function:
# Purpose:
# Usage: Get-DMAzureADGroupMember -GroupName "SP-S-SITENAME-DL-LIBRARYNAME-P-CONTRIB"
function Get-DMAzureADGroupMember ($GroupName) {
    if($azureConnection.Account -eq $null){ $global:azureConnection = Connect-AzureAD } # Connect to AAD
    $GroupID = (Get-AzureADGroup -Filter "DisplayName eq '$GroupName'").ObjectId
    Get-AzureADGroupMember -ObjectId $GroupId
}

## ----------------------------------------------------------------------------

# Function:
# Purpose: 
# Usage: Add-DMAzureADGroupMember -GroupName "SP-S-SITENAME-DL-LIBRARYNAME-P-CONTRIB" -UserUPN "user@mundy.co"
function Add-DMAzureADGroupMember ($GroupName, $UserUPN) {
    if($azureConnection.Account -eq $null){ $global:azureConnection = Connect-AzureAD } # Connect to AAD
    $GroupID = (Get-AzureADGroup -Filter "DisplayName eq '$GroupName'").ObjectId
    $UserID = (Get-AzureADUser -Filter "UserPrincipalName eq '$UserUPN'").ObjectId
    Add-AzureADGroupMember -ObjectId $GroupId -RefObjectId $UserId
}

## ----------------------------------------------------------------------------

# Function:
# Purpose:
# Usage: Remove-DMAzureADGroupMember
function Remove-DMAzureADGroupMember ($GroupName, $UserUPN) {
    if($azureConnection.Account -eq $null){ $global:azureConnection = Connect-AzureAD } # Connect to AAD
    $GroupID = (Get-AzureADGroup -Filter "DisplayName eq '$GroupName'").ObjectId
    $UserID = (Get-AzureADUser -Filter "UserPrincipalName eq '$UserUPN'").ObjectId
    Remove-AzureADGroupMember -ObjectId $GroupId -MemberId $UserId
}

## ----------------------------------------------------------------------------

# Function:
# Purpose:
# Usage: Reset-DMAzureADGroupMember -GroupName "SP-S-SITENAME-DL-LIBRARYNAME-P-CONTRIB"
function Reset-DMAzureADGroupMember ($GroupName) {
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
# Function: New-DMSPCommSite
# Purpose:  Create Communication Site
# Usage:    New-DMSPCommSite -SiteName "SITENAME"  -SiteURL "https://mundy.sharepoint.com/sites/SITENAME" -AdminCenterURL "https://mundy-Admin.sharepoint.com" -SiteOwner "admin@mundy.onmicrosoft.com" -Timezone 19 -Template "STS#3"
#Function New-DMSPCommSite ($AdminCenterURL, $SiteURL, $SiteName, $SiteOwner, $Template, $Timezone) { 
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


# Function: New-DMSPSite
# Purpose:  Create Team Site
# Usage:    New-DMSPSite -SiteName "SITENAME"  -SiteURL "https://mundy.sharepoint.com/sites/SITENAME" -AdminCenterURL "https://mundy-Admin.sharepoint.com" -SiteOwner "admin@mundy.onmicrosoft.com" -Timezone 19 -Template "STS#3"
Function New-DMSPSite ($AdminCenterURL, $SiteURL, $SiteName, $SiteOwner, $Template, $Timezone) {
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
## Todo: Function to remove default permissions

Function Set-DMSPSitePermission ($SiteURL, $UserID, $GroupName, $PermissionLevel)
{
  Try
  {
    # Connect to PnP Online:
    Connect-PnPOnline -URL $SiteURL -Interactive
    If ($UserID -ne $null)
    {
        # Grant permissions:
        Write-Host "Granting permissions to user"
        Set-PnPWebPermission -User $UserID -AddRole $PermissionLevel
    } ElseIf ($GroupName -ne $null) {
        # Connect to AAD:
        if($azureConnection.Account -eq $null){ $global:azureConnection = Connect-AzureAD }
        # Get the Group ID:
        $GroupID = (Get-AzureADGroup -Filter "DisplayName eq '$GroupName'").ObjectId
        # Grant permissions:
        Write-Host "Granting permissions to group"
        Set-PnPWebPermission -User "c:0t.c|tenant|$GroupId" -AddRole $PermissionLevel
    }
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
# Usage:    New-DMSPDocumentLibrary -SiteURL "https://mundy.sharepoint.com/sites/SITENAME" -LibraryName "LIBRARYNAME"
Function New-DMSPDocumentLibrary($SiteURL, $LibraryName)
{ 
  Try
  {
      #Connect to SharePoint Online
      #Connect-PnPOnline -URL $SiteURL -Interactive
      if($azureConnection.Account -eq $null){ $global:azureConnection = Connect-AzureAD } # Connect to AAD

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
# New-DMSPSite -SiteName "SITENAME"  -SiteURL "https://mundy.sharepoint.com/sites/SITENAME" -AdminCenterURL "https://mundy-Admin.sharepoint.com" -SiteOwner "admin@mundy.onmicrosoft.com" -Timezone 19 -Template "STS#3"
# New-DMSPSite -SiteName "SITENAME2"  -SiteURL "https://mundy.sharepoint.com/sites/SITENAME2" -AdminCenterURL "https://mundy-Admin.sharepoint.com" -SiteOwner "admin@mundy.onmicrosoft.com" -Timezone 19 -Template "STS#3"
# (wait 5 minutes)
#
# 3 = Create AAD security groups for Team Sites
# New-DMSPGroupsForSite -SiteName "SITENAME" -GroupOwner "admin@mundy.onmicrosoft.com"
# New-DMSPGroupsForSite -SiteName "SITENAME2" -GroupOwner "admin@mundy.onmicrosoft.com"
#
# 4 = Purpose: Create AAD security groups for Document Library
# New-DMSPGroupsForDL -SiteName "SITENAME" -LibraryName "Sales" -GroupOwner "admin@mundy.onmicrosoft.com"
# New-DMSPGroupsForDL -SiteName "SITENAME2" -LibraryName "Finance" -GroupOwner "admin@mundy.onmicrosoft.com"
# (wait 5 minutes)
#
# 5 = Create DL in Team Site
# Usage (note: Wait 5 minutes after creating the AAD groups, or this function may fail)
# Usage: New-DMSPDocumentLibrary -SiteURL "https://mundy.sharepoint.com/sites/SITENAME" -LibraryName "Sales"
# Usage: New-DMSPDocumentLibrary -SiteURL "https://mundy.sharepoint.com/sites/SITENAME2" -LibraryName "Finance"
# (wait 5 minutes)
# 6 = For DLs, break permission inheritance, set new permissions
# Usage (note: Wait 5 minutes after creating the DLs, or this function may fail)
# Usage: Set-DMSPDLPermissions -SiteURL "https://mundy.sharepoint.com/sites/SITENAME" -SiteName "SITENAME" -Library "Sales" -UserID "admin@mundy.onmicrosoft.com" -ReadGroupName "SP-S-SITENAME-DL-Sales-P-READ" -ContribGroupName "SP-S-SITENAME-DL-Sales-P-CONTRIB"
# Usage: Set-DMSPDLPermissions -SiteURL "https://mundy.sharepoint.com/sites/SITENAME2" -SiteName "SITENAME2" -Library "Finance" -UserID "admin@mundy.onmicrosoft.com" -ReadGroupName "SP-S-SITENAME2-DL-Finance-P-READ" -ContribGroupName "SP-S-SITENAME-DL-Finance-P-CONTRIB"
#
# ------------------------------

## ----------------------------------------------------------------------------

# Function: New-DMSPGroupsForSite
# Purpose:  Create AAD security groups for Team Site
# Usage:    New-DMSPGroupsForSite -SiteName "SITENAME" -GroupOwner "admin@mundy.onmicrosoft.com"
Function New-DMSPGroupsForSite ($SiteName, $GroupOwner) {
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


# Function: New-DMSPGroupsForDL
# Purpose:  Create AAD security groups for Document Library
# Usage:    New-DMSPGroupsForDL -SiteName "SITENAME" -LibraryName "LIBRARYNAME" -GroupOwner "admin@mundy.onmicrosoft.com"
Function New-DMSPGroupsForDL ($SiteName, $LibraryName, $GroupOwner) {
  
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

# Function: Set-DMSPDLPermissions
# Purpose: Break inheritance and Set New Permissions on Document Library
# Usage: Set-DMSPDLPermissions -SiteURL "https://mundy.sharepoint.com/sites/SITENAME" -SiteName "SITENAME" -Library "LIBRARYNAME" -UserID "admin@mundy.onmicrosoft.com" -ReadGroupName "SP-S-SITENAME-DL-LIBRARYNAME-P-READ" -ContribGroupName "SP-S-SITENAME-DL-LIBRARYNAME-P-CONTRIB"
Function Set-DMSPDLPermissions ($SiteURL, $SiteName, $Library, $UserID, $ReadGroupName, $ContribGroupName,$OwnerGroupName)
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


function Get-DMSPDLFileCount ($SiteURL) {
    $ListName = "Documents"

    Connect-PnPOnline $SiteURL -Interactive
    $List = Get-PnPList -Identity $ListName

    Get-PnPList -Identity $ListName | Select-Object  ParentWebUrl,Title,ItemCount 
}