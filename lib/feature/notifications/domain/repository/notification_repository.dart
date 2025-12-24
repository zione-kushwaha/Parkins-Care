import '../entities/notification_entity.dart';

abstract class NotificationRepository {
  /// Get FCM token for this device
  Future<String?> getFcmToken();

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic);

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic);

  /// Get all notifications for current user
  Future<List<NotificationEntity>> getNotifications();

  /// Get unread notification count
  Future<int> getUnreadCount();

  /// Mark notification as read
  Future<void> markAsRead(String notificationId);

  /// Mark all notifications as read
  Future<void> markAllAsRead();

  /// Delete notification
  Future<void> deleteNotification(String notificationId);

  /// Delete all notifications
  Future<void> deleteAllNotifications();

  /// Save notification to Firestore
  Future<void> saveNotification(NotificationEntity notification);

  /// Stream of notifications
  Stream<List<NotificationEntity>> watchNotifications();

  /// Request notification permission
  Future<bool> requestPermission();
}
