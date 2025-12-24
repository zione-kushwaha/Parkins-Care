import '../../domain/entities/emergency_contact.dart';
import '../../domain/entities/tremor_reading.dart';

abstract class TremorState {}

class TremorInitial extends TremorState {}

class TremorMonitoring extends TremorState {
  final TremorReading? currentReading;
  final bool isRecording;

  TremorMonitoring({this.currentReading, this.isRecording = false});
}

class TremorMonitoringStopped extends TremorState {}

class TremorHistoryLoaded extends TremorState {
  final List<TremorReading> readings;
  TremorHistoryLoaded(this.readings);
}

class TremorHistoryLoading extends TremorState {}

class EmergencyContactsLoaded extends TremorState {
  final List<EmergencyContact> contacts;
  EmergencyContactsLoaded(this.contacts);
}

class EmergencyContactsLoading extends TremorState {}

class TremorOperationSuccess extends TremorState {
  final String message;
  TremorOperationSuccess(this.message);
}

class TremorError extends TremorState {
  final String message;
  TremorError(this.message);
}

class SOSTriggered extends TremorState {
  final EmergencyContact? primaryContact;
  SOSTriggered({this.primaryContact});
}
