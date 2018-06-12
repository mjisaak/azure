<#
.Synopsis
   Gets the latest API version of a resource provider
.DESCRIPTION
   The following cmdlet returns the latest API version for the specified resource provider. 
   You can also include pre-release (preview) versions using the -IncludePreview switch
.EXAMPLE
   Using the Full Parameter Set:
   Get-AzureRmResourceProviderLatestApiVersion -Type Microsoft.Storage/storageAccounts
.EXAMPLE
   Using the Full Parameter Set with the -IncludePreview switch:
   Get-AzureRmResourceProviderLatestApiVersion -Type Microsoft.Storage/storageAccounts -IncludePreview
.EXAMPLE
   Using the ProviderAndType Parameter Set:
   Get-AzureRmResourceProviderLatestApiVersion -ResourceProvider Microsoft.Storage -ResourceType storageAccounts
#>
function Get-AzureRmResourceProviderLatestApiVersion {
    [CmdletBinding()]
    [Alias()]
    [OutputType([string])]
    Param
    (
        [Parameter(ParameterSetName = 'Full', Mandatory = $true, Position = 0)]
        [string]$Type,

        [Parameter(ParameterSetName = 'ProviderAndType', Mandatory = $true, Position = 0)]
        [string]$ResourceProvider,

        [Parameter(ParameterSetName = 'ProviderAndType', Mandatory = $true, Position = 1)]
        [string]$ResourceType,

        [switch]$IncludePreview
    )

    # retrieving the resource providers is time consuming therefore we store
    # them in a script variable to accelerate subsequent requests.
    if (-not $script:resourceProvider) {
        $script:resourceProvider = Get-AzureRmResourceProvider   
    }

    if ($PSCmdlet.ParameterSetName -eq 'Full') {
        $ResourceProvider = ($Type -replace "\/.*")
        $ResourceType = ($Type -replace ".*?\/(.+)", '$1')
    }
    
    $provider = $script:resourceProvider | 
        Where-Object {
        $_.ProviderNamespace -eq $ResourceProvider -and 
        $_.ResourceTypes.ResourceTypeName -eq $ResourceType
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