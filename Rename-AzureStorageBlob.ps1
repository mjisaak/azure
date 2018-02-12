<#
.Synopsis
   Renames an Azure Storage Blob
.EXAMPLE
    Rename-AzureStorageBlob -Blob $myBlob -NewName "MyNewName" -StorageContext $storageContext
#>
function Rename-AzureStorageBlob
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0)]
        [Microsoft.WindowsAzure.Commands.Common.Storage.ResourceModel.AzureStorageBlob]$Blob,

        [Parameter(Mandatory=$true, Position=1)]
        [string]$NewName,

        [Parameter(Mandatory=$true, Position=2)]
        [Microsoft.WindowsAzure.Commands.Storage.AzureStorageContext]$StorageContext
    )

  Process {     
    $blobCopyAction = Start-AzureStorageBlobCopy `
        -ICloudBlob $Blob.ICloudBlob `
        -DestBlob $NewName `
        -Context $StorageContext `
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
