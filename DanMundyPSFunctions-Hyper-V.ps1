### DanMundyPSFunctions: Hyper-V
### Version: 20220629T1030

# Function: Get-DMVMsBySwitch
# Purpose: Show each VM and which Virtual Switch it's connected to
Function Get-DMVMsBySwitch {
    Get-VMNetworkAdapter -VMName (Get-VM).Name | Select VMName,SwitchName | Sort SwitchName,VMName
}