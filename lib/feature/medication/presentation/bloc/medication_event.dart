import 'package:equatable/equatable.dart';
import '../../domain/entities/medication_entity.dart';

/// Events for medication management
sealed class MedicationEvent extends Equatable {
  const MedicationEvent();
}

class LoadMedicationsEvent extends MedicationEvent {
  final String userId;

  const LoadMedicationsEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class AddMedicationEvent extends MedicationEvent {
  final MedicationEntity medication;

  const AddMedicationEvent(this.medication);

  @override
  List<Object?> get props => [medication];
}

class UpdateMedicationEvent extends MedicationEvent {
  final MedicationEntity medication;

  const UpdateMedicationEvent(this.medication);

  @override
  List<Object?> get props => [medication];
}

class DeleteMedicationEvent extends MedicationEvent {
  final String medicationId;

  const DeleteMedicationEvent(this.medicationId);

  @override
  List<Object?> get props => [medicationId];
}

class LogMedicationEvent extends MedicationEvent {
  final String medicationId;
  final DateTime timestamp;
  final bool wasTaken;
  final String? notes;

  const LogMedicationEvent({
    required this.medicationId,
    required this.timestamp,
    required this.wasTaken,
    this.notes,
  });

  @override
  List<Object?> get props => [medicationId, timestamp, wasTaken, notes];
}

class MarkMedicationTakenEvent extends MedicationEvent {
  final String medicationId;

  const MarkMedicationTakenEvent(this.medicationId);

  @override
  List<Object?> get props => [medicationId];
}
