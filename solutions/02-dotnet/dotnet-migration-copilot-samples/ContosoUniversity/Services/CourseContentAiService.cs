using System;
using System.ClientModel;
using System.Collections.Generic;
using System.IO;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using Azure.AI.OpenAI;
using Azure.Identity;
using ContosoUniversity.Models;
using Microsoft.Extensions.Logging;
using OpenAI.Chat;

namespace ContosoUniversity.Services
{
    /// <summary>
    /// Calls Azure OpenAI gpt-4.1-mini (vision) with Managed Identity. Never throws –
    /// failures are logged and AnalyzeAsync returns null so the upload flow continues.
    /// </summary>
    public class CourseContentAiService : ICourseContentAiService
    {
        private const string SystemPrompt =
            "You assist a university administrator who is authoring a Course record. " +
            "Look at the attached image of teaching material and the course title, then return ONLY a JSON object " +
            "with this exact shape: " +
            "{ \"description\": string, \"learningObjectives\": string[], \"altText\": string }. " +
            "Keep the description under 300 characters. Provide 3 to 6 concise learning objectives. " +
            "The altText must be an accessibility description of the image under 200 characters.";

        private readonly string _endpoint;
        private readonly string _deployment;
        private readonly ILogger<CourseContentAiService> _logger;
        private readonly ChatClient _chatClient;

        public CourseContentAiService(string endpoint, string deployment, ILogger<CourseContentAiService> logger)
        {
            _endpoint = endpoint;
            _deployment = deployment;
            _logger = logger;
            if (!string.IsNullOrWhiteSpace(_endpoint))
            {
                try
                {
                    var client = new AzureOpenAIClient(new Uri(_endpoint), new DefaultAzureCredential());
                    _chatClient = client.GetChatClient(_deployment);
                }
                catch (Exception ex)
                {
                    _logger.LogWarning(ex, "Failed to initialize AzureOpenAIClient for endpoint {Endpoint}.", _endpoint);
                }
            }
        }

        public async Task<CourseAiSuggestion> AnalyzeAsync(byte[] imageBytes, string mimeType, string courseTitle, CancellationToken ct = default)
        {
            if (_chatClient == null || imageBytes == null || imageBytes.Length == 0)
            {
                return null;
            }

            try
            {
                var imagePart = ChatMessageContentPart.CreateImagePart(
                    BinaryData.FromBytes(imageBytes), mimeType ?? "image/png", ChatImageDetailLevel.Auto);

                var userText = string.IsNullOrWhiteSpace(courseTitle)
                    ? "Generate course content metadata for this teaching material image."
                    : $"Generate course content metadata for the course titled \"{courseTitle}\".";

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
                    MaxOutputTokenCount = 600
                };

                ClientResult<ChatCompletion> result = await _chatClient.CompleteChatAsync(messages, options, ct);
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
                return JsonSerializer.Deserialize<CourseAiSuggestion>(json, new JsonSerializerOptions
                {
                    PropertyNameCaseInsensitive = true
                });
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Azure OpenAI course-content analysis failed.");
                return null;
            }
        }
    }
}
