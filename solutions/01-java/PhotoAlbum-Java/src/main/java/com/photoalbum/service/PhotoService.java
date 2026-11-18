package com.photoalbum.service;

import com.photoalbum.model.Photo;
import com.photoalbum.model.UploadResult;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Optional;

/**
 * Service interface for photo operations
 */
public interface PhotoService {

    /**
     * Get all photos ordered by upload date (newest first)
     * @return List of photos
     */
    List<Photo> getAllPhotos();

    /**
     * Get a specific photo by ID
     * @param id Photo ID
     * @return Photo if found, empty otherwise
     */
    Optional<Photo> getPhotoById(String id);

    /**
     * Upload a photo file
     * @param file The uploaded file
     * @return Upload result with success status and photo details or error message
     */
    UploadResult uploadPhoto(MultipartFile file);

    /**
     * Delete a photo by ID
     * @param id Photo ID
     * @return True if deleted successfully, false if not found
     */
    boolean deletePhoto(String id);

    /**
     * Get the previous photo (older) for navigation
     * @param currentPhoto The current photo
     * @return Previous photo if found, empty otherwise
     */
    Optional<Photo> getPreviousPhoto(Photo currentPhoto);

    /**
     * Get the next photo (newer) for navigation
     * @param currentPhoto The current photo
     * @return Next photo if found, empty otherwise
     */
    Optional<Photo> getNextPhoto(Photo currentPhoto);
}