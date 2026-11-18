using System.Net.Mime;
using Ardalis.ListStartupServices;
using Azure.Identity;
using Microsoft.Azure.StackExchangeRedis;
using StackExchange.Redis;
using BlazorAdmin;
using BlazorAdmin.Services;
using Blazored.LocalStorage;
using BlazorShared;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.DataProtection;
using Microsoft.AspNetCore.Diagnostics.HealthChecks;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc.ApplicationModels;
using Microsoft.EntityFrameworkCore;
using Microsoft.eShopWeb;
using Microsoft.eShopWeb.ApplicationCore.Interfaces;
using Microsoft.eShopWeb.Infrastructure.Data;
using Microsoft.eShopWeb.Infrastructure.Identity;
using Microsoft.eShopWeb.Web;
using Microsoft.eShopWeb.Web.Configuration;
using Microsoft.eShopWeb.Web.HealthChecks;
using Microsoft.Extensions.Diagnostics.HealthChecks;

var builder = WebApplication.CreateBuilder(args);
builder.Logging.AddConsole();

// Load Azure Key Vault secrets when AZURE_KEY_VAULT_ENDPOINT is set (works across all environments)
var keyVaultEndpoint = builder.Configuration["AZURE_KEY_VAULT_ENDPOINT"];
if (!string.IsNullOrEmpty(keyVaultEndpoint))
{
    var credential = new DefaultAzureCredential();
    builder.Configuration.AddAzureKeyVault(new Uri(keyVaultEndpoint), credential);

    var appConfigEndpointEarly = builder.Configuration["AZURE_APP_CONFIGURATION_ENDPOINT"];
    if (!string.IsNullOrEmpty(appConfigEndpointEarly))
    {
        builder.Configuration.AddAzureAppConfiguration(options =>
            options.Connect(new Uri(appConfigEndpointEarly), credential)
                   .UseFeatureFlags());
    }
}

if (builder.Environment.IsDevelopment() || builder.Environment.EnvironmentName == "Docker")
{
    // Configure SQL Server (local)
    Microsoft.eShopWeb.Infrastructure.Dependencies.ConfigureServices(builder.Configuration, builder.Services);
}
else
{
    // Configure SQL Server (prod) — Key Vault and App Configuration already wired above
    var credential = new DefaultAzureCredential();

    if (string.IsNullOrEmpty(keyVaultEndpoint))
    {
        // Fallback: if Key Vault was not configured at the top, wire it now for prod
        var prodKvEndpoint = builder.Configuration["AZURE_KEY_VAULT_ENDPOINT"] ?? "";
        if (!string.IsNullOrEmpty(prodKvEndpoint))
            builder.Configuration.AddAzureKeyVault(new Uri(prodKvEndpoint), credential);

        var appConfigEndpoint = builder.Configuration["AZURE_APP_CONFIGURATION_ENDPOINT"];
        if (!string.IsNullOrEmpty(appConfigEndpoint))
        {
            builder.Configuration.AddAzureAppConfiguration(options =>
                options.Connect(new Uri(appConfigEndpoint), credential)
                       .UseFeatureFlags());
        }
    }

    var catalogConnectionString = builder.Configuration.GetConnectionString("CatalogConnection")
        ?? throw new InvalidOperationException(
            "Connection string 'CatalogConnection' is required. Set ConnectionStrings__CatalogConnection.");
    var identityConnectionString = builder.Configuration.GetConnectionString("IdentityConnection")
        ?? throw new InvalidOperationException(
            "Connection string 'IdentityConnection' is required. Set ConnectionStrings__IdentityConnection.");

    builder.Services.AddDbContext<CatalogContext>(c =>
        c.UseSqlServer(catalogConnectionString, sqlOptions => sqlOptions.EnableRetryOnFailure()));
    builder.Services.AddDbContext<AppIdentityDbContext>(options =>
        options.UseSqlServer(identityConnectionString, sqlOptions => sqlOptions.EnableRetryOnFailure()));
}

builder.Services.AddCookieSettings();

builder.Services.AddAuthentication(CookieAuthenticationDefaults.AuthenticationScheme)
    .AddCookie(options =>
    {
        options.Cookie.HttpOnly = true;
        options.Cookie.SecurePolicy = CookieSecurePolicy.Always;
        options.Cookie.SameSite = SameSiteMode.Lax;
    });

builder.Services.AddIdentity<ApplicationUser, IdentityRole>()
           .AddDefaultUI()
           .AddEntityFrameworkStores<AppIdentityDbContext>()
                           .AddDefaultTokenProviders();

builder.Services.AddScoped<ITokenClaimsService, IdentityTokenClaimService>();
builder.Configuration.AddEnvironmentVariables();
builder.Services.AddCoreServices(builder.Configuration);
builder.Services.AddWebServices(builder.Configuration);

// Add distributed cache: Azure Cache for Redis (Managed Identity) in production, in-memory for local development
var redisHostName = builder.Configuration["Redis:HostName"];
if (!string.IsNullOrEmpty(redisHostName))
{
    var redisPort = builder.Configuration.GetValue<int?>("Redis:Port") ?? 10000;
    var configurationOptions = await ConfigurationOptions
        .Parse($"{redisHostName}:{redisPort}")
        .ConfigureForAzureAsync(new AzureCacheOptions
        {
            TokenCredential = new DefaultAzureCredential()
        });
    configurationOptions.AbortOnConnectFail = false;
    var redisConnection = await ConnectionMultiplexer.ConnectAsync(configurationOptions);

    builder.Services.AddStackExchangeRedisCache(options =>
    {
        options.ConnectionMultiplexerFactory =
            () => Task.FromResult<IConnectionMultiplexer>(redisConnection);
        options.InstanceName = "eShopWeb:";
    });
    builder.Services.AddDataProtection()
        .SetApplicationName("eShopOnWeb")
        .PersistKeysToStackExchangeRedis(redisConnection, "eShopOnWeb-DataProtection-Keys");
}
else
{
    builder.Services.AddDistributedMemoryCache();
}
builder.Services.AddHttpClient("healthcheck")
    .ConfigurePrimaryHttpMessageHandler(() => new HttpClientHandler
    {
        ServerCertificateCustomValidationCallback = HttpClientHandler.DangerousAcceptAnyServerCertificateValidator
    });

builder.Services.AddRouting(options =>
{
    // Replace the type and the name used to refer to it with your own
    // IOutboundParameterTransformer implementation
    options.ConstraintMap["slugify"] = typeof(SlugifyParameterTransformer);
});

builder.Services.AddMvc(options =>
{
    options.Conventions.Add(new RouteTokenTransformerConvention(
             new SlugifyParameterTransformer()));

});
builder.Services.AddControllersWithViews();
builder.Services.AddRazorPages(options =>
{
    options.Conventions.AuthorizePage("/Basket/Checkout");
});
builder.Services.AddHttpContextAccessor();
builder.Services
    .AddHealthChecks()
    .AddCheck<ApiHealthCheck>("api_health_check", tags: new[] { "apiHealthCheck" })
    .AddCheck<HomePageHealthCheck>("home_page_health_check", tags: new[] { "homePageHealthCheck" });
builder.Services.Configure<ServiceConfig>(config =>
{
    config.Services = new List<ServiceDescriptor>(builder.Services);
    config.Path = "/allservices";
});

// blazor configuration
var configSection = builder.Configuration.GetRequiredSection(BaseUrlConfiguration.CONFIG_NAME);
builder.Services.Configure<BaseUrlConfiguration>(configSection);
var baseUrlConfig = configSection.Get<BaseUrlConfiguration>();

// Blazor Admin Required Services for Prerendering
builder.Services.AddScoped<HttpClient>(s => new HttpClient
{
    BaseAddress = new Uri(baseUrlConfig!.WebBase)
});

// add blazor services
builder.Services.AddBlazoredLocalStorage();
builder.Services.AddServerSideBlazor();
builder.Services.AddScoped<ToastService>();
builder.Services.AddScoped<HttpService>();
builder.Services.AddBlazorServices();

builder.Services.AddDatabaseDeveloperPageExceptionFilter();

var app = builder.Build();

app.Logger.LogInformation("App created...");

app.Logger.LogInformation("Seeding Database...");

using (var scope = app.Services.CreateScope())
{
    var scopedProvider = scope.ServiceProvider;
    try
    {
        var catalogContext = scopedProvider.GetRequiredService<CatalogContext>();
        await CatalogContextSeed.SeedAsync(catalogContext, app.Logger);

        var userManager = scopedProvider.GetRequiredService<UserManager<ApplicationUser>>();
        var roleManager = scopedProvider.GetRequiredService<RoleManager<IdentityRole>>();
        var identityContext = scopedProvider.GetRequiredService<AppIdentityDbContext>();
        await AppIdentityDbContextSeed.SeedAsync(identityContext, userManager, roleManager, app.Services.GetRequiredService<IConfiguration>());
    }
    catch (Exception ex)
    {
        app.Logger.LogCritical(ex, "Database migration or seeding failed. Application startup cannot continue.");
        throw;
    }
}

var catalogBaseUrl = builder.Configuration.GetValue(typeof(string), "CatalogBaseUrl") as string;
if (!string.IsNullOrEmpty(catalogBaseUrl))
{
    app.Use((context, next) =>
    {
        context.Request.PathBase = new PathString(catalogBaseUrl);
        return next();
    });
}

app.UseHealthChecks("/health",
    new HealthCheckOptions
    {
        ResponseWriter = async (context, report) =>
        {
            var result = new
            {
                status = report.Status.ToString(),
                errors = report.Entries.Select(e => new
                {
                    key = e.Key,
                    value = Enum.GetName(typeof(HealthStatus), e.Value.Status)
                })
            }.ToJson();
            context.Response.ContentType = MediaTypeNames.Application.Json;
            await context.Response.WriteAsync(result);
        }
    });
if (app.Environment.IsDevelopment() || app.Environment.EnvironmentName == "Docker")
{
    app.Logger.LogInformation("Adding Development middleware...");
    app.UseDeveloperExceptionPage();
    app.UseShowAllServicesMiddleware();
    app.UseMigrationsEndPoint();
    app.UseWebAssemblyDebugging();
}
else
{
    app.Logger.LogInformation("Adding non-Development middleware...");
    app.UseExceptionHandler("/Error");
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseBlazorFrameworkFiles();
app.UseStaticFiles();
app.UseRouting();

app.UseCookiePolicy();
app.UseAuthentication();
app.UseAuthorization();


app.MapControllerRoute("default", "{controller:slugify=Home}/{action:slugify=Index}/{id?}");
app.MapRazorPages();
app.MapHealthChecks("home_page_health_check", new HealthCheckOptions { Predicate = check => check.Tags.Contains("homePageHealthCheck") });
app.MapHealthChecks("api_health_check", new HealthCheckOptions { Predicate = check => check.Tags.Contains("apiHealthCheck") });
//endpoints.MapBlazorHub("/admin");
app.MapFallbackToFile("index.html");

app.Logger.LogInformation("LAUNCHING");
app.Run();
