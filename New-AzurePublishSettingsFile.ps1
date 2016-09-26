<#
.Synopsis
   Creates an Azure publishettings file.
.DESCRIPTION
   You must save the certificate to the current user store WITH the private key in order to use it with Import-AzurePublishSettingsFile cmdlet! 
#>
Param(
    $SubscriptionId,
    $SubscriptionName,
    $CertificateLocation,
    $CertificateThumbprint,
    $ServiceManagementUrl = "https://management.core.cloudapi.de",
    $FilePath
)

$certToUpload = Get-ChildItem $CertificateLocation | Where-Object Thumbprint -eq $CertificateThumbprint
  
$publicKey = [System.Convert]::ToBase64String($certToUpload.GetPublicKey()) 
$certificateData = [System.Convert]::ToBase64String($certToUpload.RawData)

$publishSettingsXml = 
@'
<?xml version="1.0" encoding="utf-8"?>
<PublishData>
  <PublishProfile
    SchemaVersion="2.0"
    PublishMethod="AzureServiceManagementAPI">
    <Subscription
      ServiceManagementUrl="$ServiceManagementUrl"
      Id="$SubscriptionId"
      Name="$SubscriptionName"
      ManagementCertificate="$certificateData" />
  </PublishProfile>
</PublishData>
'@

$ExecutionContext.InvokeCommand.ExpandString($publishSettingsXml) | Out-File -FilePath $FilePath
