# Function: Get-DMUrlFromShortUrl
# Purpose:  Resolve full URL from short URL
# Usage:    $resolvedUrl = Get-DMUrlFromShortUrl -url "https://dm.wtf/test"
Function Get-DMUrlFromShortUrl ($url) {
    (((Invoke-WebRequest -UseBasicParsing –Uri $url).baseresponse).ResponseUri).AbsoluteUri
}

# ----------


# 
# Resources:
# SpeedTest.Net CLI: https://www.speedtest.net/apps/cli

function Start-DMSpeedTest {
    $path = $env:TEMP
    $DownloadURL = "https://install.speedtest.net/app/cli/ookla-speedtest-1.1.1-win64.zip"
    $DownloadPath = "$path\SpeedTest.Zip"
    $ExtractToPath = "$path\SpeedTest"
    $SpeedTestEXEPath = "$path\SpeedTest\speedtest.exe"
    $LogPath = '$path\SpeedTestLog.txt'

    #Start Logging to a Text File
    $ErrorActionPreference="SilentlyContinue"
    Stop-Transcript | out-null
    $ErrorActionPreference = "Continue"
    Start-Transcript -path $LogPath -Append:$false
    #check for and delete existing log files

    function Start-DMSpeedTestDotNet()
    {
        $test = & $SpeedTestEXEPath --accept-license
        return $test
    }

    #check if file exists
    if (Test-Path $SpeedTestEXEPath -PathType leaf)
    {
        Write-Host "SpeedTest EXE Exists, starting test" -ForegroundColor Green
        Start-DMSpeedTestDotNet
    }
    else
    {
        Write-Host "SpeedTest EXE Doesnt Exist, starting file download"

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
        Start-DMSpeedTestDotNet
    }

    #stop logging
    Stop-Transcript
    return $test
}