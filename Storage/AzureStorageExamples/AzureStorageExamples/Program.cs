using System;
using System.IO;
using Microsoft.Extensions.Configuration;

namespace AzureStorageExamples
{
    class Program
    {
        static void Main(string[] args)
        {
            var builder = new ConfigurationBuilder()
                .SetBasePath(Directory.GetCurrentDirectory())
                .AddJsonFile("appsettings.json", optional: true, reloadOnChange: true);

            var configuration = builder.Build();

            Console.WriteLine(configuration.GetConnectionString("Storage"));
        }
    }
}
