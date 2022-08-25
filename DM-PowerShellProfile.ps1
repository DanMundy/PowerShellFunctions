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
    Get-Command *-DM* | Format-Table @{L='DM Commands';E={$_.Name}}
}