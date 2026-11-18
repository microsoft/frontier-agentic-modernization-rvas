using Microsoft.IdentityModel.Tokens;
using System;
using System.Collections.Generic;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace PublicApiIntegrationTests
{
    public class ApiTokenHelper
    {
        // Must match the value in appsettings.test.json > JwtSecretKey
        private const string TestJwtSecretKey = "TestSecretKeyForIntegrationTestsThatMustBeAMinimumNumberOfBytes";

        public static string GetAdminUserToken()
        {
            string userName = "admin@microsoft.com";
            string[] roles = { "Administrators" };

            return CreateToken(userName, roles);
        }

        public static string GetNormalUserToken()
        {
            string userName = "demouser@microsoft.com";
            string[] roles = { };

            return CreateToken(userName, roles);
        }

        private static string CreateToken(string userName, string[] roles)
        {
            var claims = new List<Claim> { new Claim(ClaimTypes.Name, userName) };

            foreach (var role in roles)
            {
                claims.Add(new Claim(ClaimTypes.Role, role));
            }

            var key = Encoding.ASCII.GetBytes(TestJwtSecretKey);
            var tokenDescriptor = new SecurityTokenDescriptor
            {
                Subject = new ClaimsIdentity(claims.ToArray()),
                Expires = DateTime.UtcNow.AddHours(1),
                SigningCredentials = new SigningCredentials(new SymmetricSecurityKey(key), SecurityAlgorithms.HmacSha256Signature)
            };
            var tokenHandler = new JwtSecurityTokenHandler();
            var token = tokenHandler.CreateToken(tokenDescriptor);
            return tokenHandler.WriteToken(token);
        }
    }
}
