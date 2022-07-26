# Dan Mundy PowerShell Functions

[Download All in Zip File](https://dm.wtf/psf)

    function Get-DMPowerShellFunctions {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        wget https://dm.wtf/psf -outFile dm.zip
        Expand-Archive .\dm.zip . -Force
    }
    Get-DMPowerShellFunctions