### DanMundyPSFunctions: PowerShell Profile
### Version: 20220825T1459

## ----------------------------------------------------------------------------

# Function: Install-DMFunctionsFromGithub
# Purpose:  Download and unzip my PowerShell functions
# Usage:    Install-DMFunctionsFromGithubInstall-DMFunctionsFromGithub

function Install-DMFunctionsFromGithub {
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
    Write-Host "DM Functions available for loading:"
    Get-Item "C:\DM\PowerShellFunctions-main\DM*.ps1" | Format-Table Name -HideTableHeaders
    Write-Host "Load them with (eg): Import-DMFunction -Name Active-Directory"
    Write-Host ""
    Write-Host "DM Functions that have been loaded:"
    Write-Host "----------"
    Get-Command *-DM* | Format-Table Name -HideTableHeaders
}

function Import-DMFunction ($Name) {
    $Folder = "C:\DM\PowerShellFunctions-main"
    If ($Name -eq "Active-Directory") { . $Folder\DM-Active-Directory.ps1 }
    If ($Name -eq "Filesystem") { . $Folder\DM-Filesystem.ps1 }
    If ($Name -eq "Hyper-V") { . $Folder\DM-Hyper-V.ps1 }
    If ($Name -eq "Internet") { . $Folder\DM-Internet.ps1 }
    If ($Name -eq "Network") { . $Folder\DM-Network.ps1 }
    If ($Name -eq "OneDrive") { . $Folder\DM-OneDrive.ps1 }
    If ($Name -eq "PowerShell") { . $Folder\DM-PowerShell.ps1 }
    If ($Name -eq "PowerShellProfile") { . $Folder\DM-PowerShellProfile.ps1 }
    If ($Name -eq "SharePoint") { . $Folder\DM-SharePoint.ps1 }
    If ($Name -eq "Veeam") { . $Folder\DM-Veeam.ps1 }
    If ($Name -eq "Windows") { . $Folder\DM-Windows.ps1 }
    If ($Name -eq "WindowsUpdates") { . $Folder\DM-WindowsUpdates.ps1 }
    Get-DMCommand
}

# ---------- PROMPT ----------

function Prompt
{
    $promptString = "PS " + $(Get-Location) + ">"
    Write-Host $promptString -NoNewline -ForegroundColor Yellow
    return " "
}
# ---------- WINDOW TITLE ----------

$Host.UI.RawUI.WindowTitle = "PowerShell"

# ---------- GO TO MY DIR ----------

cd C:\DM
Get-DMCommand
