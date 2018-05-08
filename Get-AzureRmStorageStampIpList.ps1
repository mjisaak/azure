Param
(
    [Parameter(Mandatory=$true, Position=0)]
    $ResourceGroupName
)
Get-AzureRmStorageAccount -ResourceGroupName $resourceGroupName | ForEach-Object {
    [PSCustomObject]@{
        StorageAccount = $_.StorageAccountName
        IPAddress = [System.Net.Dns]::GetHostAddresses((([Uri]$_.PrimaryEndpoints.Blob).Host)).IPAddressToString
    }
}