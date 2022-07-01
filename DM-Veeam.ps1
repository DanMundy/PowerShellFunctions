### DanMundyPSFunctions: Veeam
### Version: 20220629T1259

### ----------

# Function: Function Get-DMVBRLastTapeWritten
# Purpose:  Shows which tape was last written to
# Usage eg: Get-DMVBRLastTapeWritten
#           $LastTapeBarcode = (Get-DMVBRLastTapeWritten).Barcode
Function Get-DMVBRLastTapeWritten {
    Add-PSSnapin VeeamPSSnapin
    $x=(get-date).adddays(-1)
    $lastTape=Get-VBRTapeMedium | where {$_.LastWriteTime -gt $x} | sort LastWriteTime | select -last 1
    return $lastTape
}

### ----------

# Function: Move-DM-ExpiredTapesToFreePool
# Purpose:  Move any expired tapes to the free media pool
# (req because otherwise Veeam won't use (eg) a free tape that was previously marked as daily, if the next backup would be marked as weekly.
# I believe this behaviour is expected to change in a future version of Veeam, and this workaround would no longer be required) 
# Usage: Move-DM-ExpiredTapesToFreePool
function Move-DM-ExpiredTapesToFreePool {
    Add-PSSnapin VeeamPSSnapin
    $UnrecognizedMediaPool = Get-VBRTapeMediaPool -name "Unrecognized"
    $FreeMediaPool = Get-VBRTapeMediaPool -name "Free"
    $TapesToMoveToFreePool = $null
    $TapesToMoveToFreePool = Get-VBRTapeMedium | Where { ($_.Barcode -ne "CLNU00L1") -and ($_.ProtectedByHardware -ne $true) -and ($_.ProtectedBySoftware -ne $true) -and ($_.IsFree -eq $true -or $_.IsExpired -eq $true) -and ($_.MediaPoolId -ne $($FreeMediaPool.Id)) -and ($_.MediaPoolId -ne $($UnrecognizedMediaPool.Id)) -and ($_.Location.Type -ne "None")}
    $FirstTapeToMoveToFreePool = Get-VBRTapeMedium | Where { ($_.Barcode -ne "CLNU00L1") -and ($_.ProtectedByHardware -ne $true) -and ($_.ProtectedBySoftware -ne $true) -and ($_.IsFree -eq $true -or $_.IsExpired -eq $true) -and ($_.MediaPoolId -ne $($FreeMediaPool.Id)) -and ($_.MediaPoolId -ne $($UnrecognizedMediaPool.Id)) -and ($_.Location.Type -ne "None")} | Sort-Object -Property ExpirationDate | Select-Object -First 1
    Write-Host "First ="
    Write-Host $FirstTapeToMoveToFreePool

    If ($TapesToMoveToFreePool -ne $null) {
        Write-Host ""
        Write-Host "Following tapes will be added to free pool:"
        #$TapesToMoveToFreePool | ft Barcode,ExpirationDate,IsFree,IsExpired,MediaSet
        #Write-Host ""
        #foreach ($Tape in $TapesToMoveToFreePool)
        #{
        #    Write-Host "Processing tape: " $Tape
        #    Move-VBRTapeMedium -Medium $Tape -MediaPool "Free" -Confirm:$false
        #}
        $FirstTapeToMoveToFreePool | ft Barcode,ExpirationDate,IsFree,IsExpired,MediaSet
        Move-VBRTapeMedium -Medium $FirstTapeToMoveToFreePool -MediaPool "Free" -Confirm:$false

    }
}

### ----------

# Function: Import-DMs-TapeFromIoSlot
# Purpose:  Import a new tape,
#           but only on a Mon-Fri (when staff are likely to have changed it)
#           and only if the autoloader has room for it (ie prevent them overloading it, if there's also a tape still in the drive)
# Usage:    Import-DMs-TapeFromIoSlot 8
#           (assuming 8 is the max tapes you can put in the autoloader)
function Import-DMs-TapeFromIoSlot($maxTapes) {
    Add-PSSnapin VeeamPSSnapin
    $Day = (Get-Date).DayOfWeek
    #If ($JobStartedOn -eq "Monday" -or $Day -eq "Tuesday" -or $Day -eq "Wednesday" -or $Day -eq "Thursday" -or $Day -eq "Friday") {
    If ($Day -eq "Monday" -or $Day -eq "Tuesday" -or $Day -eq "Wednesday" -or $Day -eq "Thursday" -or $Day -eq "Friday") {
        $TapesInserted = (Get-VBRTapeMedium | where {$_.Location -NotLike "None"}).Count
        If ($TapesInserted -ne $maxTapes) {
            Get-VBRTapeLibrary | Import-VBRTapeMedium
        }
    }
}

### ----------


# Usable Tapes:
# Function: Get-DMVBRWriteableTapes
# Purpose:  List all tapes that are available to be written to
# Usage:    Get-DMVBRWriteableTapes | ft Barcode,Location
function Get-DMVBRWriteableTapes {
    Add-PSSnapin VeeamPSSnapin
    $UnrecognizedMediaPool = Get-VBRTapeMediaPool -name "Unrecognized"
    return Get-VBRTapeMedium |
    Where {($_.IsFree -eq $true) -or
        ($_.IsExpired -eq $true) -and
        ($_.MediaPoolId -ne $($UnrecognizedMediaPool.Id)) -and
        ($_.ProtectedByHardware -ne $true) -and
        ($_.ProtectedBySoftware -ne $true)
    } | Sort-Object -Property @{Expression = {$_.IsFree}; Ascending = $false}, ExpirationDate,Barcode
}

# Not Yet Usable Tapes:
# Usage: Get-DMVBRNotWriteableTapes | ft Barcode,MediaSet,ExpirationDate
function Get-DMVBRNotWriteableTapes {
    Add-PSSnapin VeeamPSSnapin
    $UnrecognizedMediaPool = Get-VBRTapeMediaPool -name "Unrecognized"
    return Get-VBRTapeMedium |
    Where {($_.IsFree -eq $false) -and
        ($_.IsExpired -eq $false) -and
        ($_.MediaPoolId -ne $($UnrecognizedMediaPool.Id)) -and
        ($_.ProtectedByHardware -ne $true) -and
        ($_.ProtectedBySoftware -ne $true)
    } | Sort-Object -Property @{Expression = {$_.IsFree}; Ascending = $false}, ExpirationDate,Barcode
}