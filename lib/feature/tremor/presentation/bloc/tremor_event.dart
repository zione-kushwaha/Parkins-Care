import '../../domain/entities/emergency_contact.dart';
import '../../domain/entities/tremor_reading.dart';

abstract class TremorEvent {}

class StartTremorMonitoring extends TremorEvent {}

class StopTremorMonitoring extends TremorEvent {}

class TremorDataReceived extends TremorEvent {
  final TremorReading reading;
  TremorDataReceived(this.reading);
}

class SaveTremorReading extends TremorEvent {
  final TremorReading reading;
  SaveTremorReading(this.reading);
}

class LoadTremorHistory extends TremorEvent {
  final DateTime? startDate;
  final DateTime? endDate;
  LoadTremorHistory({this.startDate, this.endDate});
}

class DeleteTremorReading extends TremorEvent {
  final String id;
  DeleteTremorReading(this.id);
}

// Emergency Contact Events
class LoadEmergencyContacts extends TremorEvent {}

class AddEmergencyContact extends TremorEvent {
  final EmergencyContact contact;
  AddEmergencyContact(this.contact);
}

class UpdateEmergencyContact extends TremorEvent {
  final EmergencyContact contact;
  UpdateEmergencyContact(this.contact);
}

class DeleteEmergencyContact extends TremorEvent {
  final String id;
  DeleteEmergencyContact(this.id);
}

class TriggerSOS extends TremorEvent {
  final String? message;
  TriggerSOS({this.message});
}
