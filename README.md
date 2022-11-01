# Dan Mundy PowerShell Functions

## Download All in Zip File: Manual

[Download All in Zip File](https://dm.wtf/psf)

## Download All in Zip File: PowerShell

```
wget https://dm.wtf/psf -outFile dm.zip
Expand-Archive .\dm.zip . -Force
```

And if you get the message about TLS, then run this one:

```
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
```

## Download All in Zip File: Function

(mostly for when I'm making changes and re-downloading often)

```
function Get-DMPowerShellFunctions {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    wget https://dm.wtf/psf -outFile dm.zip
    Expand-Archive .\dm.zip . -Force
}
Get-DMPowerShellFunctions
```