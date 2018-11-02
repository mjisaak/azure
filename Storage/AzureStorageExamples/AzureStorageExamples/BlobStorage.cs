using System;
using System.Linq;
using System.Threading.Tasks;
using AzureStorageExamples.Options;
using Microsoft.Extensions.Options;
using Microsoft.WindowsAzure.Storage;
using Microsoft.WindowsAzure.Storage.Blob;

namespace AzureStorageExamples
{
    public sealed class BlobStorage
    {
        private readonly StorageAccount _storageAccount;
        private readonly CloudBlobClient _blobClient;

        public BlobStorage(IOptions<StorageAccount> storageAccount)
        {
            _storageAccount = storageAccount.Value;

            var account = CloudStorageAccount.Parse(storageAccount.Value.ConnectionString);
            _blobClient = account.CreateCloudBlobClient();
        }

        public async Task RetrieveBlobsModifiedTodayAsync()
        {
            var container = _blobClient.GetContainerReference(_storageAccount.ContainerName);

            BlobContinuationToken blobContinuationToken = null;
            do
            {
                var results = await container.ListBlobsSegmentedAsync(null, blobContinuationToken);

                var blobs = results.Results.OfType<CloudBlockBlob>()
                    .Where(b => b.Properties.LastModified != null && b.Properties.LastModified.Value.Date == DateTime.Today);

                blobContinuationToken = results.ContinuationToken;
                foreach (var item in blobs)
                {
                    Console.WriteLine(item.Uri);
                }
            } while (blobContinuationToken != null); // Loop while the continuation token is not null. 
        }

    }
}
