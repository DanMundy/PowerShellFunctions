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

function Edit-DMPowerShelProfile {
    if ($env:COMPUTERNAME -eq "server2022core") { vim C:\Users\dan\Documents\WindowsPowerShell\Microsoft.Powershell_profile.ps1 }
}