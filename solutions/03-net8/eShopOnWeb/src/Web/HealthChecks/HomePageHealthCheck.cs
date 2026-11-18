using System.Net.Http;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Diagnostics.HealthChecks;

namespace Microsoft.eShopWeb.Web.HealthChecks;

public class HomePageHealthCheck : IHealthCheck
{
    private readonly IHttpContextAccessor _httpContextAccessor;
    private readonly IHttpClientFactory _httpClientFactory;

    public HomePageHealthCheck(IHttpContextAccessor httpContextAccessor, IHttpClientFactory httpClientFactory)
    {
        _httpContextAccessor = httpContextAccessor;
        _httpClientFactory = httpClientFactory;
    }

    public async Task<HealthCheckResult> CheckHealthAsync(
        HealthCheckContext context,
        CancellationToken cancellationToken = default(CancellationToken))
    {
        var request = _httpContextAccessor.HttpContext?.Request;
        string myUrl = request?.Scheme + "://" + request?.Host.ToString();

        var client = _httpClientFactory.CreateClient("healthcheck");
        var response = await client.GetAsync(myUrl, cancellationToken);
        var pageContents = await response.Content.ReadAsStringAsync(cancellationToken);
        if (pageContents.Contains(".NET Bot Black Sweatshirt"))
        {
            return HealthCheckResult.Healthy("The check indicates a healthy result.");
        }

        return HealthCheckResult.Unhealthy("The check indicates an unhealthy result.");
    }
}
