<#
.Synopsis
   Renames an Azure Storage Blob
.EXAMPLE
    Rename-AzureStorageBlob -Blob $myBlob -NewName "MyNewName"
#>
function Rename-AzureStorageBlob
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0)]
        [Microsoft.WindowsAzure.Commands.Common.Storage.ResourceModel.AzureStorageBlob]$Blob,

        [Parameter(Mandatory=$true, Position=1)]
        [string]$NewName
    )

  Process {     
    $blobCopyAction = Start-AzureStorageBlobCopy `
        -ICloudBlob $Blob.ICloudBlob `
        -DestBlob $NewName `
        -Context $Blob.Context `
        -DestContainer $Blob.ICloudBlob.Container.Name

    $status = $blobCopyAction | Get-AzureStorageBlobCopyState 

    while ($status.Status -eq 'Pending') 
    { 
        $status = $blobCopyAction | Get-AzureStorageBlobCopyState         
        Start-Sleep -Milliseconds 50
    }

    $Blob | Remove-AzureStorageBlob -Force 
  }
}
