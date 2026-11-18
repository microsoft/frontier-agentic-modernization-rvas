package com.photoalbum.repository;

import com.photoalbum.model.Photo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

/**
 * Repository interface for Photo entity operations
 */
@Repository
public interface PhotoRepository extends JpaRepository<Photo, String> {

    /**
     * Find all photos ordered by upload date (newest first)
     * @return List of photos ordered by upload date descending
     */
    @Query(value = "SELECT id, original_file_name, photo_data, stored_file_name, file_path, file_size, " +
                   "mime_type, uploaded_at, width, height, caption, alt_text, tags " +
                   "FROM photos " +
                   "ORDER BY uploaded_at DESC", 
           nativeQuery = true)
    List<Photo> findAllOrderByUploadedAtDesc();

    /**
     * Find photos uploaded before a specific photo (for navigation)
     * @param uploadedAt The upload timestamp to compare against
     * @return List of photos uploaded before the given timestamp
     */
    @Query(value = "SELECT id, original_file_name, photo_data, stored_file_name, file_path, file_size, " +
                   "mime_type, uploaded_at, width, height, caption, alt_text, tags " +
                   "FROM photos " +
                   "WHERE uploaded_at < :uploadedAt " +
                   "ORDER BY uploaded_at DESC " +
                   "LIMIT 10", 
           nativeQuery = true)
    List<Photo> findPhotosUploadedBefore(@Param("uploadedAt") LocalDateTime uploadedAt);

    /**
     * Find photos uploaded after a specific photo (for navigation)
     * @param uploadedAt The upload timestamp to compare against
     * @return List of photos uploaded after the given timestamp
     */
    @Query(value = "SELECT id, original_file_name, photo_data, stored_file_name, " +
                   "COALESCE(file_path, 'default_path') AS file_path, file_size, " +
                   "mime_type, uploaded_at, width, height, caption, alt_text, tags " +
                   "FROM photos " +
                   "WHERE uploaded_at > :uploadedAt " +
                   "ORDER BY uploaded_at ASC", 
           nativeQuery = true)
    List<Photo> findPhotosUploadedAfter(@Param("uploadedAt") LocalDateTime uploadedAt);

    /**
     * Find photos by upload month using TO_CHAR function
     * @param year The year to search for
     * @param month The month to search for
     * @return List of photos uploaded in the specified month
     */
    @Query(value = "SELECT id, original_file_name, photo_data, stored_file_name, file_path, file_size, " +
                   "mime_type, uploaded_at, width, height, caption, alt_text, tags " +
                   "FROM photos " +
                   "WHERE TO_CHAR(uploaded_at, 'YYYY') = :year " +
                   "AND TO_CHAR(uploaded_at, 'MM') = :month " +
                   "ORDER BY uploaded_at DESC", 
           nativeQuery = true)
    List<Photo> findPhotosByUploadMonth(@Param("year") String year, @Param("month") String month);

    /**
     * Get paginated photos using LIMIT/OFFSET
     * @param startRow Starting row number (1-based)
     * @param endRow Ending row number
     * @return List of photos within the specified row range
     */
    @Query(value = "SELECT id, original_file_name, photo_data, stored_file_name, file_path, file_size, " +
                   "mime_type, uploaded_at, width, height, caption, alt_text, tags " +
                   "FROM photos " +
                   "ORDER BY uploaded_at DESC " +
                   "LIMIT (:endRow - :startRow + 1) OFFSET (:startRow - 1)", 
           nativeQuery = true)
    List<Photo> findPhotosWithPagination(@Param("startRow") int startRow, @Param("endRow") int endRow);

    /**
     * Find photos with file size statistics using window functions
     * @return List of photos with running totals and rankings
     */
    @Query(value = "SELECT id, original_file_name, photo_data, stored_file_name, file_path, file_size, " +
                   "mime_type, uploaded_at, width, height, " +
                   "RANK() OVER (ORDER BY file_size DESC) AS size_rank, " +
                   "SUM(file_size) OVER (ORDER BY uploaded_at ROWS UNBOUNDED PRECEDING) AS running_total " +
                   "FROM photos " +
                   "ORDER BY uploaded_at DESC", 
           nativeQuery = true)
    List<Object[]> findPhotosWithStatistics();
}