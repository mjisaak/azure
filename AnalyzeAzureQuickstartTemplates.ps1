# dot source the cmdlet we need to analyze the templates
. ".\Get-AzureRmResourceProviderLatestApiVersion.ps1"
. ".\Get-OutdatedResourceProvider.ps1"

git clone https://github.com/Azure/azure-quickstart-templates.git
$quickstartTempaltePath = "D:\temp\azure-quickstart-templates-master"
$invalidTemplates = @()

$armTemplates = Get-ChildItem $quickstartTempaltePath -Filter 'azuredeploy.json' -Recurse

$analyzedTemplates = $armTemplates |
    ForEach-Object {
    $template = $_
    try
    {
        $null = $template | Get-Content | ConvertFrom-Json
        Get-OutdatedResourceProvider -Path $template.FullName
    }
    catch
    {
        $invalidTemplates += $template
    }
}

$validAnalyzes = $analyzedTemplates | Where-Object LatestVersion
$uptodateproviderCount = $validAnalyzes | Where-Object LatestVersion -eq TRUE | Measure-Object | Select-Object -ExpandProperty Count
$outdatedproviderCount = $validAnalyzes | Where-Object LatestVersion -ne TRUE | Measure-Object | Select-Object -ExpandProperty Count

Write-Host "Found $($armTemplates.Count) ARM templates in the azure quickstart repository ($($invalidTemplates.Count) of them are invalid). They are using $($analyzedTemplates.Count) resource providers. I was able to determine the latest version for $($validAnalyzes.count) resource provider. $uptodateproviderCount of them are using the latest API version whereas $outdatedproviderCount are using an outdated API." -ForegroundColor Cyan
