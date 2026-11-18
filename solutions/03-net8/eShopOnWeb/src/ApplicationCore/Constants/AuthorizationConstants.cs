namespace Microsoft.eShopWeb.ApplicationCore.Constants;

public class AuthorizationConstants
{
    // JWT signing key configuration key — value must be supplied via configuration (env var, Key Vault, or User Secrets)
    public const string JWT_SECRET_KEY_CONFIG = "JwtSecretKey";

    // Default seed password configuration key — value must be supplied via configuration (env var, Key Vault, or User Secrets)
    public const string DEFAULT_PASSWORD_CONFIG = "DefaultPassword";
}
