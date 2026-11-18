package com.photoalbum.controller;

import com.photoalbum.model.Photo;
import com.photoalbum.service.PhotoService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.Optional;

/**
 * Controller for serving photo files from Oracle database BLOB storage
 */
@Controller
@RequestMapping("/photo")
public class PhotoFileController {

    private static final Logger logger = LoggerFactory.getLogger(PhotoFileController.class);

    private final PhotoService photoService;

    public PhotoFileController(PhotoService photoService) {
        this.photoService = photoService;
    }

    /**
     * Serves a photo file by ID from Oracle database BLOB storage
     */
    @GetMapping("/{id}")
    public ResponseEntity<Resource> servePhoto(@PathVariable String id) {
        if (id == null || id.trim().isEmpty()) {
            logger.warn("Photo file request with null or empty ID");
            return ResponseEntity.notFound().build();
        }

        try {
            logger.info("=== DEBUGGING: Serving photo request for ID {} ===", id);
            Optional<Photo> photoOpt = photoService.getPhotoById(id);

            if (!photoOpt.isPresent()) {
                logger.warn("Photo with ID {} not found", id);
                return ResponseEntity.notFound().build();
            }

            Photo photo = photoOpt.get();
            logger.info("Found photo: originalFileName={}, mimeType={}", 
                    photo.getOriginalFileName(), photo.getMimeType());

            // Get photo data from Oracle database BLOB
            byte[] photoData = photo.getPhotoData();
            if (photoData == null || photoData.length == 0) {
                logger.error("No photo data found for photo ID {}", id);
                return ResponseEntity.notFound().build();
            }

            logger.info("Photo data retrieved: {} bytes, first 10 bytes: {}", 
                    photoData.length, 
                    photoData.length >= 10 ? java.util.Arrays.toString(java.util.Arrays.copyOf(photoData, 10)) : "less than 10 bytes");

            // Create resource from byte array
            Resource resource = new ByteArrayResource(photoData);

            logger.info("Serving photo ID {} ({}, {} bytes) from Oracle database",
                    id, photo.getOriginalFileName(), photoData.length);

            // Return the photo data with appropriate content type and aggressive no-cache headers
            return ResponseEntity.ok()
                    .contentType(MediaType.parseMediaType(photo.getMimeType()))
                    .header(HttpHeaders.CACHE_CONTROL, "no-cache, no-store, must-revalidate, private")
                    .header(HttpHeaders.PRAGMA, "no-cache")
                    .header(HttpHeaders.EXPIRES, "0")
                    .header("X-Photo-ID", String.valueOf(id))
                    .header("X-Photo-Name", photo.getOriginalFileName())
                    .header("X-Photo-Size", String.valueOf(photoData.length))
                    .body(resource);
        } catch (Exception ex) {
            logger.error("Error serving photo with ID {} from Oracle database", id, ex);
            return ResponseEntity.status(500).build();
        }
    }
}