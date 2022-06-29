### DanMundyPSFunctions: Veeam
### Version: 20220629T1259

# Function: Function Get-DMVBRLastTapeWritten
# Purpose:  Shows which tape was last written to
Function Get-DMVBRLastTapeWritten {
    Add-PSSnapin VeeamPSSnapin
    $x=(get-date).adddays(-1)
    $lastTape=Get-VBRTapeMedium | where {$_.LastWriteTime -gt $x} | sort LastWriteTime | select -last 1
    Write-Host "Last tape written to was $lastTape"
}
Get-DMVBRLastTapeWritten