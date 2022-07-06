# Dan Mundy PowerShell Functions

[Download All in Zip File](https://dm.wtf/psf)

    function Get-DMPowerShellFunctions {
        wget https://dm.wtf/psf -outFile dm.zip
        Expand-Archive .\dm.zip . -Force
    }
    Get-DMPowerShellFunctions