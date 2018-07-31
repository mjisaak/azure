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

## Snippet: Rename an Azure Storage Blob using Rename-AzureStorageBlob.ps1:
In this example we remove the first three characters of the blob name using a simple regex:
```powershell
$storageAccount = '<Enter Storage Account Connection String>'
$containerName = '<Enter Storage Container Name>'
$storageContext = New-AzureStorageContext -ConnectionString $storageAccount

$containers = Get-AzureStorageContainer -Context $storageContext -Name $containerName
Get-AzureStorageBlob -Container $containers.Name -Context $storageContext | ForEach-Object {
    $_ | Rename-AzureStorageBlob -NewName ($_.Name -replace '^...')
}
```
## Snippet: Perform a sql query in PowerShell using a callback
```powershell
function Receive-SqlQuery
{
    Param
    (
        [string]$ConnectionString,
        [string]$SqlQuery,
        [scriptblock]$ResultProcessor
    )

    try
    {
        $sqlConnection = New-Object System.Data.SqlClient.SqlConnection $ConnectionString
        $sqlConnection.Open()

        try
        {
            $sqlCommand = New-Object System.Data.SqlClient.SqlCommand($SqlQuery, $sqlConnection)
            $reader = $sqlCommand.ExecuteReader()
            Invoke-Command $ResultProcessor -ArgumentList $reader
        }
        finally # cleanup reader
        {
            if ($reader)
            {
                $reader.Close()
            }
        }
    }
    finally
    {
        $sqlConnection.Close();
    }
}

# Invoke-Example:
 $readerCallback = {
        Param($reader)
        while ($reader.Read()) {
            [PsCustomObject]@{
                Id = $reader['id']
                ConnectionId = $reader['connectionid']
                ProfileId = $reader['profileid']
                Role = $reader['asrole']
            }
        }
    }

    $query =
@'
SELECT [id]
      ,[connectionid]
      ,[profileid]
      ,[asrole]
  FROM [dbo].[mytable]
'@
    Receive-SqlQuery -ConnectionString $cs -SqlQuery $query -ResultProcessor $readerCallback
```

## Snippet: Retrieve an access token using the client_credentials grant_type (service principal)
```powershell
function Get-AzureAdAccessTokenUsingClientCredentials
{
    Param
    (
        [Parameter(Mandatory=$true, Position=2)]
        [string]$Tenant,

        [Parameter(Mandatory=$true, Position=3)]
        [string]$ClientId,

        [Parameter(Mandatory=$true, Position=4)]
        [string]$ClientSecret
    )

    $body = @{
        grant_type = "client_credentials";
        resource = $clientId;
        client_id = $clientId;
        client_secret = $clientSecret;
    };

    $authorizationHeader = 'Basic {0}';
    $contentType = 'application/x-www-form-urlencoded';
    $absoluteUri = "https://login.microsoftonline.com/$Tenant/oauth2/token";

    $credentials = "$($clientId):$($clientSecret)";
    $encodedCredentials = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($credentials));
    $headers = @{ Authorization = $authorizationHeader -f $encodedCredentials};

    $result = Invoke-RestMethod -Uri $absoluteUri -Method Post -Body $body -Headers $headers -ContentType $contentType;
    $result.access_token
}
```
## Snippet: Retrieve an access token using the client_credentials grant_type (service principal)
```csharp
Within Azure Blob Storage you have only containers containing blobs, there are no subfolders.
You can use something like virtual folders by adding the subdirectory to the blob name. E. g.:

/container/myvirtualdir/myblob

And retrieve all blobs that also use the virtual folder using the prefix parameter:

var blobStorageAccount = GetStorageAccount();
var blobClient = blobStorageAccount.CreateCloudBlobClient();
var blobContainer = blobClient.GetContainerReference(containerName);
List<string> blobNames = blobContainer.ListBlobs(prefix: "myvirtualdir").OfType<CloudBlockBlob>().Select(b => b.Name).ToList();
```
