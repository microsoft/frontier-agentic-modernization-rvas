using System;
using Microsoft.EntityFrameworkCore;
using System.Linq;
using Microsoft.AspNetCore.Mvc;
using ContosoUniversity.Data;
using ContosoUniversity.Models;
using ContosoUniversity.Services;
using System.Diagnostics;

namespace ContosoUniversity.Controllers
{
    public class StudentsController : BaseController
    {
        public StudentsController(SchoolContext db, NotificationService notificationService)
            : base(db, notificationService)
        {
        }

        public IActionResult Index(string sortOrder, string currentFilter, string searchString, int? page)
        {
            ViewBag.CurrentSort = sortOrder;
            ViewBag.NameSortParm = String.IsNullOrEmpty(sortOrder) ? "name_desc" : "";
            ViewBag.DateSortParm = sortOrder == "Date" ? "date_desc" : "Date";

            if (searchString != null)
                page = 1;
            else
                searchString = currentFilter;

            ViewBag.CurrentFilter = searchString;

            var students = from s in db.Students select s;

            if (!String.IsNullOrEmpty(searchString))
                students = students.Where(s => s.LastName.Contains(searchString) || s.FirstMidName.Contains(searchString));

            switch (sortOrder)
            {
                case "name_desc": students = students.OrderByDescending(s => s.LastName); break;
                case "Date": students = students.OrderBy(s => s.EnrollmentDate); break;
                case "date_desc": students = students.OrderByDescending(s => s.EnrollmentDate); break;
                default: students = students.OrderBy(s => s.LastName); break;
            }

            int pageSize = 10;
            int pageNumber = (page ?? 1);
            return View(PaginatedList<Student>.Create(students, pageNumber, pageSize));
        }

        public IActionResult Details(int? id)
        {
            if (id == null) return BadRequest();
            Student student = db.Students.Include(s => s.Enrollments).ThenInclude(e => e.Course).Where(s => s.ID == id).Single();
            if (student == null) return NotFound();
            return View(student);
        }

        public IActionResult Create()
        {
            return View(new Student { EnrollmentDate = DateTime.Today });
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public IActionResult Create([Bind("LastName,FirstMidName,EnrollmentDate")] Student student)
        {
            try
            {
                if (student.EnrollmentDate == DateTime.MinValue || student.EnrollmentDate == default)
                    ModelState.AddModelError("EnrollmentDate", "Please enter a valid enrollment date.");
                if (student.EnrollmentDate < new DateTime(1753, 1, 1) || student.EnrollmentDate > new DateTime(9999, 12, 31))
                    ModelState.AddModelError("EnrollmentDate", "Enrollment date must be between 1753 and 9999.");
                if (ModelState.IsValid)
                {
                    db.Students.Add(student);
                    db.SaveChanges();
                    SendEntityNotification("Student", student.ID.ToString(), $"{student.FirstMidName} {student.LastName}", EntityOperation.CREATE);
                    return RedirectToAction("Index");
                }
            }
            catch (Exception ex)
            {
                Trace.TraceError($"Error creating student: {ex.Message}");
                ModelState.AddModelError("", "Unable to save changes. Try again.");
            }
            return View(student);
        }

        public IActionResult Edit(int? id)
        {
            if (id == null) return BadRequest();
            Student student = db.Students.Find(id);
            if (student == null) return NotFound();
            return View(student);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public IActionResult Edit([Bind("ID,LastName,FirstMidName,EnrollmentDate")] Student student)
        {
            try
            {
                if (student.EnrollmentDate == DateTime.MinValue || student.EnrollmentDate == default)
                    ModelState.AddModelError("EnrollmentDate", "Please enter a valid enrollment date.");
                if (student.EnrollmentDate < new DateTime(1753, 1, 1) || student.EnrollmentDate > new DateTime(9999, 12, 31))
                    ModelState.AddModelError("EnrollmentDate", "Enrollment date must be between 1753 and 9999.");
                if (ModelState.IsValid)
                {
                    db.Entry(student).State = EntityState.Modified;
                    db.SaveChanges();
                    SendEntityNotification("Student", student.ID.ToString(), $"{student.FirstMidName} {student.LastName}", EntityOperation.UPDATE);
                    return RedirectToAction("Index");
                }
            }
            catch (Exception ex)
            {
                Trace.TraceError($"Error editing student: {ex.Message}");
                ModelState.AddModelError("", "Unable to save changes. Try again.");
            }
            return View(student);
        }

        public IActionResult Delete(int? id)
        {
            if (id == null) return BadRequest();
            Student student = db.Students.Find(id);
            if (student == null) return NotFound();
            return View(student);
        }

        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public IActionResult DeleteConfirmed(int id)
        {
            try
            {
                Student student = db.Students.Find(id);
                var studentName = $"{student.FirstMidName} {student.LastName}";
                db.Students.Remove(student);
                db.SaveChanges();
                SendEntityNotification("Student", id.ToString(), studentName, EntityOperation.DELETE);
                return RedirectToAction("Index");
            }
            catch (Exception ex)
            {
                Trace.TraceError($"Error deleting student: {ex.Message}");
                TempData["ErrorMessage"] = "Unable to delete the student. Try again.";
                return RedirectToAction("Index");
            }
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing) { }
            base.Dispose(disposing);
        }
    }
}
