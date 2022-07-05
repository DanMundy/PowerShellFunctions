#https://www.speedtest.net/apps/cli

$DownloadURL = "https://install.speedtest.net/app/cli/ookla-speedtest-1.1.1-win64.zip"
#location to save on the computer. Path must exist or it will error
$DownloadPath = "c:\C1\SpeedTest.Zip"
$ExtractToPath = "c:\C1\SpeedTest"
$SpeedTestEXEPath = "C:\C1\SpeedTest\speedtest.exe"
#Log File Path
$LogPath = 'c:\C1\SpeedTestLog.txt'

#Start Logging to a Text File
$ErrorActionPreference="SilentlyContinue"
Stop-Transcript | out-null
$ErrorActionPreference = "Continue"
Start-Transcript -path $LogPath -Append:$false
#check for and delete existing log files

function RunTest()
{
    $test = & $SpeedTestEXEPath --accept-license
    $test
}

#check if file exists
if (Test-Path $SpeedTestEXEPath -PathType leaf)
{
    Write-Host "SpeedTest EXE Exists, starting test" -ForegroundColor Green
    RunTest
}
else
{
    Write-Host "SpeedTest EXE Doesn't Exist, starting file download"

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
    RunTest
}

#stop logging
Stop-Transcript
exit 0