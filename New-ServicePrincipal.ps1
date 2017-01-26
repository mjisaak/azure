<#
.Synopsis
   Creates an AAD application and service principal with contributor right to the specified subscription.
#>
 Param (
    [Parameter(Mandatory=$true)]
    [String] $CertificatePassword,

    [Parameter(Mandatory=$true)]
    [string] $SubscriptionName
 )

# variables
$applicationDisplayName = 'AzureDeploymentApplication'
$certificateMonthUntilExpired = 12

# login and select the subscription
Login-AzureRmAccount
Select-AzureRmSubscription -SubscriptionName $SubscriptionName

$currentDate = Get-Date
$endDate = $CurrentDate.AddMonths($certificateMonthUntilExpired)
$keyId = (New-Guid).Guid
$certificatePath = Join-Path $env:TEMP ($ApplicationDisplayName + ".pfx")

$certificate = New-SelfSignedCertificate -DnsName $ApplicationDisplayName -CertStoreLocation cert:\LocalMachine\My `
    -KeyExportPolicy Exportable -Provider "Microsoft Enhanced RSA and AES Cryptographic Provider"

$securedCertificatePassword = ConvertTo-SecureString $CertificatePassword -AsPlainText -Force
Export-PfxCertificate -Cert ("Cert:\localmachine\my\" + $certificate.Thumbprint) -FilePath $certificatePath -Password $securedCertificatePassword -Force | Write-Verbose

$pfxCertificate = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Certificate -ArgumentList @($certificatePath, $securedCertificatePassword)
$keyValue = [System.Convert]::ToBase64String($pfxCertificate.GetRawCertData())
$keyCredential = New-Object  Microsoft.Azure.Commands.Resources.Models.ActiveDirectory.PSADKeyCredential
$keyCredential.StartDate = $currentDate
$keyCredential.EndDate= $endDate
$keyCredential.KeyId = $keyId
$keyCredential.CertValue = $keyValue

$Application = New-AzureRmADApplication -DisplayName $ApplicationDisplayName `
    -HomePage ("http://" + $ApplicationDisplayName) -IdentifierUris ("http://" + $KeyId) -KeyCredentials $keyCredential

New-AzureRMADServicePrincipal -ApplicationId $Application.ApplicationId | Write-Verbose
Get-AzureRmADServicePrincipal | Where {$_.ApplicationId -eq $Application.ApplicationId} | Write-Verbose

$NewRole = $null
$Retries = 0;
While ($NewRole -eq $null -and $Retries -le 6)
{
    # Sleep here for a few seconds to allow the service principal application to become active (should only take a couple of seconds normally)
    Sleep 5
    New-AzureRMRoleAssignment -RoleDefinitionName Contributor -ServicePrincipalName $Application.ApplicationId | Write-Verbose -ErrorAction SilentlyContinue
    Sleep 10
    $NewRole = Get-AzureRMRoleAssignment -ServicePrincipalName $Application.ApplicationId -ErrorAction SilentlyContinue
    $Retries++;
}
$tenantId = Get-AzureRmSubscription -SubscriptionName $SubscriptionName | select -ExpandProperty TenantId

"Application successfully created. Use the snippet below to authenticate your script:"
"Add-AzureRmAccount -ServicePrincipal -TenantId {0} -ApplicationId {1} -CertificateThumbprint {2}" -f $tenantId, $Application.ApplicationId, $certificate.Thumbprint