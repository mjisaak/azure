using System;
using System.IO;
using AzureStorageExamples.Options;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace AzureStorageExamples
{
    class Program
    {
        static void Main(string[] args)
        {
            var builder = new ConfigurationBuilder()
                .SetBasePath(Directory.GetCurrentDirectory())
                .AddJsonFile("appsettings.json", optional: true, reloadOnChange: true);

            builder.AddUserSecrets<Program>();
            var configuration = builder.Build();

            
            var services = new ServiceCollection();
            services
                .Configure<StorageAccount>(configuration.GetSection(nameof(StorageAccount)))
                .AddOptions()
                .AddSingleton<BlobStorage>();

            var serviceProvider = services.BuildServiceProvider();
            serviceProvider.GetService<BlobStorage>().RetrieveBlobsModifiedTodayAsync().GetAwaiter().GetResult();

            Console.ReadKey();

        }
    }
}
