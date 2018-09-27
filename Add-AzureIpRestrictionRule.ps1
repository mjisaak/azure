<#
.Synopsis
  Adds an Azure Ip restriction rule to an Azure App Service.
.EXAMPLE
  Add-AzureIpRestrictionRule -ResourceGroupName $ResourceGroupName -AppServiceName $AppServiceName -rule $rule
#>
function Add-AzureIpRestrictionRule
{
    [CmdletBinding()]
    Param
    (
        # Name of the resource group that contains the App Service.
        [Parameter(Mandatory=$true, Position=0)]
        $ResourceGroupName, 

        # Name of your Web or API App.
        [Parameter(Mandatory=$true, Position=1)]
        $AppServiceName, 

        # rule to add.
        [Parameter(Mandatory=$true, Position=2)]
        [PSCustomObject]$rule 
    )

    $ApiVersions = Get-AzureRmResourceProvider -ProviderNamespace Microsoft.Web | 
        Select-Object -ExpandProperty ResourceTypes |
        Where-Object ResourceTypeName -eq 'sites' |
        Select-Object -ExpandProperty ApiVersions

    $LatestApiVersion = $ApiVersions[0]

    $WebAppConfig = Get-AzureRmResource -ResourceType 'Microsoft.Web/sites/config' -ResourceName $AppServiceName -ResourceGroupName $ResourceGroupName -ApiVersion $LatestApiVersion

    $WebAppConfig.Properties.ipSecurityRestrictions =  $WebAppConfig.Properties.ipSecurityRestrictions + @($rule) | 
        Group-Object name | 
        ForEach-Object { $_.Group | Select-Object -Last 1 }

    Set-AzureRmResource -ResourceId $WebAppConfig.ResourceId -Properties $WebAppConfig.Properties -ApiVersion $LatestApiVersion -Force    
}

############################################################
$SubscriptionId = '' 
$AppServiceName = ''
$ResourceGroupName = ''


Disable-AzureRmContextAutosave -Scope Process | out-null
$ctxPath = Join-Path $env:APPDATA 'azure.ctx'

if (-not (Test-Path $ctxPath))
{
    Login-AzureRmAccount
    Save-AzureRmContext -Path $ctxPath -Force
}
 
Import-AzureRmContext -Path $ctxPath | out-null
Set-AzureRmContext -SubscriptionId $SubscriptionId | Out-Null


$clientIp = Invoke-WebRequest 'https://api.ipify.org' | Select-Object -ExpandProperty Content

$rule = [PSCustomObject]@{
    ipAddress = "$($clientIp)/32"
    action = "Allow"  
    priority = 123 
    name = '{0}_{1}' -f $env:computername, $env:USERNAME 
    description = "Automatically added ip restriction"
}

Add-AzureIpRestrictionRule -ResourceGroupName $ResourceGroupName -AppServiceName $AppServiceName -rule $rule