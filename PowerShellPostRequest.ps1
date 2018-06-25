$myBody = @{
    "myBodyProperty" = "myValue"
}

$headers = @{
    "Content-Type" = "application/json-patch+json"
    "Accept" = "application/json"
}

$route = 'https://myapi.azurewebsites.net/api/Route'

Invoke-WebRequest `
    -Uri $route `
    -Body ([System.Text.Encoding]::UTF8.GetBytes(($myBody| ConvertTo-Json))) `
    -Headers $headers `
    -Method Post
