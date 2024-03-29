### DanMundyPSFunctions: Windows
### Version: 20220721T2304

## ----------------------------------------------------------------------------

# Function: Get-DMInstallFeatureUpdate
# Purpose:  
# Usage:    Get-DMLastBootTime
# Sources:  https://dan.srl/IXTU

function Install-DMWindowsFeatureUpdate {
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

# Function: Install-DMWindowsUpdates
# Purpose:  Silently install all available updates, no reboot
# Usage:    Install-DMWindowsUpdates
# More info on PSWindowsUpdate: https://dan.srl/BMZH

function Install-DMWindowsUpdates {
    if(-not (Get-Module PSWindowsUpdate -ListAvailable)){
    Install-Module PSWindowsUpdate -Scope CurrentUser -Force
    }
    Write-Host "Checking for available updates"
    Get-WindowsUpdate
    Write-Host "Installing updates"
    Get-WindowsUpdate -Install -IgnoreUserInput -AcceptAll -AutoReboot  | Out-File "$env:Temp\$(Get-Date -f yyyy-MM-dd)-WindowsUpdate.log" -Append -Force
    #Get-WindowsUpdate -Install -IgnoreUserInput -AcceptAll -IgnoreReboot
}


## ----------------------------------------------------------------------------