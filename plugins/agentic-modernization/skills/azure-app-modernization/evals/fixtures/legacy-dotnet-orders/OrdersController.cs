using System;
using System.Data.SqlClient;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Threading;
using System.Transactions;
using System.Web.Mvc;

public class OrdersController : Controller
{
    [Authorize(Roles = "OrderClerks")]
    public ActionResult Save(OrderInput input)
    {
        Session["lastCustomer"] = input.CustomerId;

        using (var scope = new TransactionScope())
        using (var connection = new SqlConnection(
            System.Configuration.ConfigurationManager.ConnectionStrings["Orders"].ConnectionString))
        {
            connection.Open();
            var command = new SqlCommand(
                "INSERT INTO Orders(CustomerId, Total) OUTPUT INSERTED.Id VALUES (@customer, @total)",
                connection);
            command.Parameters.AddWithValue("@customer", input.CustomerId);
            command.Parameters.AddWithValue("@total", input.Total);
            var orderId = (int)command.ExecuteScalar();

            WriteInvoicePreview(orderId);
            scope.Complete();

            ThreadPool.QueueUserWorkItem(_ => NotifyPartner(orderId));
            return Json(new { id = orderId });
        }
    }

    private void WriteInvoicePreview(int orderId)
    {
        var root = System.Configuration.ConfigurationManager.AppSettings["InvoiceExportPath"];
        using (var bitmap = new Bitmap(800, 600))
        {
            bitmap.Save(Path.Combine(root, orderId + ".png"), ImageFormat.Png);
        }
    }

    private void NotifyPartner(int orderId)
    {
        // Partner client is supplied by a private assembly not included in this fixture.
    }
}

public class OrderInput
{
    public string CustomerId { get; set; }
    public decimal Total { get; set; }
}
