package com.photoalbum.dto;

import java.util.List;

/**
 * AI-generated suggestions for a photo, returned by {@link com.photoalbum.service.PhotoAiService}.
 * Any field may be null when the model could not produce a useful value.
 */
public record PhotoAiSuggestion(String caption, String altText, List<String> tags) {
}
