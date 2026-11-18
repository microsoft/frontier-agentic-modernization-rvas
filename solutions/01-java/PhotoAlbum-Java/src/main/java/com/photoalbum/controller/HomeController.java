package com.photoalbum.controller;

import com.photoalbum.model.Photo;
import com.photoalbum.model.UploadResult;
import com.photoalbum.service.PhotoService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * Controller for the main photo gallery page with upload functionality
 */
@Controller
public class HomeController {

    private static final Logger logger = LoggerFactory.getLogger(HomeController.class);

    private final PhotoService photoService;

    public HomeController(PhotoService photoService) {
        this.photoService = photoService;
    }

    /**
     * Handler for GET requests - loads all photos for display
     */
    @GetMapping("/")
    public String index(Model model) {
        try {
            List<Photo> photos = photoService.getAllPhotos();
            model.addAttribute("photos", photos);
            // Add timestamp for cache busting
            model.addAttribute("timestamp", System.currentTimeMillis());
        } catch (Exception ex) {
            logger.error("Error loading photos", ex);
            model.addAttribute("photos", new ArrayList<Photo>());
            model.addAttribute("timestamp", System.currentTimeMillis());
        }
        return "index";
    }

    /**
     * Handler for POST requests - uploads one or more photo files
     */
    @PostMapping("/upload")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> uploadPhotos(@RequestParam("files") List<MultipartFile> files) {
        Map<String, Object> response = new HashMap<String, Object>();
        List<Map<String, Object>> uploadedPhotos = new ArrayList<Map<String, Object>>();
        List<Map<String, Object>> failedUploads = new ArrayList<Map<String, Object>>();

        if (files == null || files.isEmpty()) {
            response.put("success", false);
            response.put("error", "No files provided");
            return ResponseEntity.badRequest().body(response);
        }

        for (MultipartFile file : files) {
            UploadResult result = photoService.uploadPhoto(file);

            if (result.isSuccess()) {
                Optional<Photo> photoOpt = photoService.getPhotoById(result.getPhotoId());
                if (photoOpt.isPresent()) {
                    Photo photo = photoOpt.get();
                    Map<String, Object> uploadedPhoto = new HashMap<String, Object>();
                    uploadedPhoto.put("id", photo.getId());
                    uploadedPhoto.put("originalFileName", photo.getOriginalFileName());
                    uploadedPhoto.put("filePath", photo.getFilePath());
                    uploadedPhoto.put("uploadedAt", photo.getUploadedAt());
                    uploadedPhoto.put("fileSize", photo.getFileSize());
                    uploadedPhoto.put("width", photo.getWidth());
                    uploadedPhoto.put("height", photo.getHeight());
                    uploadedPhotos.add(uploadedPhoto);
                }
            } else {
                Map<String, Object> failedUpload = new HashMap<String, Object>();
                failedUpload.put("fileName", result.getFileName());
                failedUpload.put("error", result.getErrorMessage());
                failedUploads.add(failedUpload);
            }
        }

        response.put("success", !uploadedPhotos.isEmpty());
        response.put("uploadedPhotos", uploadedPhotos);
        response.put("failedUploads", failedUploads);

        return ResponseEntity.ok(response);
    }
}