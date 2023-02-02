### DanMundyPSFunctions: Windows
### Version: 20220721T2304

## Glue Functions

function Check-DMIsElevated

 {
    $id = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $p = New-Object System.Security.Principal.WindowsPrincipal($id)
    if ($p.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator))
   { Write-Output $true }      
    else
   { Write-Output $false }   
 }

 # Use like this: if (-not(Check-IsElevated)) { throw "Please run this script as an administrator" }

## ----------------------------------------------------------------------------

# Function:     Get-DMLastBootTime
# Purpose:      Show when Windows was booted
# Usage:        Get-DMLastBootTime

function Get-DMLastBootTime {
    Get-WmiObject win32_operatingsystem | select csname, @{LABEL='LastBootUpTime';EXPRESSION={$_.ConverttoDateTime($_.lastbootuptime)}}
}

function Get-DMRebootHistory {
    Get-WmiObject Win32_NTLogEvent -filter "LogFile='System' and EventCode=6005" | Select ComputerName, EventCode, @{LABEL='TimeWritten';EXPRESSION={$_.ConverttoDateTime($_.TimeWritten)}}
}

## ----------------------------------------------------------------------------

# Function:     Get-DMInstalledPrograms
# Purpose:      Show applications installed
# Usage:        Get-DMInstalledPrograms

function Get-DMInstalledPrograms {
    Get-WmiObject -Class Win32_Product | ft Name,Vendor,Version
}

## ----------------------------------------------------------------------------

# Function: Get-DMInstallFeatureUpdate
# Purpose:  
# Usage:    Get-DMLastBootTime
# Sources:  https://dm.wtf/IXTU

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

# Function:     New-DMShortcut
# Purpose:      Creates a shortcut (LNK file)
# Usage:        New-DMShortcut

function New-DMShortcut ($TargetFile,$ShortcutFile) {
    $WScriptShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WScriptShell.CreateShortcut($ShortcutFile)
    $Shortcut.TargetPath = $TargetFile
    $Shortcut.Save()
}

## ----------------------------------------------------------------------------

# Function:     New-DMOfficeShortcuts
# Purpose:      Creates desktop shortcuts for the Office Apps
# Usage:        New-DMOfficeShortcuts -LogFile "C:\Temp\New-Object-Desktop-Shortcuts.log"
# Depends on:   New-DMShortcut (in this file)

function New-DMOfficeShortcuts ($LogFile) {
    #Start logging PS script for troubleshooting.
    Start-Transcript -Path $LogFile

    #Create Microsoft Office public deskop shortcuts.
    New-DMShortcut -TargetFile "C:\Program Files\Microsoft Office\root\Office16\MSACCESS.EXE" -ShortcutFile "C:\Users\Public\Desktop\Access.lnk"
    New-DMShortcut -TargetFile "C:\Program Files\Microsoft Office\root\Office16\EXCEL.EXE" -ShortcutFile "C:\Users\Public\Desktop\Excel.lnk"
    New-DMShortcut -TargetFile "C:\Program Files\Microsoft Office\root\Office16\OUTLOOK.EXE" -ShortcutFile "C:\Users\Public\Desktop\Outlook.lnk"
    New-DMShortcut -TargetFile "C:\Program Files\Microsoft Office\root\Office16\POWERPNT.EXE" -ShortcutFile "C:\Users\Public\Desktop\PowerPoint.lnk"
    New-DMShortcut -TargetFile "C:\Program Files\Microsoft Office\root\Office16\MSPUB.EXE" -ShortcutFile "C:\Users\Public\Desktop\Publisher.lnk"
    New-DMShortcut -TargetFile "C:\Program Files\Microsoft Office\root\Office16\WINWORD.EXE" -ShortcutFile "C:\Users\Public\Desktop\Word.lnk"

    #Create Microsoft Internet Exporer public desktop shortcut.
    #New-DMShortcut -TargetFile "C:\Program Files\Internet Explorer\iexplore.exe" -ShortcutFile "C:\Users\Public\Desktop\Internet Explorer.lnk"

    #Create Google Chrome desktop shortcut.
    #New-DMShortcut -TargetFile "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" -ShortcutFile "C:\Users\Public\Desktop\Google Chrome.lnk"

    #Stop logging PS script for troubleshooting.
    Stop-Transcript
}
# New-DMOfficeShortcuts -LogFile "$env:Temp\New-Object-Desktop-Shortcuts.log"


## ----------------------------------------------------------------------------

# Function:     New-DMShortcut
# Purpose:      Creates a shortcut (LNK file)
# Usage:        New-DMShortcut

function Set-DMHostnameBasedOnSerial ($Prefix) {
    $AssetID = ((Get-WmiObject Cim_Chassis).SerialNumber).replace("-", "").replace(".", "")
    $Name = "$Prefix-" + $AssetID.substring($assetid.length - 11, 11)

    if ((get-wmiobject cim_computersystem).name -ne $name)
    {
        Rename-Computer -NewName $Name -WhatIf
    }
}

## ----------------------------------------------------------------------------

## ----------------------------------------------------------------------------

function Get-DMDeviceSerialNumber {
    return (Get-WmiObject Cim_Chassis).SerialNumber)
    # Note you can also use: (Get-WmiObject Cim_Chassis).SerialNumber
    # (but it takes a little longer to process)
}

## ----------------------------------------------------------------------------

Function Get-DMWindowsVersion {
    Get-ComputerInfo | select WindowsProductName, WindowsVersion
    [System.Environment]::OSVersion.Version
}


##
# Purpose: List User Profiles and the Last Time They Were Used
# Requirements: Must run as admin

function Get-DMUserProfileLastUseTime {
    if (-not(Check-DMIsElevated)) { throw "Please run this script as an administrator" }
    Get-WMIObject -class Win32_UserProfile | sort-object -Property LastUseTime |  ft LocalPath, LastUseTime
}