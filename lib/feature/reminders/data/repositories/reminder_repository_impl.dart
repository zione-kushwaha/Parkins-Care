import '../../domain/entities/reminder.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../models/reminder_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReminderRepositoryImpl implements ReminderRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  ReminderRepositoryImpl({required this.firestore, required this.auth});

  String get _userId => auth.currentUser?.uid ?? '';

  CollectionReference get _remindersCollection =>
      firestore.collection('users').doc(_userId).collection('reminders');

  @override
  Future<List<Reminder>> getReminders() async {
    try {
      final snapshot = await _remindersCollection
          .orderBy('dateTime', descending: false)
          .get();

      return snapshot.docs
          .map(
            (doc) => ReminderModel.fromJson({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch reminders: $e');
    }
  }

  @override
  Future<void> addReminder(Reminder reminder) async {
    try {
      final reminderModel = ReminderModel.fromEntity(reminder);
      await _remindersCollection.doc(reminder.id).set(reminderModel.toJson());
    } catch (e) {
      throw Exception('Failed to add reminder: $e');
    }
  }

  @override
  Future<void> updateReminder(Reminder reminder) async {
    try {
      final reminderModel = ReminderModel.fromEntity(reminder);
      await _remindersCollection
          .doc(reminder.id)
          .update(reminderModel.toJson());
    } catch (e) {
      throw Exception('Failed to update reminder: $e');
    }
  }

  @override
  Future<void> deleteReminder(String id) async {
    try {
      await _remindersCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete reminder: $e');
    }
  }

  @override
  Future<void> toggleReminderComplete(String id) async {
    try {
      final doc = await _remindersCollection.doc(id).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final isCompleted = data['isCompleted'] as bool? ?? false;
        await _remindersCollection.doc(id).update({
          'isCompleted': !isCompleted,
        });
      }
    } catch (e) {
      throw Exception('Failed to toggle reminder: $e');
    }
  }
}
