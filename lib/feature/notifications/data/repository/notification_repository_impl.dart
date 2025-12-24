import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repository/notification_repository.dart';
import '../models/notification_model.dart';
import '../services/fcm_service.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FcmService _fcmService;

  NotificationRepositoryImpl(
    this._firestore,
    this._auth,
    this._fcmService,
  );

  String? get _userId => _auth.currentUser?.uid;

  CollectionReference get _notificationsCollection =>
      _firestore.collection('users/$_userId/notifications');

  @override
  Future<String?> getFcmToken() async {
    try {
      return await _fcmService.getToken();
    } catch (e) {
      print('Error getting FCM token: $e');
      rethrow;
    }
  }

  @override
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _fcmService.subscribeToTopic(topic);
    } catch (e) {
      print('Error subscribing to topic: $e');
      rethrow;
    }
  }

  @override
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _fcmService.unsubscribeFromTopic(topic);
    } catch (e) {
      print('Error unsubscribing from topic: $e');
      rethrow;
    }
  }

  @override
  Future<List<NotificationEntity>> getNotifications() async {
    try {
      if (_userId == null) {
        throw Exception('User not authenticated');
      }

      final querySnapshot = await _notificationsCollection
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      return querySnapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting notifications: $e');
      rethrow;
    }
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      if (_userId == null) {
        throw Exception('User not authenticated');
      }

      final querySnapshot = await _notificationsCollection
          .where('isRead', isEqualTo: false)
          .count()
          .get();

      return querySnapshot.count ?? 0;
    } catch (e) {
      print('Error getting unread count: $e');
      rethrow;
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      if (_userId == null) {
        throw Exception('User not authenticated');
      }

      await _notificationsCollection.doc(notificationId).update({
        'isRead': true,
      });
    } catch (e) {
      print('Error marking notification as read: $e');
      rethrow;
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      if (_userId == null) {
        throw Exception('User not authenticated');
      }

      final querySnapshot = await _notificationsCollection
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (var doc in querySnapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      print('Error marking all notifications as read: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    try {
      if (_userId == null) {
        throw Exception('User not authenticated');
      }

      await _notificationsCollection.doc(notificationId).delete();
    } catch (e) {
      print('Error deleting notification: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteAllNotifications() async {
    try {
      if (_userId == null) {
        throw Exception('User not authenticated');
      }

      final querySnapshot = await _notificationsCollection.get();

      final batch = _firestore.batch();
      for (var doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      print('Error deleting all notifications: $e');
      rethrow;
    }
  }

  @override
  Future<void> saveNotification(NotificationEntity notification) async {
    try {
      if (_userId == null) {
        throw Exception('User not authenticated');
      }

      final notificationModel = NotificationModel.fromEntity(notification);
      await _notificationsCollection
          .doc(notification.id)
          .set(notificationModel.toFirestore());
    } catch (e) {
      print('Error saving notification: $e');
      rethrow;
    }
  }

  @override
  Stream<List<NotificationEntity>> watchNotifications() {
    if (_userId == null) {
      return Stream.value([]);
    }

    return _notificationsCollection
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromFirestore(doc))
            .toList());
  }

  @override
  Future<bool> requestPermission() async {
    try {
      final settings = await _fcmService.requestPermission();
      return settings?.authorizationStatus == AuthorizationStatus.authorized ||
          settings?.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e) {
      print('Error requesting permission: $e');
      return false;
    }
  }
}
