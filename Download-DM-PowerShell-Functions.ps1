function Get-DMPowerShellFunctions {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    wget https://dan.srl/psf -outFile dm.zip
    Expand-Archive .\dm.zip . -Force
}
Get-DMPowerShellFunctions