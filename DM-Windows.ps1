### DanMundyPSFunctions: Windows
### Version: 20220721T2304

## ----------------------------------------------------------------------------

# Function: Get-DM-LastBootTime
# Purpose:  Show when Windows was booted
# Usage:    Get-DM-LastBootTime

function Get-DMLastBootTime {
    Get-WmiObject win32_operatingsystem | select csname, @{LABEL='LastBootUpTime';EXPRESSION={$_.ConverttoDateTime($_.lastbootuptime)}}
}

function Get-DMRebootHistory {
    Get-WmiObject Win32_NTLogEvent -filter "LogFile='System' and EventCode=6005" | Select ComputerName, EventCode, @{LABEL='TimeWritten';EXPRESSION={$_.ConverttoDateTime($_.TimeWritten)}}
}

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