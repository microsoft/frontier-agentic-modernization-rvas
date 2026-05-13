package com.photoalbum.service.impl;

import com.azure.ai.openai.OpenAIClient;
import com.azure.ai.openai.OpenAIClientBuilder;
import com.azure.ai.openai.models.ChatChoice;
import com.azure.ai.openai.models.ChatCompletions;
import com.azure.ai.openai.models.ChatCompletionsJsonResponseFormat;
import com.azure.ai.openai.models.ChatCompletionsOptions;
import com.azure.ai.openai.models.ChatMessageContentItem;
import com.azure.ai.openai.models.ChatMessageImageContentItem;
import com.azure.ai.openai.models.ChatMessageImageUrl;
import com.azure.ai.openai.models.ChatMessageTextContentItem;
import com.azure.ai.openai.models.ChatRequestMessage;
import com.azure.ai.openai.models.ChatRequestSystemMessage;
import com.azure.ai.openai.models.ChatRequestUserMessage;
import com.azure.identity.DefaultAzureCredentialBuilder;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.photoalbum.dto.PhotoAiSuggestion;
import com.photoalbum.service.PhotoAiService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.Base64;
import java.util.List;
import java.util.Optional;

/**
 * Azure OpenAI vision-backed implementation. Uses {@code DefaultAzureCredential}
 * (managed identity in Azure, developer credentials locally).
 *
 * <p>The system prompt requests a strict JSON object so we can deserialize the
 * response into {@link PhotoAiSuggestion} without prompt-format drift.</p>
 */
@Service
public class PhotoAiServiceImpl implements PhotoAiService {

    private static final Logger logger = LoggerFactory.getLogger(PhotoAiServiceImpl.class);
    private static final ObjectMapper MAPPER = new ObjectMapper();

    private static final String SYSTEM_PROMPT =
        "You are a photo metadata assistant for a personal photo album. "
        + "Given a photo, respond ONLY with a strict JSON object using exactly these keys: "
        + "\"caption\" (a short, friendly one-sentence description, max 120 chars), "
        + "\"altText\" (an accessibility-friendly description for screen readers, max 250 chars), "
        + "\"tags\" (an array of 3-6 lowercase single-word tags). "
        + "Do not include any other text outside the JSON.";

    private final String endpoint;
    private final String deployment;
    private volatile OpenAIClient client;

    public PhotoAiServiceImpl(
            @Value("${azure.openai.endpoint:}") String endpoint,
            @Value("${azure.openai.deployment:gpt-4.1-mini}") String deployment) {
        this.endpoint = endpoint;
        this.deployment = deployment;
    }

    private OpenAIClient getClient() {
        if (client != null) {
            return client;
        }
        if (endpoint == null || endpoint.isBlank()) {
            return null;
        }
        synchronized (this) {
            if (client == null) {
                client = new OpenAIClientBuilder()
                        .endpoint(endpoint)
                        .credential(new DefaultAzureCredentialBuilder().build())
                        .buildClient();
            }
            return client;
        }
    }

    @Override
    public Optional<PhotoAiSuggestion> analyze(byte[] imageBytes, String mimeType) {
        if (imageBytes == null || imageBytes.length == 0) {
            return Optional.empty();
        }
        OpenAIClient c = getClient();
        if (c == null) {
            logger.debug("Azure OpenAI endpoint not configured — skipping AI enrichment.");
            return Optional.empty();
        }

        try {
            String safeMime = (mimeType == null || mimeType.isBlank()) ? "image/png" : mimeType;
            String base64 = Base64.getEncoder().encodeToString(imageBytes);
            String dataUrl = "data:" + safeMime + ";base64," + base64;

            List<ChatMessageContentItem> userContent = List.of(
                    new ChatMessageTextContentItem("Analyze this photo and return the JSON object as instructed."),
                    new ChatMessageImageContentItem(new ChatMessageImageUrl(dataUrl))
            );

            List<ChatRequestMessage> messages = List.of(
                    new ChatRequestSystemMessage(SYSTEM_PROMPT),
                    new ChatRequestUserMessage(userContent)
            );

            ChatCompletionsOptions options = new ChatCompletionsOptions(messages)
                    .setResponseFormat(new ChatCompletionsJsonResponseFormat())
                    .setTemperature(0.2)
                    .setMaxTokens(500);

            ChatCompletions completions = c.getChatCompletions(deployment, options);
            if (completions == null || completions.getChoices() == null || completions.getChoices().isEmpty()) {
                return Optional.empty();
            }
            ChatChoice choice = completions.getChoices().get(0);
            String json = choice.getMessage() != null ? choice.getMessage().getContent() : null;
            if (json == null || json.isBlank()) {
                return Optional.empty();
            }

            PhotoAiSuggestion suggestion = MAPPER.readValue(json, PhotoAiSuggestion.class);
            return Optional.of(suggestion);
        } catch (Exception ex) {
            logger.warn("Azure OpenAI photo analysis failed: {}", ex.getMessage());
            return Optional.empty();
        }
    }
}
