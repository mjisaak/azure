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
