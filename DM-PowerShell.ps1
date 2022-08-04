### DanMundyPSFunctions: SharePoint
### Version: 20220623T1133

## ----------------------------------------------------------------------------

# Function: Get-DM-PowerShellFunctions
# Purpose:  Download and unzip my PowerShell functions
# Usage:    Get-DM-PowerShellFunctionsGet-DM-PowerShellFunctions

function Get-DM-PowerShellFunctions {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    wget https://dm.wtf/psf -outFile dm.zip
    Expand-Archive .\dm.zip . -Force
}

## ----------------------------------------------------------------------------

# Function: Install-DM-Module
# Purpose:  Update (or Install) PowerShell Module
# Usage:    Install-DM-Module -Name ModuleName (install for all users)
#           Install-DM-Module -Name ModuleName -CurrentUser $true (install for current user)

function Install-DM-Module ($Name,$CurrentUser) {
    if ($CurrentUser -eq $True) { $Scope = "CurrentUser"} Else { $Scope = "AllUsers"}
    if (Get-Module $Name -ListAvailable) {
        Update-Module $Name -Scope $Scope -Force
    } Else {
        Install-Module $Name -Scope $Scope -Force
    }
}