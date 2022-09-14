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

function Show-DMFunctions {
    Write-Host "DM Functions available for loading:"
    Get-Item "C:\DM\PowerShellFunctions-main\DM*.ps1" | Format-Table Name -HideTableHeaders
    Write-Host "Load them with (eg): Import-DMFunction -Name Active-Directory"
    Write-Host "(this doesn't work yet, just source it)"
    Write-Host ""
    Write-Host "DM Functions that have been loaded:"
    Write-Host "----------"
    Get-Command *-DM* | Format-Table Name -HideTableHeaders
}

function Import-DMFunction ($Name) {
    . "C:\DM\PowerShellFunctions-main\$Name"
    Show-DMFunctions
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
Show-DMFunctions

# Tab completion for command history:
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward