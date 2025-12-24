import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

/// Top-level function to handle background messages
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling background message: ${message.messageId}');
}

class FcmService {
  final FirebaseMessaging _firebaseMessaging;
  final FlutterLocalNotificationsPlugin _localNotifications;

  final StreamController<RemoteMessage> _messageStreamController =
      StreamController<RemoteMessage>.broadcast();

  Stream<RemoteMessage> get messageStream => _messageStreamController.stream;

  FcmService(this._firebaseMessaging, this._localNotifications);

  /// Initialize FCM and local notifications
  Future<void> initialize() async {
    try {
      // Check if FCM is supported on this platform
      if (!_isFcmSupported()) {
        print(
          'FCM is not supported on this platform (Windows/Linux/macOS desktop)',
        );
        // Only initialize local notifications for unsupported platforms
        await _initializeLocalNotifications();
        return;
      }

      // Set up background message handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Request permission
      await requestPermission();

      // Get FCM token
      final token = await _firebaseMessaging.getToken();
      print('FCM Token: $token');

      // Listen to token refresh
      _firebaseMessaging.onTokenRefresh.listen((token) {
        print('FCM Token refreshed: $token');
      });

      // Handle foreground messages - will be caught by NotificationHandler
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Foreground message received: ${message.messageId}');
        _messageStreamController.add(message);
        _showLocalNotification(message);
      });

      // Handle notification when app is opened from background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('Message opened app: ${message.messageId}');
        _messageStreamController.add(message);
      });

      // Handle notification when app is opened from terminated state
      _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
        if (message != null) {
          print('App opened from terminated state: ${message.messageId}');
          _messageStreamController.add(message);
        }
      });
    } catch (e) {
      print('Error initializing FCM: $e');
      // Initialize local notifications even if FCM fails
      await _initializeLocalNotifications();
    }
  }

  /// Check if FCM is supported on current platform
  bool _isFcmSupported() {
    // FCM is supported on Android and iOS
    try {
      // Check if running on mobile platforms
      return Platform.isAndroid || Platform.isIOS;
    } catch (e) {
      // If Platform is not available, assume unsupported
      return false;
    }
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          final payload = jsonDecode(response.payload!);
          print('Notification tapped: $payload');
          // Handle notification tap
        }
      },
    );
  }

  /// Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;

    if (notification != null) {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription:
                'This channel is used for important notifications.',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: true,
            styleInformation: BigTextStyleInformation(''),
          );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        platformChannelSpecifics,
        payload: jsonEncode(message.data),
      );
    }
  }

  /// Request permission for notifications
  Future<NotificationSettings?> requestPermission() async {
    if (!_isFcmSupported()) {
      print('FCM not supported on this platform, skipping permission request');
      return null;
    }

    try {
      NotificationSettings settings = await _firebaseMessaging
          .requestPermission(
            alert: true,
            announcement: false,
            badge: true,
            carPlay: false,
            criticalAlert: false,
            provisional: false,
            sound: true,
          );

      print('User granted permission: ${settings.authorizationStatus}');
      return settings;
    } catch (e) {
      print('Error requesting permission: $e');
      return null;
    }
  }

  /// Get FCM token
  Future<String?> getToken() async {
    if (!_isFcmSupported()) {
      print('FCM token not available on this platform');
      return null;
    }

    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    if (!_isFcmSupported()) {
      print('FCM not supported on this platform');
      return;
    }

    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print('Subscribed to topic: $topic');
    } catch (e) {
      print('Error subscribing to topic: $e');
      rethrow;
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    if (!_isFcmSupported()) {
      print('FCM not supported on this platform');
      return;
    }

    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('Unsubscribed from topic: $topic');
    } catch (e) {
      print('Error unsubscribing from topic: $e');
      rethrow;
    }
  }

  /// Show scheduled notification
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    try {
      await _localNotifications.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'scheduled_channel',
            'Scheduled Notifications',
            channelDescription:
                'This channel is used for scheduled notifications.',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        // uiLocalNotificationDateInterpretation:
        //     UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
    } catch (e) {
      print('Error scheduling notification: $e');
      rethrow;
    }
  }

  /// Cancel notification
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// Dispose
  void dispose() {
    _messageStreamController.close();
  }
}
