using System;
using Microsoft.EntityFrameworkCore;
using System.Linq;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Http;
using System.IO;
using System.Threading.Tasks;
using Azure.Storage.Blobs;
using Azure.Storage.Blobs.Models;
using ContosoUniversity.Data;
using ContosoUniversity.Models;
using ContosoUniversity.Services;
using Microsoft.Extensions.Configuration;

namespace ContosoUniversity.Controllers
{
    public class CoursesController : BaseController
    {
        private readonly BlobServiceClient _blobServiceClient;
        private readonly string _containerName;
        private readonly ICourseContentAiService _aiService;

        public CoursesController(SchoolContext db, NotificationService notificationService,
            BlobServiceClient blobServiceClient, IConfiguration configuration,
            ICourseContentAiService aiService)
            : base(db, notificationService)
        {
            _blobServiceClient = blobServiceClient;
            _containerName = configuration["AzureStorageBlob:ContainerName"] ?? "teaching-materials";
            _aiService = aiService;
        }

        public IActionResult Index()
        {
            var courses = db.Courses.Include(c => c.Department);
            return View(courses.ToList());
        }

        public IActionResult Details(int? id)
        {
            if (id == null) return BadRequest();
            Course course = db.Courses.Include(c => c.Department).Where(c => c.CourseID == id).Single();
            if (course == null) return NotFound();
            return View(course);
        }

        public IActionResult Create()
        {
            ViewBag.DepartmentID = new Microsoft.AspNetCore.Mvc.Rendering.SelectList(db.Departments, "DepartmentID", "Name");
            return View(new Course());
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create([Bind("CourseID,Title,Credits,DepartmentID,TeachingMaterialImagePath,Description,LearningObjectives,AltText")] Course course, IFormFile teachingMaterialImage)
        {
            if (ModelState.IsValid)
            {
                byte[] uploadedBytes = null;
                string uploadedMimeType = null;
                if (teachingMaterialImage != null && teachingMaterialImage.Length > 0)
                {
                    var allowedExtensions = new[] { ".jpg", ".jpeg", ".png", ".gif", ".bmp" };
                    var fileExtension = Path.GetExtension(teachingMaterialImage.FileName).ToLower();
                    if (!allowedExtensions.Contains(fileExtension))
                    {
                        ModelState.AddModelError("teachingMaterialImage", "Please upload a valid image file (jpg, jpeg, png, gif, bmp).");
                        ViewBag.DepartmentID = new Microsoft.AspNetCore.Mvc.Rendering.SelectList(db.Departments, "DepartmentID", "Name", course.DepartmentID);
                        return View(course);
                    }
                    if (teachingMaterialImage.Length > 5 * 1024 * 1024)
                    {
                        ModelState.AddModelError("teachingMaterialImage", "File size must be less than 5MB.");
                        ViewBag.DepartmentID = new Microsoft.AspNetCore.Mvc.Rendering.SelectList(db.Departments, "DepartmentID", "Name", course.DepartmentID);
                        return View(course);
                    }
                    try
                    {
                        using (var ms = new MemoryStream())
                        {
                            await teachingMaterialImage.CopyToAsync(ms);
                            uploadedBytes = ms.ToArray();
                        }
                        uploadedMimeType = teachingMaterialImage.ContentType;
                        var blobName = $"course_{course.CourseID}_{Guid.NewGuid()}{fileExtension}";
                        var containerClient = _blobServiceClient.GetBlobContainerClient(_containerName);
                        containerClient.CreateIfNotExists();
                        var blobClient = containerClient.GetBlobClient(blobName);
                        using (var stream = new MemoryStream(uploadedBytes))
                        {
                            blobClient.Upload(stream, overwrite: true);
                        }
                        course.TeachingMaterialImagePath = blobName;
                    }
                    catch (Exception ex)
                    {
                        ModelState.AddModelError("teachingMaterialImage", "Error uploading file: " + ex.Message);
                        ViewBag.DepartmentID = new Microsoft.AspNetCore.Mvc.Rendering.SelectList(db.Departments, "DepartmentID", "Name", course.DepartmentID);
                        return View(course);
                    }
                }

                // Best-effort AI enrichment. Never blocks the save.
                if (uploadedBytes != null && _aiService != null)
                {
                    var suggestion = await _aiService.AnalyzeAsync(uploadedBytes, uploadedMimeType, course.Title);
                    if (suggestion != null)
                    {
                        if (string.IsNullOrWhiteSpace(course.Description)) course.Description = suggestion.Description;
                        if (string.IsNullOrWhiteSpace(course.AltText)) course.AltText = suggestion.AltText;
                        if (string.IsNullOrWhiteSpace(course.LearningObjectives) && suggestion.LearningObjectives != null)
                        {
                            course.LearningObjectives = string.Join("\n", suggestion.LearningObjectives);
                        }
                    }
                }

                db.Courses.Add(course);
                db.SaveChanges();
                SendEntityNotification("Course", course.CourseID.ToString(), course.Title, EntityOperation.CREATE);
                return RedirectToAction("Index");
            }
            ViewBag.DepartmentID = new Microsoft.AspNetCore.Mvc.Rendering.SelectList(db.Departments, "DepartmentID", "Name", course.DepartmentID);
            return View(course);
        }

        public IActionResult Edit(int? id)
        {
            if (id == null) return BadRequest();
            Course course = db.Courses.Find(id);
            if (course == null) return NotFound();
            ViewBag.DepartmentID = new Microsoft.AspNetCore.Mvc.Rendering.SelectList(db.Departments, "DepartmentID", "Name", course.DepartmentID);
            return View(course);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit([Bind("CourseID,Title,Credits,DepartmentID,TeachingMaterialImagePath,Description,LearningObjectives,AltText")] Course course, IFormFile teachingMaterialImage)
        {
            if (ModelState.IsValid)
            {
                byte[] uploadedBytes = null;
                string uploadedMimeType = null;
                if (teachingMaterialImage != null && teachingMaterialImage.Length > 0)
                {
                    var allowedExtensions = new[] { ".jpg", ".jpeg", ".png", ".gif", ".bmp" };
                    var fileExtension = Path.GetExtension(teachingMaterialImage.FileName).ToLower();
                    if (!allowedExtensions.Contains(fileExtension))
                    {
                        ModelState.AddModelError("teachingMaterialImage", "Please upload a valid image file (jpg, jpeg, png, gif, bmp).");
                        ViewBag.DepartmentID = new Microsoft.AspNetCore.Mvc.Rendering.SelectList(db.Departments, "DepartmentID", "Name", course.DepartmentID);
                        return View(course);
                    }
                    if (teachingMaterialImage.Length > 5 * 1024 * 1024)
                    {
                        ModelState.AddModelError("teachingMaterialImage", "File size must be less than 5MB.");
                        ViewBag.DepartmentID = new Microsoft.AspNetCore.Mvc.Rendering.SelectList(db.Departments, "DepartmentID", "Name", course.DepartmentID);
                        return View(course);
                    }
                    try
                    {
                        if (!string.IsNullOrEmpty(course.TeachingMaterialImagePath))
                        {
                            try
                            {
                                // Support both stored blob names and legacy full URIs
                                var oldBlobName = course.TeachingMaterialImagePath.StartsWith("http")
                                    ? Path.GetFileName(new Uri(course.TeachingMaterialImagePath).LocalPath)
                                    : course.TeachingMaterialImagePath;
                                var containerClient = _blobServiceClient.GetBlobContainerClient(_containerName);
                                containerClient.GetBlobClient(oldBlobName).DeleteIfExists();
                            }
                            catch { }
                        }
                        using (var ms = new MemoryStream())
                        {
                            await teachingMaterialImage.CopyToAsync(ms);
                            uploadedBytes = ms.ToArray();
                        }
                        uploadedMimeType = teachingMaterialImage.ContentType;
                        var blobName = $"course_{course.CourseID}_{Guid.NewGuid()}{fileExtension}";
                        var container = _blobServiceClient.GetBlobContainerClient(_containerName);
                        container.CreateIfNotExists();
                        var blobClient = container.GetBlobClient(blobName);
                        using (var stream = new MemoryStream(uploadedBytes))
                        {
                            blobClient.Upload(stream, overwrite: true);
                        }
                        course.TeachingMaterialImagePath = blobName;
                    }
                    catch (Exception ex)
                    {
                        ModelState.AddModelError("teachingMaterialImage", "Error uploading file: " + ex.Message);
                        ViewBag.DepartmentID = new Microsoft.AspNetCore.Mvc.Rendering.SelectList(db.Departments, "DepartmentID", "Name", course.DepartmentID);
                        return View(course);
                    }
                }

                // Best-effort AI enrichment when a new image was uploaded.
                if (uploadedBytes != null && _aiService != null)
                {
                    var suggestion = await _aiService.AnalyzeAsync(uploadedBytes, uploadedMimeType, course.Title);
                    if (suggestion != null)
                    {
                        if (string.IsNullOrWhiteSpace(course.Description)) course.Description = suggestion.Description;
                        if (string.IsNullOrWhiteSpace(course.AltText)) course.AltText = suggestion.AltText;
                        if (string.IsNullOrWhiteSpace(course.LearningObjectives) && suggestion.LearningObjectives != null)
                        {
                            course.LearningObjectives = string.Join("\n", suggestion.LearningObjectives);
                        }
                    }
                }

                db.Entry(course).State = EntityState.Modified;
                db.SaveChanges();
                SendEntityNotification("Course", course.CourseID.ToString(), course.Title, EntityOperation.UPDATE);
                return RedirectToAction("Index");
            }
            ViewBag.DepartmentID = new Microsoft.AspNetCore.Mvc.Rendering.SelectList(db.Departments, "DepartmentID", "Name", course.DepartmentID);
            return View(course);
        }

        public IActionResult Delete(int? id)
        {
            if (id == null) return BadRequest();
            Course course = db.Courses.Include(c => c.Department).Where(c => c.CourseID == id).Single();
            if (course == null) return NotFound();
            return View(course);
        }

        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public IActionResult DeleteConfirmed(int id)
        {
            Course course = db.Courses.Find(id);
            var courseTitle = course.Title;
            if (!string.IsNullOrEmpty(course.TeachingMaterialImagePath))
            {
                try
                {
                    // Support both stored blob names and legacy full URIs
                    var oldBlobName = course.TeachingMaterialImagePath.StartsWith("http")
                        ? Path.GetFileName(new Uri(course.TeachingMaterialImagePath).LocalPath)
                        : course.TeachingMaterialImagePath;
                    var containerClient = _blobServiceClient.GetBlobContainerClient(_containerName);
                    containerClient.GetBlobClient(oldBlobName).DeleteIfExists();
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine($"Error deleting blob: {ex.Message}");
                }
            }
            db.Courses.Remove(course);
            db.SaveChanges();
            SendEntityNotification("Course", id.ToString(), courseTitle, EntityOperation.DELETE);
            return RedirectToAction("Index");
        }

        [HttpGet]
        public async Task<IActionResult> Image(string name)
        {
            if (string.IsNullOrEmpty(name)) return NotFound();
            try
            {
                // Support legacy full URIs stored before this fix
                var blobName = name.StartsWith("http")
                    ? Path.GetFileName(new Uri(name).LocalPath)
                    : name;
                var containerClient = _blobServiceClient.GetBlobContainerClient(_containerName);
                var blobClient = containerClient.GetBlobClient(blobName);
                var response = await blobClient.DownloadStreamingAsync();
                var contentType = response.Value.Details.ContentType ?? "application/octet-stream";
                return File(response.Value.Content, contentType);
            }
            catch
            {
                return NotFound();
            }
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing) { }
            base.Dispose(disposing);
        }
    }
}
