// Photo Album Upload JavaScript
(function () {
    'use strict';

    const dropZone = document.getElementById('drop-zone');
    const fileInput = document.getElementById('file-input');
    const uploadForm = document.getElementById('upload-form');
    const uploadFeedback = document.getElementById('upload-feedback');
    const uploadProgress = document.getElementById('upload-progress');
    const uploadSuccess = document.getElementById('upload-success');
    const uploadErrors = document.getElementById('upload-errors');
    const photoGallery = document.getElementById('photo-gallery');

    if (!dropZone || !fileInput) {
        console.error('Required elements not found');
        return;
    }

    // Click on drop zone to open file picker
    dropZone.addEventListener('click', () => {
        fileInput.click();
    });

    // Prevent default drag behaviors
    ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
        dropZone.addEventListener(eventName, preventDefaults, false);
        document.body.addEventListener(eventName, preventDefaults, false);
    });

    function preventDefaults(e) {
        e.preventDefault();
        e.stopPropagation();
    }

    // Highlight drop zone when dragging over it
    ['dragenter', 'dragover'].forEach(eventName => {
        dropZone.addEventListener(eventName, () => {
            dropZone.classList.add('drop-zone-highlight');
        }, false);
    });

    ['dragleave', 'drop'].forEach(eventName => {
        dropZone.addEventListener(eventName, () => {
            dropZone.classList.remove('drop-zone-highlight');
        }, false);
    });

    // Handle dropped files
    dropZone.addEventListener('drop', (e) => {
        const dt = e.dataTransfer;
        const files = dt.files;
        handleFiles(files);
    }, false);

    // Handle file input change
    fileInput.addEventListener('change', (e) => {
        handleFiles(e.target.files);
    });

    function handleFiles(files) {
        if (!files || files.length === 0) {
            return;
        }

        // Client-side validation
        const validFiles = [];
        const errors = [];
        const allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
        const maxSize = 10 * 1024 * 1024; // 10MB

        Array.from(files).forEach(file => {
            if (!allowedTypes.includes(file.type)) {
                errors.push(`${file.name}: File type not supported. Please upload JPEG, PNG, GIF, or WebP images.`);
            } else if (file.size > maxSize) {
                errors.push(`${file.name}: File size exceeds 10MB limit.`);
            } else {
                validFiles.push(file);
            }
        });

        if (errors.length > 0) {
            showErrors(errors);
        }

        if (validFiles.length > 0) {
            uploadFiles(validFiles);
        }
    }

    async function uploadFiles(files) {
        // Show progress
        uploadFeedback.classList.remove('d-none');
        uploadProgress.classList.remove('d-none');
        uploadSuccess.classList.add('d-none');
        uploadErrors.classList.add('d-none');

        const formData = new FormData();
        files.forEach(file => {
            formData.append('files', file);
        });

        try {
            const response = await fetch('/upload', {
                method: 'POST',
                body: formData
            });

            uploadProgress.classList.add('d-none');

            if (response.ok) {
                const result = await response.json();

                if (result.uploadedPhotos && result.uploadedPhotos.length > 0) {
                    showSuccess(`Successfully uploaded ${result.uploadedPhotos.length} photo(s)!`);
                    displayNewPhotos(result.uploadedPhotos);
                }

                if (result.failedUploads && result.failedUploads.length > 0) {
                    const errorMessages = result.failedUploads.map(f => `${f.fileName}: ${f.error}`);
                    showErrors(errorMessages);
                }

                // Reset file input
                fileInput.value = '';
            } else {
                showErrors(['Upload failed. Please try again.']);
            }
        } catch (error) {
            uploadProgress.classList.add('d-none');
            console.error('Upload error:', error);
            showErrors(['An error occurred during upload. Please try again.']);
        }
    }

    function displayNewPhotos(photos) {
        // Remove "no photos" message if it exists
        const alertInfo = document.querySelector('#gallery-section .alert-info');
        if (alertInfo) {
            alertInfo.remove();
        }

        // Get the current gallery element (may have been created dynamically)
        let galleryElement = document.getElementById('photo-gallery');

        // Create gallery if it doesn't exist
        if (!galleryElement) {
            const gallerySection = document.getElementById('gallery-section');
            galleryElement = document.createElement('div');
            galleryElement.className = 'row';
            galleryElement.id = 'photo-gallery';
            gallerySection.appendChild(galleryElement);
        }

        // Add photos to the beginning of the gallery
        photos.forEach((photo) => {
            const photoCard = createPhotoCard(photo);
            galleryElement.insertAdjacentHTML('afterbegin', photoCard);
        });
    }

    function createPhotoCard(photo) {
        const uploadDate = new Date(photo.uploadedAt);
        const formattedDate = uploadDate.toLocaleString('en-US', {
            month: 'short',
            day: 'numeric',
            year: 'numeric',
            hour: 'numeric',
            minute: '2-digit',
            hour12: true
        });

        const dimensions = (photo.width && photo.height)
            ? ` • ${photo.width} x ${photo.height}`
            : '';

        // Use photo URL with current timestamp to bypass all caching
        const timestamp = new Date().getTime();
        const photoUrl = `/photo/${photo.id}?_t=${timestamp}`;
        const detailUrl = `/detail/${photo.id}`;

        return `
            <div class="col-12 col-sm-6 col-md-4 col-lg-3 mb-4">
                <div class="card photo-card h-100">
                    <a href="${detailUrl}" class="photo-link">
                        <img src="${photoUrl}" class="card-img-top" alt="${photo.originalFileName}" loading="eager">
                    </a>
                    <div class="card-body">
                        <p class="card-text text-truncate" title="${photo.originalFileName}">
                            <small><a href="${detailUrl}" class="text-decoration-none text-dark">${photo.originalFileName}</a></small>
                        </p>
                        <p class="card-text">
                            <small class="text-muted">${formattedDate}</small>
                        </p>
                        <p class="card-text">
                            <small class="text-muted">
                                ${Math.round(photo.fileSize / 1024)} KB${dimensions}
                            </small>
                        </p>
                    </div>
                </div>
            </div>
        `;
    }

    function showSuccess(message) {
        uploadSuccess.textContent = message;
        uploadSuccess.classList.remove('d-none');

        // Auto-hide after 5 seconds
        setTimeout(() => {
            uploadSuccess.classList.add('d-none');
        }, 5000);
    }

    function showErrors(errors) {
        uploadErrors.innerHTML = '<strong>Upload errors:</strong><ul class="mb-0 mt-2">' +
            errors.map(e => `<li>${e}</li>`).join('') +
            '</ul>';
        uploadErrors.classList.remove('d-none');
    }
})();