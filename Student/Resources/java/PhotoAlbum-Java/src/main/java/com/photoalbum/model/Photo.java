package com.photoalbum.model;

import javax.persistence.*;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Positive;
import javax.validation.constraints.Size;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Represents an uploaded photo with metadata for display and management
 */
@Entity
@Table(name = "photos", indexes = {
    @Index(name = "idx_photos_uploaded_at", columnList = "uploaded_at", unique = false)
})
public class Photo {

    /**
     * Unique identifier for the photo using UUID
     */
    @Id
    @Column(name = "id", length = 36)
    private String id;

    /**
     * Original filename as uploaded by user
     */
    @NotBlank
    @Size(max = 255)
    @Column(name = "original_file_name", nullable = false, length = 255)
    private String originalFileName;

    /**
     * Binary photo data stored directly in Oracle database
     */
    @Lob
    @Column(name = "photo_data", nullable = true)
    private byte[] photoData;

    /**
     * GUID-based filename with extension (for compatibility)
     */
    @NotBlank
    @Size(max = 255)
    @Column(name = "stored_file_name", nullable = false, length = 255)
    private String storedFileName;

    /**
     * Relative path from static resources (for compatibility - not used for DB storage)
     */
    @Size(max = 500)
    @Column(name = "file_path", length = 500)
    private String filePath;

    /**
     * File size in bytes
     */
    @NotNull
    @Positive
    @Column(name = "file_size", nullable = false, columnDefinition = "NUMBER(19,0)")
    private Long fileSize;

    /**
     * MIME type (e.g., image/jpeg, image/png)
     */
    @NotBlank
    @Size(max = 50)
    @Column(name = "mime_type", nullable = false, length = 50)
    private String mimeType;

    /**
     * Timestamp of upload
     */
    @NotNull
    @Column(name = "uploaded_at", nullable = false, columnDefinition = "TIMESTAMP DEFAULT SYSTIMESTAMP")
    private LocalDateTime uploadedAt;

    /**
     * Image width in pixels (populated after upload)
     */
    @Column(name = "width")
    private Integer width;

    /**
     * Image height in pixels (populated after upload)
     */
    @Column(name = "height")
    private Integer height;

    // Default constructor
    public Photo() {
        this.id = UUID.randomUUID().toString();
        this.uploadedAt = LocalDateTime.now();
    }

    // Constructor with required fields
    public Photo(String originalFileName, byte[] photoData, String storedFileName, String filePath, Long fileSize, String mimeType) {
        this();
        this.originalFileName = originalFileName;
        this.photoData = photoData;
        this.storedFileName = storedFileName;
        this.filePath = filePath;
        this.fileSize = fileSize;
        this.mimeType = mimeType;
    }

    // Constructor with required fields (file system compatibility)
    public Photo(String originalFileName, String storedFileName, String filePath, Long fileSize, String mimeType) {
        this();
        this.originalFileName = originalFileName;
        this.storedFileName = storedFileName;
        this.filePath = filePath;
        this.fileSize = fileSize;
        this.mimeType = mimeType;
    }

    // Getters and Setters
    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getOriginalFileName() {
        return originalFileName;
    }

    public void setOriginalFileName(String originalFileName) {
        this.originalFileName = originalFileName;
    }

    public byte[] getPhotoData() {
        return photoData;
    }

    public void setPhotoData(byte[] photoData) {
        this.photoData = photoData;
    }

    public String getStoredFileName() {
        return storedFileName;
    }

    public void setStoredFileName(String storedFileName) {
        this.storedFileName = storedFileName;
    }

    public String getFilePath() {
        return filePath;
    }

    public void setFilePath(String filePath) {
        this.filePath = filePath;
    }

    public Long getFileSize() {
        return fileSize;
    }

    public void setFileSize(Long fileSize) {
        this.fileSize = fileSize;
    }

    public String getMimeType() {
        return mimeType;
    }

    public void setMimeType(String mimeType) {
        this.mimeType = mimeType;
    }

    public LocalDateTime getUploadedAt() {
        return uploadedAt;
    }

    public void setUploadedAt(LocalDateTime uploadedAt) {
        this.uploadedAt = uploadedAt;
    }

    public Integer getWidth() {
        return width;
    }

    public void setWidth(Integer width) {
        this.width = width;
    }

    public Integer getHeight() {
        return height;
    }

    public void setHeight(Integer height) {
        this.height = height;
    }

    @Override
    public String toString() {
        return "Photo{" +
                "id=" + id +
                ", originalFileName='" + originalFileName + '\'' +
                ", storedFileName='" + storedFileName + '\'' +
                ", filePath='" + filePath + '\'' +
                ", fileSize=" + fileSize +
                ", mimeType='" + mimeType + '\'' +
                ", uploadedAt=" + uploadedAt +
                ", width=" + width +
                ", height=" + height +
                '}';
    }
}