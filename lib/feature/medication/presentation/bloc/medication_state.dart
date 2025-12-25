import 'package:equatable/equatable.dart';
import '../../domain/entities/medication_entity.dart';

/// States for medication management
sealed class MedicationState extends Equatable {
  const MedicationState();
}

class MedicationInitial extends MedicationState {
  const MedicationInitial();

  @override
  List<Object?> get props => [];
}

class MedicationLoading extends MedicationState {
  const MedicationLoading();

  @override
  List<Object?> get props => [];
}

class MedicationsLoaded extends MedicationState {
  final List<MedicationEntity> medications;
  final List<MedicationEntity> upcomingMedications;
  final List<MedicationEntity> missedMedications;
  final double adherenceRate;

  const MedicationsLoaded({
    required this.medications,
    required this.upcomingMedications,
    required this.missedMedications,
    required this.adherenceRate,
  });

  @override
  List<Object?> get props => [
    medications,
    upcomingMedications,
    missedMedications,
    adherenceRate,
  ];
}

class MedicationAdded extends MedicationState {
  final MedicationEntity medication;

  const MedicationAdded(this.medication);

  @override
  List<Object?> get props => [medication];
}

class MedicationUpdated extends MedicationState {
  final MedicationEntity medication;

  const MedicationUpdated(this.medication);

  @override
  List<Object?> get props => [medication];
}

class MedicationDeleted extends MedicationState {
  final String medicationId;

  const MedicationDeleted(this.medicationId);

  @override
  List<Object?> get props => [medicationId];
}

class MedicationLogged extends MedicationState {
  final String medicationId;
  final bool wasTaken;

  const MedicationLogged({required this.medicationId, required this.wasTaken});

  @override
  List<Object?> get props => [medicationId, wasTaken];
}

class MedicationError extends MedicationState {
  final String message;

  const MedicationError(this.message);

  @override
  List<Object?> get props => [message];
}
