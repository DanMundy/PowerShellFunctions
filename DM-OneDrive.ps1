### DanMundyPSFunctions: OneDrive
### Version: 20220823T1213
#
# Functions in this file:
# ----------
# Get-DMOneDriveSites
# Get-DMOneDriveSitesFileCount
# New-DMOneDrivePreprovision
# Get-DMSmbSharePaths
# Grant-DMAdminAccessToAllOneDriveSites

## ----------------------------------------------------------------------------

# Function: Get-DMOneDriveSites
# Purpose:  Show OneDrive sites
# Requires: Install-DMModule -Name PnP.PowerShell
# Usage: Get-DMOneDriveSites --tenant "mundy" --outFile "C:\DM\Results.csv"
#        Get-DMOneDriveSites -tenant "mundy" | sort UsageInMB -Descending
# 
# (if eg SharePoint URL is "https://mundy.sharepoint.com" then Tenant is "mundy")
# Todo: Parameter checking, to make sure it's just a single word, no "https://" included (as I'm always mistyping it)

function Get-DMOneDriveSites ($tenant, $outFile) { 
    if ($(get-pnpcontext).url -ne "https://$tenant.sharepoint.com") { Connect-PnPOnline -Url "https://$tenant.sharepoint.com" -Interactive }
    #if($azureConnection.Account -eq $null){ $global:azureConnection = Connect-AzureAD } # Connect to AAD
     
    #Get OneDrive Site Details and export to CSV
    $Result = Get-PnPTenantSite -IncludeOneDriveSites -Filter "Url -like 'https://$tenant-my.sharepoint.com/personal/'"
    If ($OutFile -ne $Null) {
        $Result | Select Title, URL, Owner, LastContentModifiedDate, StorageUsageCurrent | Export-Csv -Path $outFile -NoTypeInformation
    } Else {
        $Result | Select Title, URL, @{L='Modified';E={$_.LastContentModifiedDate}}, @{L='UsageInMB';E={$_.StorageUsageCurrent}}
    }
}

# Usage:   Get-DMOneDriveSitesFileCount -SiteURL "https://purewineco-my.sharepoint.com/personal/stanley_tan_purewine_co"
# Sources: https://dan.srl/RFGK https://dan.srl/XIHN
# Todo:    Combine it with the above, so it scans *all* OneDrives, and shows both usage in MB, and number of files

function Get-DMOneDriveSitesFileCount ($SiteURL) {
    $ListName = "Documents"

    Connect-PnPOnline $SiteURL -Interactive
    $List = Get-PnPList -Identity $ListName

    Get-PnPList -Identity $ListName | Select-Object  ParentWebUrl,Title,ItemCount 
}

## ----------------------------------------------------------------------------

## ----------------------------------------------------------------------------

# DRAFT:    THIS FUNCTION HASN'T BEEN TESTED YET
# Function: New-DMOneDrivePreprovision
# Purpose:  Create OneDrive for users who don't have one, so that migration won't fail
# Usage:    New-DMOneDrivePreprovision

function New-DMOneDrivePreprovision ($AdminCenterURL, $UserUPN) {
     
    #Connect to PnP Online
    Connect-PnPOnline -Url $AdminCenterURL -Interactive
     
    #Create OneDrive for User
    New-PnPPersonalSite -Email $UserUPN
    #Pre-Provision OneDrive for Business Site for Multiple users
    #New-PnPPersonalSite -Email "latam@crescent.com", "saopaulo@crescent.com"
}

## ----------------------------------------------------------------------------

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

# Function: Grant-DMAdminAccessToAllOneDriveSites
# Purpose:  
# Requires: Install-DMModule -Name PnP.PowerShell 
# Usage: Grant-DMAdminAccessToAllOneDriveSites -AdminSiteURL "https://crescent-admin.sharepoint.com" -SiteCollAdmin "sarazhak@crescent.com"

Function Grant-DMAdminAccessToAllOneDriveSites ($AdminSiteURL,$SiteCollAdmin) {
      
    #Connect to PnP Online to the Tenant Admin Site
    Connect-PnPOnline -Url $AdminSiteURL -Interactive
      
    #Get All OneDrive Sites
    $OneDriveSites = Get-PnPTenantSite -IncludeOneDriveSites -Filter "Url -like '-my.sharepoint.com/personal/'"
     
    #Loop through each site
    ForEach($Site in $OneDriveSites)
    { 
        #Add Site collection Admin
        Set-PnPTenantSite -Url $Site.URL -Owners $SiteCollAdmin
        Write-Host -f Green "Added Site Collection Admin to: "$Site.URL
    }
}