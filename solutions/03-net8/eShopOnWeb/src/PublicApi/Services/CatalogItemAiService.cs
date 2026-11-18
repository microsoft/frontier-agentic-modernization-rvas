using System;
using System.Collections.Generic;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using Azure.AI.OpenAI;
using Azure.Identity;
using Microsoft.eShopWeb.ApplicationCore.Entities;
using Microsoft.eShopWeb.ApplicationCore.Interfaces;
using Microsoft.Extensions.Logging;
using OpenAI.Chat;

namespace Microsoft.eShopWeb.PublicApi.Services;

/// <summary>
/// Calls Azure OpenAI gpt-4.1-mini (vision) with Managed Identity to suggest
/// a product description and alt text from a catalog item image.
/// Never throws — failures are logged and SuggestAsync returns null so that
/// the create/update flow continues without AI enrichment.
/// </summary>
public class CatalogItemAiService : ICatalogItemAiService
{
    private const string SystemPrompt =
        "You are a product description assistant for an online fashion and apparel store. " +
        "Given a product image and product name, return ONLY a JSON object with exactly these keys: " +
        "{ \"description\": string, \"altText\": string }. " +
        "The description must be a compelling, concise e-commerce product description under 300 characters. " +
        "The altText must be an accessibility-friendly image description under 200 characters. " +
        "Do not include any other text outside the JSON.";

    private readonly ILogger<CatalogItemAiService> _logger;
    private readonly ChatClient? _chatClient;

    public CatalogItemAiService(string endpoint, string deployment, ILogger<CatalogItemAiService> logger)
    {
        _logger = logger;

        if (!string.IsNullOrWhiteSpace(endpoint))
        {
            try
            {
                var client = new AzureOpenAIClient(new Uri(endpoint), new DefaultAzureCredential());
                _chatClient = client.GetChatClient(deployment);
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Failed to initialize AzureOpenAIClient for endpoint {Endpoint}.", endpoint);
            }
        }
    }

    public async Task<CatalogItemAiSuggestion?> SuggestAsync(byte[] imageBytes, string mimeType, string productName, CancellationToken ct = default)
    {
        if (_chatClient == null || imageBytes == null || imageBytes.Length == 0)
        {
            return null;
        }

        try
        {
            var safeMime = string.IsNullOrWhiteSpace(mimeType) ? "image/png" : mimeType;

            var imagePart = ChatMessageContentPart.CreateImagePart(
                BinaryData.FromBytes(imageBytes), safeMime, ChatImageDetailLevel.Auto);

            var userText = string.IsNullOrWhiteSpace(productName)
                ? "Generate product metadata for this item."
                : $"Generate product metadata for the product named \"{productName}\".";

            var messages = new List<ChatMessage>
            {
                new SystemChatMessage(SystemPrompt),
                new UserChatMessage(
                    ChatMessageContentPart.CreateTextPart(userText),
                    imagePart)
            };

            var options = new ChatCompletionOptions
            {
                ResponseFormat = ChatResponseFormat.CreateJsonObjectFormat(),
                Temperature = 0.2f,
                MaxOutputTokenCount = 400
            };

            var result = await _chatClient.CompleteChatAsync(messages, options, ct);
            var content = result.Value.Content;
            if (content == null || content.Count == 0)
            {
                return null;
            }

            var json = content[0].Text;
            if (string.IsNullOrWhiteSpace(json))
            {
                return null;
            }

            using var doc = JsonDocument.Parse(json);
            var root = doc.RootElement;
            var description = root.TryGetProperty("description", out var descProp) ? descProp.GetString() : null;
            var altText = root.TryGetProperty("altText", out var altProp) ? altProp.GetString() : null;

            if (string.IsNullOrWhiteSpace(description))
            {
                return null;
            }

            return new CatalogItemAiSuggestion(description!, altText ?? string.Empty);
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Azure OpenAI catalog item suggestion failed.");
            return null;
        }
    }
}
