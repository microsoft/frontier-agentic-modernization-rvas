package com.photoalbum.service;

import com.photoalbum.dto.PhotoAiSuggestion;

import java.util.Optional;

/**
 * Analyzes an uploaded photo with Azure OpenAI vision and returns a caption,
 * an accessibility-friendly alt text, and a small set of tags.
 *
 * <p>Implementations must NEVER throw: if Azure OpenAI is not configured or
 * the call fails for any reason, return {@link Optional#empty()} and log a
 * warning. The upload flow must continue to work without AI enrichment.</p>
 */
public interface PhotoAiService {

    /**
     * Analyze a photo and return AI-generated metadata.
     *
     * @param imageBytes the raw image bytes
     * @param mimeType   the MIME type (e.g. {@code image/jpeg})
     * @return suggestion, or {@link Optional#empty()} when AI is disabled or fails
     */
    Optional<PhotoAiSuggestion> analyze(byte[] imageBytes, String mimeType);
}
