import 'package:equatable/equatable.dart';

enum MedicationFrequency { daily, weekly, asNeeded }

enum MedicationStatus { taken, skipped, snoozed, pending }

class MedicationEntity extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String dosage;
  final MedicationFrequency frequency;
  final List<String> scheduleTimes; // Time in HH:mm format
  final String? notes;
  final DateTime createdAt;
  final bool isActive;

  const MedicationEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.scheduleTimes,
    this.notes,
    required this.createdAt,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    name,
    dosage,
    frequency,
    scheduleTimes,
    notes,
    createdAt,
    isActive,
  ];
}

class MedicationLogEntity extends Equatable {
  final String id;
  final String medicationId;
  final String userId;
  final DateTime scheduledTime;
  final DateTime? takenAt;
  final MedicationStatus status;
  final String? note;

  const MedicationLogEntity({
    required this.id,
    required this.medicationId,
    required this.userId,
    required this.scheduledTime,
    this.takenAt,
    required this.status,
    this.note,
  });

  @override
  List<Object?> get props => [
    id,
    medicationId,
    userId,
    scheduledTime,
    takenAt,
    status,
    note,
  ];
}
