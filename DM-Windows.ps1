### DanMundyPSFunctions: Windows
### Version: 20220721T2304

## ----------------------------------------------------------------------------

# Function:     Get-DM-LastBootTime
# Purpose:      Show when Windows was booted
# Usage:        Get-DM-LastBootTime

function Get-DMLastBootTime {
    Get-WmiObject win32_operatingsystem | select csname, @{LABEL='LastBootUpTime';EXPRESSION={$_.ConverttoDateTime($_.lastbootuptime)}}
}

function Get-DMRebootHistory {
    Get-WmiObject Win32_NTLogEvent -filter "LogFile='System' and EventCode=6005" | Select ComputerName, EventCode, @{LABEL='TimeWritten';EXPRESSION={$_.ConverttoDateTime($_.TimeWritten)}}
}

## ----------------------------------------------------------------------------

# Function:     Get-DM-InstalledPrograms
# Purpose:      Show applications installed
# Usage:        Get-DM-InstalledPrograms

function Get-DM-InstalledPrograms {
    Get-WmiObject -Class Win32_Product | ft Name,Vendor,Version
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

## ----------------------------------------------------------------------------

# Function:     New-DM-Shortcut
# Purpose:      Creates a shortcut (LNK file)
# Usage:        New-DM-Shortcut

function New-DM-Shortcut ($TargetFile,$ShortcutFile) {
    $WScriptShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WScriptShell.CreateShortcut($ShortcutFile)
    $Shortcut.TargetPath = $TargetFile
    $Shortcut.Save()
}

## ----------------------------------------------------------------------------

# Function:     New-DM-OfficeShortcuts
# Purpose:      Creates desktop shortcuts for the Office Apps
# Usage:        New-DM-OfficeShortcuts -LogFile "C:\Temp\New-Object-Desktop-Shortcuts.log"
# Depends on:   New-DM-Shortcut (in this file)

function New-DM-OfficeShortcuts ($LogFile) {
    #Start logging PS script for troubleshooting.
    Start-Transcript -Path $LogFile

    #Create Microsoft Office public deskop shortcuts.
    New-DM-Shortcut -TargetFile "C:\Program Files\Microsoft Office\root\Office16\MSACCESS.EXE" -ShortcutFile "C:\Users\Public\Desktop\Access.lnk"
    New-DM-Shortcut -TargetFile "C:\Program Files\Microsoft Office\root\Office16\EXCEL.EXE" -ShortcutFile "C:\Users\Public\Desktop\Excel.lnk"
    New-DM-Shortcut -TargetFile "C:\Program Files\Microsoft Office\root\Office16\OUTLOOK.EXE" -ShortcutFile "C:\Users\Public\Desktop\Outlook.lnk"
    New-DM-Shortcut -TargetFile "C:\Program Files\Microsoft Office\root\Office16\POWERPNT.EXE" -ShortcutFile "C:\Users\Public\Desktop\PowerPoint.lnk"
    New-DM-Shortcut -TargetFile "C:\Program Files\Microsoft Office\root\Office16\MSPUB.EXE" -ShortcutFile "C:\Users\Public\Desktop\Publisher.lnk"
    New-DM-Shortcut -TargetFile "C:\Program Files\Microsoft Office\root\Office16\WINWORD.EXE" -ShortcutFile "C:\Users\Public\Desktop\Word.lnk"

    #Create Microsoft Internet Exporer public desktop shortcut.
    #New-DM-Shortcut -TargetFile "C:\Program Files\Internet Explorer\iexplore.exe" -ShortcutFile "C:\Users\Public\Desktop\Internet Explorer.lnk"

    #Create Google Chrome desktop shortcut.
    #New-DM-Shortcut -TargetFile "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" -ShortcutFile "C:\Users\Public\Desktop\Google Chrome.lnk"

    #Stop logging PS script for troubleshooting.
    Stop-Transcript
}
# New-DM-OfficeShortcuts -LogFile "$env:Temp\New-Object-Desktop-Shortcuts.log"


## ----------------------------------------------------------------------------

# Function:     New-DM-Shortcut
# Purpose:      Creates a shortcut (LNK file)
# Usage:        New-DM-Shortcut

function Set-DM-HostnameBasedOnSerial ($Prefix) {
    $AssetID = ((Get-WmiObject Cim_Chassis).SerialNumber).replace("-", "").replace(".", "")
    $Name = "$Prefix-" + $AssetID.substring($assetid.length - 11, 11)

    if ((get-wmiobject cim_computersystem).name -ne $name)
    {
        Rename-Computer -NewName $Name -WhatIf
    }
}

## ----------------------------------------------------------------------------

## ----------------------------------------------------------------------------

function Get-DM-DeviceSerialNumber {
    return (Get-WmiObject Cim_Chassis).SerialNumber)
}