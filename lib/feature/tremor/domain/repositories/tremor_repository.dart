import '../entities/emergency_contact.dart';
import '../entities/tremor_reading.dart';

abstract class TremorRepository {
  Future<void> saveTremorReading(TremorReading reading);
  Future<List<TremorReading>> getTremorHistory({
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<TremorReading?> getLatestReading();
  Future<void> deleteTremorReading(String id);

  // Emergency contacts
  Future<void> addEmergencyContact(EmergencyContact contact);
  Future<List<EmergencyContact>> getEmergencyContacts();
  Future<void> updateEmergencyContact(EmergencyContact contact);
  Future<void> deleteEmergencyContact(String id);
  Future<EmergencyContact?> getPrimaryContact();
}
