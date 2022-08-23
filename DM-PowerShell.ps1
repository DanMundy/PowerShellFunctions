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
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 # For older version of Windows (only affects current PowerShell session)
    if ($CurrentUser -eq $True) { $Scope = "CurrentUser"} Else { $Scope = "AllUsers"}
    if (Get-Module $Name -ListAvailable) {
        Update-Module $Name -Force
    } Else {
        Install-Module $Name -Scope $Scope -Force
    }
}

# DM TODO: Below looks interesting: (source: https://dm.wtf/BMZH)
# After installing the PSWindowsUpdate module on your computer, you can remotely install it on other computers or servers using the Update-WUModule cmdlet. For example, to copy the PSWindowsUpdate module from your computer to two remote hosts, run the commands (you need access to the remote servers via the WinRM protocol):
#
# $Targets = "lon-fs02", "lon-db01"
# Update-WUModule -ComputerName $Targets –Local
#
# To save (export) the PoSh module to a shared network folder for further importing on other computers, run:
#
# Save-Module -Name PSWindowsUpdate –Path \\lon-fs02\psmodules\

Function Get-DM-PowerShellVersion {
    Return $PSVersionTable.PSVersion
}