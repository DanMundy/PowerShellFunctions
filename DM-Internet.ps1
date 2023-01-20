## ----------------------------------------------------------------------------

# Function: Get-DMUrlFromShortUrl
# Purpose:  Resolve full URL from short URL
# Usage:    $resolvedUrl = Get-DMUrlFromShortUrl -url "https://dm.wtf/test"
function Get-DMUrlFromShortUrl ($url) {
    return (((Invoke-WebRequest -UseBasicParsing -Uri $url).baseresponse).ResponseUri).AbsoluteUri
}

## ----------------------------------------------------------------------------

# 
# Resources:
#     SpeedTest.Net CLI: https://www.speedtest.net/apps/cli

function Start-DMSpeedTest {
    $path = $env:TEMP
    $DownloadURL = "https://install.speedtest.net/app/cli/ookla-speedtest-1.1.1-win64.zip"
    $DownloadPath = "$path\SpeedTest.Zip"
    $ExtractToPath = "$path\SpeedTest"
    $SpeedTestEXEPath = "$path\SpeedTest\speedtest.exe"

    #check if file exists
    if (Test-Path $SpeedTestEXEPath -PathType leaf)
    {
        Write-Host "SpeedTest EXE exists"
    }
    else
    {
        Write-Host "SpeedTest EXE does not exist, starting file download"

        #downloads the file from the URL
        wget $DownloadURL -outfile $DownloadPath

        #Unzip the file
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        function Unzip
        {
            param([string]$zipfile, [string]$outpath)

            [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
        }
        Unzip $DownloadPath $ExtractToPath
    }
    Write-Host "Starting test" -ForegroundColor Green
    $test = & $SpeedTestEXEPath --accept-license
    return $test
}

function Get-DMWiredNetworkAdapters {
    $NetworkAdapters = Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter "IPEnabled='TRUE'" | Where-Object { ($_.Description -notlike "*VMware*") -and ($_.Description -notlike "*Wireless*")}
    $NetworkAdapters | ft IPAddress,Description
}

## ----------------------------------------------------------------------------

function Download-DMPSFunction ($name) {
    $file = "$name.ps1"
    if (Test-Path .\$file) { Remove-Item .\$file }
    Invoke-WebRequest "https://raw.githubusercontent.com/DanMundy/PowerShellFunctions/main/$file" -OutFile .\$file
    # wget https://dm.wtf/psf
}

## ----------------------------------------------------------------------------

