 function Show-HelloWorld
 {
     Write-Host "hello, world!"
 }

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
