using System;
using Microsoft.EntityFrameworkCore;
using System.Linq;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Http;
using System.IO;
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

        public CoursesController(SchoolContext db, NotificationService notificationService,
            BlobServiceClient blobServiceClient, IConfiguration configuration)
            : base(db, notificationService)
        {
            _blobServiceClient = blobServiceClient;
            _containerName = configuration["AzureStorageBlob:ContainerName"] ?? "teaching-materials";
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
        public IActionResult Create([Bind("CourseID,Title,Credits,DepartmentID,TeachingMaterialImagePath")] Course course, IFormFile teachingMaterialImage)
        {
            if (ModelState.IsValid)
            {
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
                        var blobName = $"course_{course.CourseID}_{Guid.NewGuid()}{fileExtension}";
                        var containerClient = _blobServiceClient.GetBlobContainerClient(_containerName);
                        containerClient.CreateIfNotExists(PublicAccessType.Blob);
                        var blobClient = containerClient.GetBlobClient(blobName);
                        using (var stream = teachingMaterialImage.OpenReadStream())
                        {
                            blobClient.Upload(stream, overwrite: true);
                        }
                        course.TeachingMaterialImagePath = blobClient.Uri.ToString();
                    }
                    catch (Exception ex)
                    {
                        ModelState.AddModelError("teachingMaterialImage", "Error uploading file: " + ex.Message);
                        ViewBag.DepartmentID = new Microsoft.AspNetCore.Mvc.Rendering.SelectList(db.Departments, "DepartmentID", "Name", course.DepartmentID);
                        return View(course);
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
        public IActionResult Edit([Bind("CourseID,Title,Credits,DepartmentID,TeachingMaterialImagePath")] Course course, IFormFile teachingMaterialImage)
        {
            if (ModelState.IsValid)
            {
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
                                var oldUri = new Uri(course.TeachingMaterialImagePath);
                                var oldBlobName = Path.GetFileName(oldUri.LocalPath);
                                var containerClient = _blobServiceClient.GetBlobContainerClient(_containerName);
                                containerClient.GetBlobClient(oldBlobName).DeleteIfExists();
                            }
                            catch { }
                        }
                        var blobName = $"course_{course.CourseID}_{Guid.NewGuid()}{fileExtension}";
                        var container = _blobServiceClient.GetBlobContainerClient(_containerName);
                        container.CreateIfNotExists(PublicAccessType.Blob);
                        var blobClient = container.GetBlobClient(blobName);
                        using (var stream = teachingMaterialImage.OpenReadStream())
                        {
                            blobClient.Upload(stream, overwrite: true);
                        }
                        course.TeachingMaterialImagePath = blobClient.Uri.ToString();
                    }
                    catch (Exception ex)
                    {
                        ModelState.AddModelError("teachingMaterialImage", "Error uploading file: " + ex.Message);
                        ViewBag.DepartmentID = new Microsoft.AspNetCore.Mvc.Rendering.SelectList(db.Departments, "DepartmentID", "Name", course.DepartmentID);
                        return View(course);
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
                    var oldUri = new Uri(course.TeachingMaterialImagePath);
                    var oldBlobName = Path.GetFileName(oldUri.LocalPath);
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

        protected override void Dispose(bool disposing)
        {
            if (disposing) { }
            base.Dispose(disposing);
        }
    }
}
