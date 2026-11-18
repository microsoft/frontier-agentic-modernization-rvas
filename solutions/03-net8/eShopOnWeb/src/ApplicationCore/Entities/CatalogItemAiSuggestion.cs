namespace Microsoft.eShopWeb.ApplicationCore.Entities;

/// <summary>
/// AI-generated metadata for a catalog item, returned by <see cref="Interfaces.ICatalogItemAiService"/>.
/// </summary>
/// <param name="Description">Short, compelling product description (max ~300 chars).</param>
/// <param name="AltText">Accessibility alt text for the product image (max ~200 chars).</param>
public record CatalogItemAiSuggestion(string Description, string AltText);
