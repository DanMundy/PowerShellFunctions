### DanMundyPSFunctions: Windows
### Version: 20220721T2304

## ----------------------------------------------------------------------------

# Function: Get-DM-InstallFeatureUpdate
# Purpose:  
# Usage:    Get-DM-LastBootTime
# Sources:  https://dm.wtf/IXTU

function Install-DM-WindowsFeatureUpdate {
    $winVer = [System.Environment]::OSVersion.Version.Major
    $dir = 'C:\_Windows_FU\packages'
    mkdir $dir

    if ($winVer -eq 10)
        {  
            $webClient = New-Object System.Net.WebClient
            $url = 'https://go.microsoft.com/fwlink/?LinkID=799445'
            $file = "$($dir)\Win10Upgrade.exe"
            $webClient.DownloadFile($url,$file)
            Start-Process -FilePath $file -ArgumentList '/quietinstall /skipeula /auto upgrade /copylogs $dir'
            } 
        
        else 

            {
                echo "This is Not Windows10 OS "
            }
        
    sleep 10

    #Remove-Item "C:\_Windows_FU" -Recurse -Force -Confirm:$false
}

## ----------------------------------------------------------------------------

# Function: Install-DM-WindowsUpdates
# Purpose:  Silently install all available updates, no reboot
# Usage:    Install-DM-WindowsUpdates

function Install-DM-WindowsUpdates {
    if(-not (Get-Module PSWindowsUpdate -ListAvailable)){
    Install-Module PSWindowsUpdate -Scope CurrentUser -Force
    }
    Get-WindowsUpdate -Install -IgnoreUserInput -AcceptAll -IgnoreReboot
}


## ----------------------------------------------------------------------------

# Function: Update-DM-PowerShellModule
# Purpose:  Update (or Install) PowerShell Module
# Usage:    Update-DM-PowerShellModule

function Update-DM-PowerShellModule ($Name) {
    # Check if module installed
    if (Get-Module $Name -ListAvailable) {
        # Update it:
        # Update-Module PnP.PowerShell*
        Update-Module $Name
    } Else {
        # Install if required
        Install-Module $Name -Scope CurrentUser -Force
    }
}


function Update-DM-PowerShellModule ($Name) {
    # Check if module installed
    if (Get-Module $Name -ListAvailable) {
        # Update it:
        # Update-Module PnP.PowerShell*
        Update-Module $Name -Scope CurrentUser -Force
    } Else {
        # Install if required
        Install-Module $Name -Scope CurrentUser -Force
    }
}