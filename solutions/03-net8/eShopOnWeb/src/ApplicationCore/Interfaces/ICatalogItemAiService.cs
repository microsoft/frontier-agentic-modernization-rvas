using System.Threading;
using System.Threading.Tasks;
using Microsoft.eShopWeb.ApplicationCore.Entities;

namespace Microsoft.eShopWeb.ApplicationCore.Interfaces;

/// <summary>
/// Analyzes a product image with Azure OpenAI vision and returns suggested
/// catalog item metadata (description and alt text).
///
/// Implementations must NEVER throw: if Azure OpenAI is not configured or
/// the call fails, return null. The create/update flow must continue without AI enrichment.
/// </summary>
public interface ICatalogItemAiService
{
    Task<CatalogItemAiSuggestion?> SuggestAsync(byte[] imageBytes, string mimeType, string productName, CancellationToken ct = default);
}
