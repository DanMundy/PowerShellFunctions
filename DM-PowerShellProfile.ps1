### DanMundyPSFunctions: PowerShell Profile
### Version: 20220825T1459

## ----------------------------------------------------------------------------

# Function: Install-DMPowerShellFunctions
# Purpose:  Download and unzip my PowerShell functions
# Usage:    Install-DMPowerShellFunctionsInstall-DMPowerShellFunctions

function Install-DMPowerShellFunctions {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    wget https://dm.wtf/psf -outFile dm.zip
    Expand-Archive .\dm.zip . -Force
}

function Edit-DMPowerShellProfile {
    vim $PROFILE
}

function Reload-DMPowerShellProfile {
    . $PROFILE
}

function Get-DMCommand {
    Write-Host "Functions that have been loaded:"
    Get-Command *-DM* | Format-Table Name -HideTableHeaders
    Write-Host "Available for loading:"
    Get-Item "C:\DM\PowerShellFunctions-main\DM*.ps1" | Format-Table Name -HideTableHeaders
}