# Azure
This repository contains some Azure PowerShell scripts / snippets
## Scripts
###  New-AzurePublishSettingsFile
Creates an Azure publishettings file. Usage:
```
.\New-AzurePublishSettingsFile.ps1 `
    -SubscriptionId 'yourSubscriptionId' `
    -SubscriptionName 'yourSubscriptionName' `
    -CertificateLocation 'Cert:\CurrentUser\My' `
    -CertificateThumbprint 'yourCertificateThumbprint' `
    -FilePath 'yourFileLocation'
```
