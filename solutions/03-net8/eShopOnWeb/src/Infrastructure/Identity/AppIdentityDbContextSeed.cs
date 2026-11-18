using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.eShopWeb.ApplicationCore.Constants;
using Microsoft.Extensions.Configuration;

namespace Microsoft.eShopWeb.Infrastructure.Identity;

public class AppIdentityDbContextSeed
{
    public static async Task SeedAsync(AppIdentityDbContext identityDbContext, UserManager<ApplicationUser> userManager, RoleManager<IdentityRole> roleManager, IConfiguration configuration)
    {
        if (identityDbContext.Database.IsSqlServer())
        {
            identityDbContext.Database.Migrate();
        }

        var defaultPassword = configuration[AuthorizationConstants.DEFAULT_PASSWORD_CONFIG]
            ?? throw new InvalidOperationException(
                $"Default seed password not configured. Set '{AuthorizationConstants.DEFAULT_PASSWORD_CONFIG}' in configuration (env var, Key Vault, or User Secrets).");

        await roleManager.CreateAsync(new IdentityRole(BlazorShared.Authorization.Constants.Roles.ADMINISTRATORS));

        var defaultUser = new ApplicationUser { UserName = "demouser@microsoft.com", Email = "demouser@microsoft.com" };
        await userManager.CreateAsync(defaultUser, defaultPassword);

        string adminUserName = "admin@microsoft.com";
        var adminUser = new ApplicationUser { UserName = adminUserName, Email = adminUserName };
        await userManager.CreateAsync(adminUser, defaultPassword);
        adminUser = await userManager.FindByNameAsync(adminUserName);
        if (adminUser != null)
        {
            await userManager.AddToRoleAsync(adminUser, BlazorShared.Authorization.Constants.Roles.ADMINISTRATORS);
        }
    }
}
