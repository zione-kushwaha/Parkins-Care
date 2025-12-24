import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/emergency_contact.dart';
import '../../domain/entities/tremor_reading.dart';
import '../../domain/repositories/tremor_repository.dart';
import '../models/emergency_contact_model.dart';
import '../models/tremor_reading_model.dart';
import '../services/tremor_api_service.dart';

class TremorRepositoryImpl implements TremorRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final TremorApiService _apiService = TremorApiService();

  TremorRepositoryImpl({required this.firestore, required this.auth});

  String get _userId => auth.currentUser?.uid ?? '';

  CollectionReference get _tremorCollection =>
      firestore.collection('users').doc(_userId).collection('tremorReadings');

  CollectionReference get _contactsCollection => firestore
      .collection('users')
      .doc(_userId)
      .collection('emergencyContacts');

  @override
  Future<void> saveTremorReading(TremorReading reading) async {
    try {
      // Save to Firestore
      final model = TremorReadingModel.fromEntity(reading);
      await _tremorCollection.doc(reading.id).set(model.toJson());

      // Send to backend API
      await _apiService.sendTremorData(reading);
    } catch (e) {
      throw Exception('Failed to save tremor reading: $e');
    }
  }

  @override
  Future<List<TremorReading>> getTremorHistory({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _tremorCollection.orderBy('timestamp', descending: true);

      if (startDate != null) {
        query = query.where(
          'timestamp',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        );
      }

      if (endDate != null) {
        query = query.where(
          'timestamp',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate),
        );
      }

      final snapshot = await query.limit(100).get();

      return snapshot.docs
          .map(
            (doc) => TremorReadingModel.fromJson({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch tremor history: $e');
    }
  }

  @override
  Future<TremorReading?> getLatestReading() async {
    try {
      final snapshot = await _tremorCollection
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      return TremorReadingModel.fromJson({
        'id': snapshot.docs.first.id,
        ...snapshot.docs.first.data() as Map<String, dynamic>,
      });
    } catch (e) {
      throw Exception('Failed to fetch latest reading: $e');
    }
  }

  @override
  Future<void> deleteTremorReading(String id) async {
    try {
      await _tremorCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete tremor reading: $e');
    }
  }

  @override
  Future<void> addEmergencyContact(EmergencyContact contact) async {
    try {
      // If this is set as primary, unset all others first
      if (contact.isPrimary) {
        final contacts = await getEmergencyContacts();
        for (var c in contacts.where((c) => c.isPrimary)) {
          await _contactsCollection.doc(c.id).update({'isPrimary': false});
        }
      }

      final model = EmergencyContactModel.fromEntity(contact);
      await _contactsCollection.doc(contact.id).set(model.toJson());
    } catch (e) {
      throw Exception('Failed to add emergency contact: $e');
    }
  }

  @override
  Future<List<EmergencyContact>> getEmergencyContacts() async {
    try {
      // Fetch all contacts and sort in memory to avoid Firestore composite index
      final snapshot = await _contactsCollection
          .orderBy('createdAt', descending: false)
          .get();

      final contacts = snapshot.docs
          .map(
            (doc) => EmergencyContactModel.fromJson({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }),
          )
          .toList();

      // Sort: primary contacts first, then by creation date
      contacts.sort((a, b) {
        if (a.isPrimary && !b.isPrimary) return -1;
        if (!a.isPrimary && b.isPrimary) return 1;
        return a.createdAt.compareTo(b.createdAt);
      });

      return contacts;
    } catch (e) {
      throw Exception('Failed to fetch emergency contacts: $e');
    }
  }

  @override
  Future<void> updateEmergencyContact(EmergencyContact contact) async {
    try {
      // If this is set as primary, unset all others first
      if (contact.isPrimary) {
        final contacts = await getEmergencyContacts();
        for (var c in contacts.where(
          (c) => c.isPrimary && c.id != contact.id,
        )) {
          await _contactsCollection.doc(c.id).update({'isPrimary': false});
        }
      }

      final model = EmergencyContactModel.fromEntity(contact);
      await _contactsCollection.doc(contact.id).update(model.toJson());
    } catch (e) {
      throw Exception('Failed to update emergency contact: $e');
    }
  }

  @override
  Future<void> deleteEmergencyContact(String id) async {
    try {
      await _contactsCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete emergency contact: $e');
    }
  }

  @override
  Future<EmergencyContact?> getPrimaryContact() async {
    try {
      final snapshot = await _contactsCollection
          .where('isPrimary', isEqualTo: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      return EmergencyContactModel.fromJson({
        'id': snapshot.docs.first.id,
        ...snapshot.docs.first.data() as Map<String, dynamic>,
      });
    } catch (e) {
      throw Exception('Failed to fetch primary contact: $e');
    }
  }
}
