$scriptblock = {
### DanMundyPSFunctions: Network
### Version: 20220816T1226

## ----------------------------------------------------------------------------

# Function:     Start-DMIPScan
# Purpose:      Scan current /24 network
# Usage:        Start-DMIPScan

function Start-DMIPScan {
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

## ----------------------------------------------------------------------------

# Function:     Get-PingSweep
# Purpose:      Scan current /24 network
# Not Mine

# Inspiration from https://twitter.com/mrhvid/status/929717169130176512 @mrhvid @Lee_Holmes

function ResolveIp($IpAddress) {
    try {
        (Resolve-DnsName $IpAddress -QuickTimeout -ErrorAction SilentlyContinue).NameHost
    } catch {
        $null
    }
}

function Get-PingSweep {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [string]$SubNet,
        [switch]$ResolveName
    )
    $ips = 1..254 | ForEach-Object {"$($SubNet).$_"}
    $ps = foreach ($ip in $ips) {
        (New-Object Net.NetworkInformation.Ping).SendPingAsync($ip, 250)
        #[Net.NetworkInformation.Ping]::New().SendPingAsync($ip, 250) # or if on PowerShell v5
    }
    [Threading.Tasks.Task]::WaitAll($ps)
    $ps.Result | Where-Object -FilterScript {$_.Status -eq 'Success' -and $_.Address -like "$subnet*"} |
    Select-Object Address,Status,RoundtripTime -Unique |
    ForEach-Object {
        if ($_.Status -eq 'Success') {
            if (!$ResolveName) {
                $_
            } else {
                $_ | Select-Object Address, @{Expression={ResolveIp($_.Address)};Label='Name'}, Status, RoundtripTime
            }
        }
    }
}

<#
Get-PingSweep -SubNet '10.56.161'
Address        Status RoundtripTime
-------        ------ -------------
10.56.161.1   Success             2
10.56.161.48  Success             0
10.56.161.49  Success             0
10.56.161.51  Success             0
10.56.161.52  Success             0
10.56.161.53  Success             0
10.56.161.54  Success             1

Get-PingSweep -SubNet '10.56.161' -ResolveName
Address       Name                          Status RoundtripTime
-------       ----                          ------ -------------
10.56.161.1   b86-bop12-sw18.contoso.com   Success             3
10.56.161.48  it-box1-dhwin7.contoso.com   Success             1
10.56.161.49  it-box2-dhwin10.contoso.com  Success             0
10.56.161.51  it-dept1-uh7yg2.contoso.com  Success             0
10.56.161.52  ds101sync.contoso.com        Success             0
10.56.161.53                               Success             1
10.56.161.54  it-ithd-12tr889.contoso.com  Success             1

(Measure-Command -Expression {Get-PingSweep -SubNet '10.56.161' -ResolveName}).Milliseconds
441
#>

## ----------------------------------------------------------------------------
}