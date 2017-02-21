# Azure
This repository contains some Azure PowerShell scripts / snippets
## Script: New-AzurePublishSettingsFile.ps1
Creates an Azure publishettings file. Usage:
```powershell
.\New-AzurePublishSettingsFile.ps1 `
    -SubscriptionId 'yourSubscriptionId' `
    -SubscriptionName 'yourSubscriptionName' `
    -CertificateLocation 'Cert:\CurrentUser\My' `
    -CertificateThumbprint 'yourCertificateThumbprint' `
    -FilePath 'yourFileLocation'
```

## Script: New-ServicePrincipal.ps1
Creates an AAD application and service principal with contributor right to the specified subscription. 
This is used to authenticate a deployment application / script / CI-system instead of using a username / password login.
```powershell
.\New-ServicePrincipal.ps1 `
    -CertificatePassword 'yourCertificatePassword'
    -SubscriptionName 'yourSubscriptionName' 
```

## Snippet: Remove-EmptyAzureResourceGroups
Removes all resource groups for the current selected subscription that has no resources. 
```powershell
function Remove-EmptyAzureResourceGroups
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    Param ()
        
    $resourceGroups = Get-AzureRmResourceGroup -WarningAction SilentlyContinue
    $resources = Get-AzureRmResource
 
    $nonEmptyResourceGroups = $resourceGroups | foreach {
        $resources | ? ResourceGroupName -eq $_.ResourceGroupName | select -expand ResourceGroupName -Unique 
    }        
    $ResourceGroupsToDelete = $resourceGroups | where { $_.ResourceGroupName -notin $nonEmptyResourceGroups }
 
    $ResourceGroupsToDelete | foreach {
        if ($pscmdlet.ShouldProcess($_.ResourceGroupName, 'Remove-AzureRmResourceGroup'))
        {
            $_ | Remove-AzureRmResourceGroup -Confirm:$false
        }
    }   
}
```
## Snippet: Retrieve all application role assignment for a service principal


```powershell
Import-Module AzureAD
Connect-AzureAD
Get-AzureADServicePrincipal | ForEach-Object {
  $appRoles = @{ "$([Guid]::Empty.ToString())" = "(default)" }
  $_.AppRoles | % { $appRoles[$_.Id] = $_.DisplayName }

  # Get the app role assignments for this app, and add a field for the app role name
  Get-AzureADServiceAppRoleAssignment -ObjectId ($_.ObjectId) | % {
    $_ | Add-Member "AppRoleDisplayName" $appRoles[$_.Id] -Passthru
  }
} | Where PrincipalId -eq (Get-AzureADServicePrincipal -SearchString "myb2capp" | select -ExpandProperty ObjectId) | fl *
```

## Snippet: Create an aad application and service principal using a password

```powershell
Login-AzureRmAccount

$ApplicationName = "myapp"
$URI = "http://myapp.com"
$endDate = [System.DateTime]::Now.AddYears(2)

$bytes = New-Object Byte[] 32
$rand = [System.Security.Cryptography.RandomNumberGenerator]::Create()
$rand.GetBytes($bytes)
$ClientSecret = [System.Convert]::ToBase64String($bytes)

$aadApplication = New-AzureRmADApplication `
    -DisplayName $ApplicationName `
    -HomePage $URI `
    -IdentifierUris $URI `
    -Password $ClientSecret `
    -EndDate $endDate

New-AzureRmADServicePrincipal -ApplicationId $aadApplication.ApplicationId
```

## Snippet: Assign RBAC to a service principal:
```powershell
New-AzureRmRoleAssignment `
    -RoleDefinitionName Contributor `
    -ServicePrincipalName '<ApplicationId>' `
    -Scope '/subscriptions/<SubscriptionId>'
```
