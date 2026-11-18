using System.Net.Http;
using System.Threading;
using System.Threading.Tasks;
using BlazorShared;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using Microsoft.Extensions.Options;

namespace Microsoft.eShopWeb.Web.HealthChecks;

public class ApiHealthCheck : IHealthCheck
{
    private readonly BaseUrlConfiguration _baseUrlConfiguration;
    private readonly IHttpClientFactory _httpClientFactory;

    public ApiHealthCheck(IOptions<BaseUrlConfiguration> baseUrlConfiguration, IHttpClientFactory httpClientFactory)
    {
        _baseUrlConfiguration = baseUrlConfiguration.Value;
        _httpClientFactory = httpClientFactory;
    }

    public async Task<HealthCheckResult> CheckHealthAsync(
        HealthCheckContext context,
        CancellationToken cancellationToken = default(CancellationToken))
    {
        string myUrl = _baseUrlConfiguration.ApiBase + "catalog-items";
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
