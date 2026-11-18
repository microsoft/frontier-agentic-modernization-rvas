using Azure.AI.OpenAI;
using Azure.Identity;
using Azure.Storage.Blobs;
using ContosoUniversity.Data;
using ContosoUniversity.Services;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.StaticFiles;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.FileProviders;
using Microsoft.Extensions.Hosting;
using System;
using System.IO;

var builder = WebApplication.CreateBuilder(args);

// Add MVC services
builder.Services.AddControllersWithViews();

// Add EF Core with SQL Server
builder.Services.AddDbContext<SchoolContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

// Add Azure Service Bus notification service
builder.Services.AddSingleton<NotificationService>(sp =>
    new NotificationService(builder.Configuration));

// Add Azure Blob Storage client
builder.Services.AddSingleton(sp =>
{
    var endpoint = builder.Configuration["AzureStorageBlob:Endpoint"];
    if (!string.IsNullOrEmpty(endpoint))
    {
        return new BlobServiceClient(new Uri(endpoint), new DefaultAzureCredential());
    }
    // Fallback for local development - return a placeholder client
    var connectionString = builder.Configuration["AzureStorageBlob:ConnectionString"] ?? "UseDevelopmentStorage=true";
    return new BlobServiceClient(connectionString);
});

// Add Azure OpenAI client + course-content AI service (Managed Identity).
// Service is null-safe: if AzureOpenAI:Endpoint is not set, AI suggestions are simply skipped.
builder.Services.AddSingleton<ICourseContentAiService>(sp =>
{
    var endpoint = builder.Configuration["AzureOpenAI:Endpoint"];
    var deployment = builder.Configuration["AzureOpenAI:Deployment"] ?? "gpt-4.1-mini";
    var logger = sp.GetRequiredService<Microsoft.Extensions.Logging.ILogger<CourseContentAiService>>();
    return new CourseContentAiService(endpoint, deployment, logger);
});

var app = builder.Build();

// Configure HTTP pipeline
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseStaticFiles();

// Serve static files from Content/ directory
var contentPath = Path.Combine(builder.Environment.ContentRootPath, "Content");
if (Directory.Exists(contentPath))
{
    app.UseStaticFiles(new StaticFileOptions
    {
        FileProvider = new PhysicalFileProvider(contentPath),
        RequestPath = "/Content"
    });
}

// Serve static files from Scripts/ directory
var scriptsPath = Path.Combine(builder.Environment.ContentRootPath, "Scripts");
if (Directory.Exists(scriptsPath))
{
    app.UseStaticFiles(new StaticFileOptions
    {
        FileProvider = new PhysicalFileProvider(scriptsPath),
        RequestPath = "/Scripts"
    });
}

app.UseRouting();
app.UseAuthorization();

// Initialize database
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<SchoolContext>();
    DbInitializer.Initialize(context);
}

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}");

app.Run();
