### DanMundyPSFunctions: Network
### Version: 20220816T1226

## ----------------------------------------------------------------------------

# Function:     Start-DM-IPScan
# Purpose:      Scan current /24 network
# Usage:        Start-DM-IPScan

function Start-DM-IPScan {
    #Foreach all Class C:-Networks (/24)
    $(Get-NetIPAddress | where-object {$_.PrefixLength -eq "24"}).IPAddress | Where-Object {$_ -like "*.*"} | % { 
        $netip="$($([IPAddress]$_).GetAddressBytes()[0]).$($([IPAddress]$_).GetAddressBytes()[1]).$($([IPAddress]$_).GetAddressBytes()[2])"
        write-host "`n`nping C-Subnet $netip.1-254 ...`n"
        1..254 | % { 
            (New-Object System.Net.NetworkInformation.Ping).SendPingAsync("$netip.$_","1000") | Out-Null
        }
    }
    #wait until arp-cache: complete
    while ($(Get-NetNeighbor).state -eq "incomplete") {write-host "waiting";timeout 1 | out-null}
    #add the Hostname and present the result
    $Result = Get-NetNeighbor | Where-Object -Property state -ne Unreachable | where-object -property state -ne Permanent | select IPaddress,LinkLayerAddress,State, @{n="Hostname"; e={(Resolve-DnsName $_.IPaddress).NameHost}}
    if ($([System.Diagnostics.Process]::GetCurrentProcess().SessionId) -eq 0) {
        # Running in BackStage:
        $Result
    } Else {
        # Running in Regular User Session:
        $Result | Out-GridView
    }
}

## ----------------------------------------------------------------------------