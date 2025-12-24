import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/notification_model.dart';

class NotificationHandler {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  NotificationHandler(this._firestore, this._auth);

  /// Save incoming FCM notification to Firestore
  Future<void> saveNotificationToFirestore(RemoteMessage message) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        print('User not authenticated, cannot save notification');
        return;
      }

      final notificationId =
          message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString();

      final notificationModel = NotificationModel.fromRemoteMessage(
        notificationId,
        {
          'notification': {
            'title': message.notification?.title,
            'body': message.notification?.body,
            'image': message.notification?.android?.imageUrl,
          },
          'data': message.data,
        },
      );

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(notificationId)
          .set(notificationModel.toFirestore());

      print('Notification saved to Firestore: $notificationId');
    } catch (e) {
      print('Error saving notification to Firestore: $e');
    }
  }

  /// Handle foreground message
  Future<void> handleForegroundMessage(RemoteMessage message) async {
    print('Handling foreground message: ${message.messageId}');
    await saveNotificationToFirestore(message);
  }

  /// Handle background message (called from top-level function)
  static Future<void> handleBackgroundMessage(RemoteMessage message) async {
    print('Handling background message: ${message.messageId}');
    // Background messages are handled by the top-level function
    // We'll save them when the user opens the app
  }

  /// Handle notification tap
  Future<void> handleNotificationTap(RemoteMessage message) async {
    print('Notification tapped: ${message.messageId}');
    await saveNotificationToFirestore(message);
    // Navigate to specific screen based on data
    // This can be handled in the UI layer
  }
}
