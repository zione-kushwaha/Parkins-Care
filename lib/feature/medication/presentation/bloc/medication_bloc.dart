import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/medication_entity.dart';
import 'medication_event.dart';
import 'medication_state.dart';

@injectable
class MedicationBloc extends Bloc<MedicationEvent, MedicationState> {
  // TODO: Inject repository when implemented

  MedicationBloc() : super(const MedicationInitial()) {
    on<LoadMedicationsEvent>(_onLoadMedications);
    on<AddMedicationEvent>(_onAddMedication);
    on<LogMedicationEvent>(_onLogMedication);
    on<MarkMedicationTakenEvent>(_onMarkMedicationTaken);
  }

  Future<void> _onLoadMedications(
    LoadMedicationsEvent event,
    Emitter<MedicationState> emit,
  ) async {
    emit(const MedicationLoading());

    try {
      // TODO: Replace with actual repository call
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock data for now
      final medications = [
        MedicationEntity(
          id: '1',
          userId: event.userId,
          name: 'Levodopa',
          dosage: '100mg',
          frequency: MedicationFrequency.daily,
          scheduleTimes: ['08:00', '14:00', '20:00'],
          notes: 'Take with food',
          createdAt: DateTime.now(),
          isActive: true,
        ),
        MedicationEntity(
          id: '2',
          userId: event.userId,
          name: 'Carbidopa',
          dosage: '25mg',
          frequency: MedicationFrequency.daily,
          scheduleTimes: ['08:00', '20:00'],
          createdAt: DateTime.now(),
          isActive: true,
        ),
      ];

      final upcoming = medications.where((m) => m.isActive).toList();
      final missed = <MedicationEntity>[];

      // Calculate adherence rate (simplified)
      final adherence = 85.0;

      emit(
        MedicationsLoaded(
          medications: medications,
          upcomingMedications: upcoming,
          missedMedications: missed,
          adherenceRate: adherence,
        ),
      );
    } catch (e) {
      emit(MedicationError(e.toString()));
    }
  }

  Future<void> _onAddMedication(
    AddMedicationEvent event,
    Emitter<MedicationState> emit,
  ) async {
    emit(const MedicationLoading());

    try {
      // TODO: Replace with actual repository call
      await Future.delayed(const Duration(milliseconds: 500));

      emit(MedicationAdded(event.medication));
      // Reload medications
      add(LoadMedicationsEvent(event.medication.userId));
    } catch (e) {
      emit(MedicationError(e.toString()));
    }
  }

  Future<void> _onLogMedication(
    LogMedicationEvent event,
    Emitter<MedicationState> emit,
  ) async {
    try {
      // TODO: Replace with actual repository call
      await Future.delayed(const Duration(milliseconds: 300));

      emit(
        MedicationLogged(
          medicationId: event.medicationId,
          wasTaken: event.wasTaken,
        ),
      );
    } catch (e) {
      emit(MedicationError(e.toString()));
    }
  }

  Future<void> _onMarkMedicationTaken(
    MarkMedicationTakenEvent event,
    Emitter<MedicationState> emit,
  ) async {
    try {
      // TODO: Replace with actual repository call
      await Future.delayed(const Duration(milliseconds: 300));

      emit(MedicationLogged(medicationId: event.medicationId, wasTaken: true));
    } catch (e) {
      emit(MedicationError(e.toString()));
    }
  }
}
