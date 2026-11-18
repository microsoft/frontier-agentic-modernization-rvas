using System;
using System.Threading.Tasks;
using Azure.Identity;
using Azure.Messaging.ServiceBus;
using ContosoUniversity.Models;
using Microsoft.Extensions.Configuration;
using Newtonsoft.Json;

namespace ContosoUniversity.Services
{
    public class NotificationService : IDisposable
    {
        private readonly ServiceBusClient _client;
        private readonly ServiceBusSender _sender;
        private readonly ServiceBusReceiver _receiver;
        private readonly string _queueName;
        private bool _disposed = false;

        public NotificationService(IConfiguration configuration)
        {
            _queueName = configuration["AzureServiceBus:QueueName"] ?? "contoso-university-notifications";
            var fullyQualifiedNamespace = configuration["AzureServiceBus:FullyQualifiedNamespace"];

            if (!string.IsNullOrEmpty(fullyQualifiedNamespace))
            {
                _client = new ServiceBusClient(fullyQualifiedNamespace, new DefaultAzureCredential());
            }
            else
            {
                // Fallback: use connection string for local development
                var connectionString = configuration["AzureServiceBus:ConnectionString"];
                if (!string.IsNullOrEmpty(connectionString))
                {
                    _client = new ServiceBusClient(connectionString);
                }
            }

            if (_client != null)
            {
                _sender = _client.CreateSender(_queueName);
                _receiver = _client.CreateReceiver(_queueName, new ServiceBusReceiverOptions
                {
                    ReceiveMode = ServiceBusReceiveMode.ReceiveAndDelete
                });
            }
        }

        public void SendNotification(string entityType, string entityId, EntityOperation operation, string userName = null)
        {
            SendNotification(entityType, entityId, null, operation, userName);
        }

        public void SendNotification(string entityType, string entityId, string entityDisplayName, EntityOperation operation, string userName = null)
        {
            try
            {
                SendNotificationAsync(entityType, entityId, entityDisplayName, operation, userName)
                    .GetAwaiter().GetResult();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Failed to send notification: {ex.Message}");
            }
        }

        public async Task SendNotificationAsync(string entityType, string entityId, string entityDisplayName, EntityOperation operation, string userName = null)
        {
            if (_sender == null) return;

            try
            {
                var notification = new Notification
                {
                    EntityType = entityType,
                    EntityId = entityId,
                    Operation = operation.ToString(),
                    Message = GenerateMessage(entityType, entityId, entityDisplayName, operation),
                    CreatedAt = DateTime.Now,
                    CreatedBy = userName ?? "System",
                    IsRead = false
                };

                var jsonMessage = JsonConvert.SerializeObject(notification);
                var message = new ServiceBusMessage(jsonMessage)
                {
                    Subject = $"{entityType} {operation}"
                };

                await _sender.SendMessageAsync(message);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Failed to send notification: {ex.Message}");
            }
        }

        public Notification ReceiveNotification()
        {
            try
            {
                return ReceiveNotificationAsync().GetAwaiter().GetResult();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Failed to receive notification: {ex.Message}");
                return null;
            }
        }

        public async Task<Notification> ReceiveNotificationAsync()
        {
            if (_receiver == null) return null;

            try
            {
                var receivedMessage = await _receiver.ReceiveMessageAsync(TimeSpan.FromSeconds(1));
                if (receivedMessage == null) return null;

                var jsonContent = receivedMessage.Body.ToString();
                return JsonConvert.DeserializeObject<Notification>(jsonContent);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Failed to receive notification: {ex.Message}");
                return null;
            }
        }

        public void MarkAsRead(int notificationId)
        {
            // Notifications are auto-completed on receive (ReceiveAndDelete mode)
        }

        private string GenerateMessage(string entityType, string entityId, string entityDisplayName, EntityOperation operation)
        {
            var displayText = !string.IsNullOrWhiteSpace(entityDisplayName)
                ? $"{entityType} '{entityDisplayName}'"
                : $"{entityType} (ID: {entityId})";

            switch (operation)
            {
                case EntityOperation.CREATE:
                    return $"New {displayText} has been created";
                case EntityOperation.UPDATE:
                    return $"{displayText} has been updated";
                case EntityOperation.DELETE:
                    return $"{displayText} has been deleted";
                default:
                    return $"{displayText} operation: {operation}";
            }
        }

        public void Dispose()
        {
            if (!_disposed)
            {
                _sender?.DisposeAsync().AsTask().GetAwaiter().GetResult();
                _receiver?.DisposeAsync().AsTask().GetAwaiter().GetResult();
                _client?.DisposeAsync().AsTask().GetAwaiter().GetResult();
                _disposed = true;
            }
        }
    }
}
