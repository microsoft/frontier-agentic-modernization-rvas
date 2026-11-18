using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;
using Azure.Identity;
using Microsoft.Azure.StackExchangeRedis;
using StackExchange.Redis;
using BlazorShared;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.DataProtection;
using Microsoft.AspNetCore.Identity;
using Microsoft.eShopWeb;
using Microsoft.eShopWeb.ApplicationCore.Constants;
using Microsoft.eShopWeb.ApplicationCore.Interfaces;
using Microsoft.eShopWeb.PublicApi.Services;
using Microsoft.eShopWeb.ApplicationCore.Services;
using Microsoft.eShopWeb.Infrastructure.Data;
using Microsoft.eShopWeb.Infrastructure.Identity;
using Microsoft.eShopWeb.Infrastructure.Logging;
using Microsoft.eShopWeb.PublicApi;
using Microsoft.eShopWeb.PublicApi.Middleware;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using MinimalApi.Endpoint.Configurations.Extensions;
using MinimalApi.Endpoint.Extensions;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddEndpoints();

// Use to force loading of appsettings.json of test project
builder.Configuration.AddConfigurationFile("appsettings.test.json");
builder.Logging.AddConsole();

// Load Azure Key Vault secrets when running in Azure (AZURE_KEY_VAULT_ENDPOINT env var must be set)
var keyVaultEndpoint = builder.Configuration["AZURE_KEY_VAULT_ENDPOINT"];
if (!string.IsNullOrEmpty(keyVaultEndpoint))
{
    var credential = new DefaultAzureCredential();
    builder.Configuration.AddAzureKeyVault(new Uri(keyVaultEndpoint), credential);

    // Optionally pull centralised config from Azure App Configuration
    var appConfigEndpoint = builder.Configuration["AZURE_APP_CONFIGURATION_ENDPOINT"];
    if (!string.IsNullOrEmpty(appConfigEndpoint))
    {
        builder.Configuration.AddAzureAppConfiguration(options =>
            options.Connect(new Uri(appConfigEndpoint), credential)
                   .UseFeatureFlags());
    }
}

Microsoft.eShopWeb.Infrastructure.Dependencies.ConfigureServices(builder.Configuration, builder.Services);

builder.Services.AddIdentity<ApplicationUser, IdentityRole>()
        .AddEntityFrameworkStores<AppIdentityDbContext>()
        .AddDefaultTokenProviders();

builder.Services.AddScoped(typeof(IRepository<>), typeof(EfRepository<>));
builder.Services.AddScoped(typeof(IReadRepository<>), typeof(EfRepository<>));
builder.Services.Configure<CatalogSettings>(builder.Configuration);
var catalogSettings = builder.Configuration.Get<CatalogSettings>() ?? new CatalogSettings();
builder.Services.AddSingleton<IUriComposer>(new UriComposer(catalogSettings));
builder.Services.AddScoped(typeof(IAppLogger<>), typeof(LoggerAdapter<>));
builder.Services.AddScoped<ITokenClaimsService, IdentityTokenClaimService>();

// Register AI service (gracefully skipped when AzureOpenAI:Endpoint is not configured)
var aiEndpoint = builder.Configuration["AzureOpenAI:Endpoint"] ?? string.Empty;
var aiDeployment = builder.Configuration["AzureOpenAI:Deployment"] ?? "gpt-4.1-mini";
builder.Services.AddSingleton<ICatalogItemAiService>(sp =>
    new CatalogItemAiService(aiEndpoint, aiDeployment,
        sp.GetRequiredService<ILogger<CatalogItemAiService>>()));

var configSection = builder.Configuration.GetRequiredSection(BaseUrlConfiguration.CONFIG_NAME);
builder.Services.Configure<BaseUrlConfiguration>(configSection);
var baseUrlConfig = configSection.Get<BaseUrlConfiguration>();

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
        options.InstanceName = "eShopApi:";
    });
    builder.Services.AddDataProtection()
        .SetApplicationName("eShopOnWeb")
        .PersistKeysToStackExchangeRedis(redisConnection, "eShopOnWeb-DataProtection-Keys");
}
else
{
    builder.Services.AddDistributedMemoryCache();
}

var jwtSecret = builder.Configuration[AuthorizationConstants.JWT_SECRET_KEY_CONFIG]
    ?? throw new InvalidOperationException($"JWT secret key not configured. Set '{AuthorizationConstants.JWT_SECRET_KEY_CONFIG}' in configuration (env var, Key Vault, or User Secrets).");
var key = Encoding.ASCII.GetBytes(jwtSecret);
builder.Services.AddAuthentication(config =>
{
    config.DefaultScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(config =>
{
    config.RequireHttpsMetadata = false;
    config.SaveToken = true;
    config.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuerSigningKey = true,
        IssuerSigningKey = new SymmetricSecurityKey(key),
        ValidateIssuer = false,
        ValidateAudience = false
    };
});

const string CORS_POLICY = "CorsPolicy";
builder.Services.AddCors(options =>
{
    options.AddPolicy(name: CORS_POLICY,
        corsPolicyBuilder =>
        {
            corsPolicyBuilder.WithOrigins(baseUrlConfig!.WebBase.Replace("host.docker.internal", "localhost").TrimEnd('/'));
            corsPolicyBuilder.AllowAnyMethod();
            corsPolicyBuilder.AllowAnyHeader();
        });
});

builder.Services.AddControllers();
builder.Services.AddAutoMapper(cfg => cfg.AddMaps(typeof(MappingProfile).Assembly));
builder.Configuration.AddEnvironmentVariables();

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "My API", Version = "v1" });
    c.EnableAnnotations();
    c.SchemaFilter<CustomSchemaFilters>();
    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Description = @"JWT Authorization header using the Bearer scheme. \r\n\r\n 
                      Enter 'Bearer' [space] and then your token in the text input below.
                      \r\n\r\nExample: 'Bearer 12345abcdef'",
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.ApiKey,
        Scheme = "Bearer"
    });

    c.AddSecurityRequirement(new OpenApiSecurityRequirement()
            {
                    {
                        new OpenApiSecurityScheme
                        {
                            Reference = new OpenApiReference
                            {
                                Type = ReferenceType.SecurityScheme,
                                Id = "Bearer"
                            },
                            Scheme = "oauth2",
                            Name = "Bearer",
                            In = ParameterLocation.Header,

                        },
                        new List<string>()
                    }
            });
});

var app = builder.Build();

app.Logger.LogInformation("PublicApi App created...");

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

if (app.Environment.IsDevelopment())
{
    app.UseDeveloperExceptionPage();
}

app.UseMiddleware<ExceptionMiddleware>();

app.UseHttpsRedirection();

app.UseRouting();

app.UseCors(CORS_POLICY);

app.UseAuthorization();

// Enable middleware to serve generated Swagger as a JSON endpoint.
app.UseSwagger();

// Enable middleware to serve swagger-ui (HTML, JS, CSS, etc.), 
// specifying the Swagger JSON endpoint.
app.UseSwaggerUI(c =>
{
    c.SwaggerEndpoint("/swagger/v1/swagger.json", "My API V1");
});

app.MapControllers();
app.MapEndpoints();

app.Logger.LogInformation("LAUNCHING PublicApi");
app.Run();

public partial class Program { }
