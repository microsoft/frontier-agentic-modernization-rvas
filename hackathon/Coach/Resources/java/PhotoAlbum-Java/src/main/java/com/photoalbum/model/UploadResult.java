package com.photoalbum.model;

/**
 * Result object for photo upload operations
 */
public class UploadResult {
    private boolean success;
    private String fileName;
    private String errorMessage;
    private String photoId;

    // Default constructor
    public UploadResult() {
    }

    // Constructor for successful upload with photo ID
    public UploadResult(boolean success, String fileName, String photoId) {
        this.success = success;
        this.fileName = fileName;
        this.photoId = photoId;
    }

    // Static factory method for failed upload
    public static UploadResult failure(String fileName, String errorMessage) {
        UploadResult result = new UploadResult();
        result.success = false;
        result.fileName = fileName;
        result.errorMessage = errorMessage;
        return result;
    }

    // Getters and Setters
    public boolean isSuccess() {
        return success;
    }

    public void setSuccess(boolean success) {
        this.success = success;
    }

    public String getFileName() {
        return fileName;
    }

    public void setFileName(String fileName) {
        this.fileName = fileName;
    }

    public String getErrorMessage() {
        return errorMessage;
    }

    public void setErrorMessage(String errorMessage) {
        this.errorMessage = errorMessage;
    }

    public String getPhotoId() {
        return photoId;
    }

    public void setPhotoId(String photoId) {
        this.photoId = photoId;
    }

    @Override
    public String toString() {
        return "UploadResult{" +
                "success=" + success +
                ", fileName='" + fileName + '\'' +
                ", errorMessage='" + errorMessage + '\'' +
                ", photoId=" + photoId +
                '}';
    }
}