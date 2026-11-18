package com.photoalbum.controller;

import com.photoalbum.model.Photo;
import com.photoalbum.service.PhotoService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.Optional;

/**
 * Controller for displaying a single photo in full size
 */
@Controller
@RequestMapping("/detail")
public class DetailController {

    private static final Logger logger = LoggerFactory.getLogger(DetailController.class);

    private final PhotoService photoService;

    public DetailController(PhotoService photoService) {
        this.photoService = photoService;
    }

    /**
     * Handles GET requests to display a photo
     */
    @GetMapping("/{id}")
    public String detail(@PathVariable String id, Model model) {
        if (id == null || id.trim().isEmpty()) {
            return "redirect:/";
        }

        try {
            Optional<Photo> photoOpt = photoService.getPhotoById(id);
            if (!photoOpt.isPresent()) {
                return "redirect:/";
            }

            Photo photo = photoOpt.get();
            model.addAttribute("photo", photo);

            // Find previous and next photos for navigation
            Optional<Photo> previousPhoto = photoService.getPreviousPhoto(photo);
            Optional<Photo> nextPhoto = photoService.getNextPhoto(photo);

            model.addAttribute("previousPhotoId", previousPhoto.isPresent() ? previousPhoto.get().getId() : null);
            model.addAttribute("nextPhotoId", nextPhoto.isPresent() ? nextPhoto.get().getId() : null);

            return "detail";
        } catch (Exception ex) {
            logger.error("Error loading photo with ID {}", id, ex);
            return "redirect:/";
        }
    }

    /**
     * Handles POST requests to delete a photo
     */
    @PostMapping("/{id}/delete")
    public String deletePhoto(@PathVariable String id, RedirectAttributes redirectAttributes) {
        try {
            boolean deleted = photoService.deletePhoto(id);
            if (deleted) {
                logger.info("Photo {} deleted successfully", id);
                redirectAttributes.addFlashAttribute("successMessage", "Photo deleted successfully");
            } else {
                redirectAttributes.addFlashAttribute("errorMessage", "Photo not found");
            }
        } catch (Exception ex) {
            logger.error("Error deleting photo {}", id, ex);
            redirectAttributes.addFlashAttribute("errorMessage", "Failed to delete photo. Please try again.");
        }
        return "redirect:/";
    }
}