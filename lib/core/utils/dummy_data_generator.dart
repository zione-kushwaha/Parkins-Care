import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../feature/reminders/domain/entities/reminder.dart';
import '../../feature/reminders/data/models/reminder_model.dart';
import '../../feature/notifications/data/models/notification_model.dart';

class DummyDataGenerator {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  DummyDataGenerator({required this.firestore, required this.auth});

  String get _userId => auth.currentUser?.uid ?? '';

  /// Clear all existing dummy data (reminders and notifications)
  Future<void> clearAllData() async {
    if (_userId.isEmpty) {
      print('No user logged in. Cannot clear data.');
      return;
    }

    try {
      print('Clearing existing reminders...');
      final remindersCollection = firestore
          .collection('users')
          .doc(_userId)
          .collection('reminders');
      
      final reminders = await remindersCollection.get();
      for (final doc in reminders.docs) {
        await doc.reference.delete();
      }
      print('✅ Cleared ${reminders.docs.length} reminders');

      print('Clearing existing notifications...');
      final notificationsCollection = firestore
          .collection('users')
          .doc(_userId)
          .collection('notifications');
      
      final notifications = await notificationsCollection.get();
      for (final doc in notifications.docs) {
        await doc.reference.delete();
      }
      print('✅ Cleared ${notifications.docs.length} notifications');
      
      print('✅ All data cleared successfully!');
    } catch (e) {
      print('❌ Error clearing data: $e');
      rethrow;
    }
  }

  /// Add dummy reminders to Firestore
  Future<void> addDummyReminders({bool force = false}) async {
    if (_userId.isEmpty) {
      print('No user logged in. Cannot add dummy data.');
      return;
    }

    final now = DateTime.now();
    final remindersCollection = firestore
        .collection('users')
        .doc(_userId)
        .collection('reminders');

    // Check if reminders already exist
    final existingReminders = await remindersCollection.limit(1).get();
    if (existingReminders.docs.isNotEmpty && !force) {
      print('Reminders already exist. Skipping dummy data generation.');
      return;
    }

    final dummyReminders = [
      Reminder(
        id: '',
        title: 'Take Morning Medication',
        description: 'Levodopa 100mg - Take with breakfast',
        dateTime: DateTime(now.year, now.month, now.day, 8, 0),
        type: 'medication',
        isRecurring: true,
        recurringPattern: 'daily',
        isCompleted: false,
        createdAt: now,
      ),
      Reminder(
        id: '',
        title: 'Evening Medication',
        description: 'Carbidopa 25mg - Take after dinner',
        dateTime: DateTime(now.year, now.month, now.day, 20, 0),
        type: 'medication',
        isRecurring: true,
        recurringPattern: 'daily',
        isCompleted: false,
        createdAt: now,
      ),
      Reminder(
        id: '',
        title: 'Physical Therapy Session',
        description: 'Weekly PT appointment with Dr. Sarah',
        dateTime: now.add(const Duration(days: 2, hours: 10)),
        type: 'appointment',
        isRecurring: true,
        recurringPattern: 'weekly',
        isCompleted: false,
        createdAt: now,
      ),
      Reminder(
        id: '',
        title: 'Morning Exercise',
        description: '30 minutes of light stretching and walking',
        dateTime: DateTime(now.year, now.month, now.day + 1, 7, 30),
        type: 'exercise',
        isRecurring: true,
        recurringPattern: 'daily',
        isCompleted: false,
        createdAt: now,
      ),
      Reminder(
        id: '',
        title: 'Neurologist Appointment',
        description: 'Quarterly checkup with Dr. Johnson',
        dateTime: now.add(const Duration(days: 7)),
        type: 'appointment',
        isRecurring: false,
        isCompleted: false,
        createdAt: now,
      ),
      Reminder(
        id: '',
        title: 'Afternoon Medication',
        description: 'Pramipexole 0.5mg',
        dateTime: DateTime(now.year, now.month, now.day, 14, 0),
        type: 'medication',
        isRecurring: true,
        recurringPattern: 'daily',
        isCompleted: false,
        createdAt: now,
      ),
      Reminder(
        id: '',
        title: 'Balance Training',
        description: 'Practice balance exercises for 20 minutes',
        dateTime: now.add(const Duration(days: 1, hours: 15)),
        type: 'exercise',
        isRecurring: false,
        isCompleted: false,
        createdAt: now,
      ),
      Reminder(
        id: '',
        title: 'Blood Test',
        description: 'Fasting blood work at LabCorp',
        dateTime: now.add(const Duration(days: 3, hours: 8)),
        type: 'appointment',
        isRecurring: false,
        isCompleted: false,
        createdAt: now,
      ),
    ];

    print('Adding ${dummyReminders.length} dummy reminders...');

    for (final reminder in dummyReminders) {
      final model = ReminderModel(
        id: '',
        title: reminder.title,
        description: reminder.description,
        dateTime: reminder.dateTime,
        type: reminder.type,
        isRecurring: reminder.isRecurring,
        recurringPattern: reminder.recurringPattern,
        isCompleted: reminder.isCompleted,
        createdAt: reminder.createdAt,
      );

      await remindersCollection.add(model.toJson());
    }

    print('✅ Dummy reminders added successfully!');
  }

  /// Add dummy notifications to Firestore
  Future<void> addDummyNotifications({bool force = false}) async {
    if (_userId.isEmpty) {
      print('No user logged in. Cannot add dummy notifications.');
      return;
    }

    final now = DateTime.now();
    final notificationsCollection = firestore
        .collection('users')
        .doc(_userId)
        .collection('notifications');

    // Check if notifications already exist
    final existingNotifications = await notificationsCollection.limit(1).get();
    if (existingNotifications.docs.isNotEmpty && !force) {
      print('Notifications already exist. Skipping dummy data generation.');
      return;
    }

    final dummyNotifications = [
      NotificationModel(
        id: '',
        title: 'Welcome to Parkins Care! 👋',
        body:
            'Your health companion for managing Parkinson\'s disease. Stay on track with your medications and appointments.',
        timestamp: now.subtract(const Duration(hours: 2)),
        isRead: false,
        type: 'welcome',
      ),
      NotificationModel(
        id: '',
        title: 'Medication Reminder Set ⏰',
        body:
            'Your morning medication reminder has been scheduled for 8:00 AM daily.',
        timestamp: now.subtract(const Duration(hours: 1)),
        isRead: false,
        type: 'reminder',
      ),
      NotificationModel(
        id: '',
        title: 'Exercise Time! 🏃',
        body:
            'Don\'t forget your morning exercise routine. Start your day with light stretching!',
        timestamp: now.subtract(const Duration(minutes: 30)),
        isRead: false,
        type: 'exercise',
      ),
      NotificationModel(
        id: '',
        title: 'Appointment Tomorrow 📅',
        body:
            'You have a physical therapy session scheduled for tomorrow at 10:00 AM.',
        timestamp: now.subtract(const Duration(minutes: 15)),
        isRead: false,
        type: 'appointment',
      ),
      NotificationModel(
        id: '',
        title: 'Tremor Monitoring Active 📊',
        body:
            'Tremor detection is now active. Your device will monitor and log tremor activity.',
        timestamp: now.subtract(const Duration(days: 1)),
        isRead: true,
        type: 'system',
      ),
      NotificationModel(
        id: '',
        title: 'Weekly Progress Report 📈',
        body:
            'Great job this week! You completed 90% of your medication reminders on time.',
        timestamp: now.subtract(const Duration(days: 2)),
        isRead: true,
        type: 'progress',
      ),
      NotificationModel(
        id: '',
        title: 'New Feature Available ✨',
        body:
            'Check out the new tremor history tracking feature in your dashboard!',
        timestamp: now.subtract(const Duration(days: 3)),
        isRead: true,
        type: 'update',
      ),
    ];

    print('Adding ${dummyNotifications.length} dummy notifications...');

    for (final notification in dummyNotifications) {
      await notificationsCollection.add(notification.toFirestore());
    }

    print('✅ Dummy notifications added successfully!');
  }

  /// Add all dummy data at once
  Future<void> addAllDummyData({bool force = false}) async {
    try {
      await addDummyReminders(force: force);
      await addDummyNotifications(force: force);
      print('✅ All dummy data added successfully!');
    } catch (e) {
      print('❌ Error adding dummy data: $e');
      rethrow;
    }
  }
  
  /// Clear and regenerate all dummy data
  Future<void> regenerateAllData() async {
    try {
      await clearAllData();
      await addAllDummyData(force: true);
      print('✅ All dummy data regenerated successfully!');
    } catch (e) {
      print('❌ Error regenerating dummy data: $e');
      rethrow;
    }
  }
}
