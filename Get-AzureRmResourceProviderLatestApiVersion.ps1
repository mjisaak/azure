<#
.Synopsis
   Gets the latest API version of a resource provider
.DESCRIPTION
   The following cmdlet returns the latest API version for the specified resource provider. 
   You can also include pre-release (preview) versions using the -IncludePreview switch
.EXAMPLE
   Get-AzureRmResourceProviderLatestApiVersion -Type Microsoft.Storage/storageAccounts
.EXAMPLE
   Get-AzureRmResourceProviderLatestApiVersion -Type Microsoft.Storage/storageAccounts -IncludePreview
#>
function Get-AzureRmResourceProviderLatestApiVersion
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([string])]
    Param
    (
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Type,

        [switch]$IncludePreview
    )

    # retrieving the resource providers is time consuming therefore we store
    # them in a script variable to accelerate subsequent requests.
    if (-not $script:resourceProvider) 
    {
         $script:resourceProvider = Get-AzureRmResourceProvider   
    }

    $provider = ($Type -replace "\/.*")
    $typeName = ($Type -replace ".*?\/(.+)", '$1')

      $provider = $script:resourceProvider | 
        Where-Object {
            $_.ProviderNamespace -eq $provider -and 
            $_.ResourceTypes.ResourceTypeName -eq $typeName
        }

    if ($IncludePreview) {
        $provider.ResourceTypes.ApiVersions[0]
    }
    else {
        $provider.ResourceTypes.ApiVersions | Where-Object {
                $_ -notmatch '-preview'
              } | Select-Object -First 1
    }
}