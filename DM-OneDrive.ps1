### DanMundyPSFunctions: OneDrive
### Version: 20220823T1213

## ----------------------------------------------------------------------------

# Function: Get-DMOneDriveSites
# Purpose:  Show OneDrive sites
# Requires: Install-DM-Module -Name PnP.PowerShell
# Usage: Get-DMOneDriveSites --tenant "companyname" --outFile "C:\DM\Results.csv"
# 
# (if eg SharePoint URL is "https://companyname.sharepoint.com" then Tenant is "companyname")

function Get-DMOneDriveSites ($tenant, $outFile) { 
    if ($(get-pnpcontext).url -ne "https://$tenant.sharepoint.com") { Connect-DM-SPSite -Url "https://$tenant.sharepoint.com" }
    #if($azureConnection.Account -eq $null){ $global:azureConnection = Connect-AzureAD } # Connect to AAD
     
    #Get OneDrive Site Details and export to CSV
    $Result = Get-PnPTenantSite -IncludeOneDriveSites -Filter "Url -like 'https://$tenant-my.sharepoint.com/personal/'"
    If ($OutFile -ne $Null) {
        $Result | Select Title, URL, Owner, LastContentModifiedDate, StorageUsageCurrent | Export-Csv -Path $outFile -NoTypeInformation
    } Else {
        $Result | Select Title, URL, LastContentModifiedDate, @{L='StorageUsageCurrentMB';E={$_.StorageUsageCurrent}}
    }
}

## ----------------------------------------------------------------------------

## ----------------------------------------------------------------------------

# DRAFT:    THIS FUNCTION HASN'T BEEN TESTED YET
# Function: New-DM-OneDrivePreprovision
# Purpose:  Create OneDrive for users who don't have one, so that migration won't fail
# Usage:    New-DM-OneDrivePreprovision

function New-DM-OneDrivePreprovision {
    #Set SPO service url
    $SPOServiceUrl = "https://mundy-admin.sharepoint.com"
     
    #Set user emails to provision SPO Personal Site (OneDrive)
    $UserEmails = Get-Content -path "D:\Temp\User-Emails.txt"
     
    #Connect to SharePoint Online Admin
    Connect-SPOService -Url $SPOServiceUrl
     
    #Confirm connected to correct SPO
    Get-SPOSite
     
    #Request SPO Personal Site (OneDrive) for each user
    Request-SPOPersonalSite -UserEmails $UserEmails
     
    #Get list of all SPO personal sites (OneDrive) URLs.
    Get-SPOSite -IncludePersonalSite $true -Limit all -Filter "Url -like '-my.sharepoint.com/personal/'" | Sort Url | ft Url
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