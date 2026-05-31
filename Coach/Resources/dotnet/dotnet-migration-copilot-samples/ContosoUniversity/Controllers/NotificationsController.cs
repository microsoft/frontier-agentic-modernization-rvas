using System;
using System.Collections.Generic;
using System.Text.Json;
using Microsoft.AspNetCore.Mvc;
using ContosoUniversity.Data;
using ContosoUniversity.Services;
using ContosoUniversity.Models;

namespace ContosoUniversity.Controllers
{
    public class NotificationsController : BaseController
    {
        private static readonly JsonSerializerOptions _pascalCaseOptions = new JsonSerializerOptions
        {
            PropertyNamingPolicy = null  // null = PascalCase (no renaming)
        };

        public NotificationsController(SchoolContext db, NotificationService notificationService)
            : base(db, notificationService)
        {
        }

        // GET: api/notifications - Get pending notifications for admin
        [HttpGet]
        public JsonResult GetNotifications()
        {
            var notifications = new List<Notification>();

            try
            {
                Notification notification;
                while ((notification = notificationService.ReceiveNotification()) != null)
                {
                    notifications.Add(notification);

                    if (notifications.Count >= 10)
                        break;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error retrieving notifications: {ex.Message}");
                return Json(new { success = false, message = "Error retrieving notifications" });
            }

            return Json(new
            {
                success = true,
                notifications = notifications,
                count = notifications.Count
            }, _pascalCaseOptions);
        }

        // POST: api/notifications/mark-read
        [HttpPost]
        public JsonResult MarkAsRead(int id)
        {
            try
            {
                notificationService.MarkAsRead(id);
                return Json(new { success = true });
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error marking notification as read: {ex.Message}");
                return Json(new { success = false, message = "Error updating notification" });
            }
        }

        // GET: Notifications/Index - Admin notification dashboard
        public IActionResult Index()
        {
            return View();
        }
    }
}
