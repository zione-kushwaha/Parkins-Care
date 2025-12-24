import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/tremor_detection_service.dart';
import '../../domain/repositories/tremor_repository.dart';
import 'tremor_event.dart';
import 'tremor_state.dart';

class TremorBloc extends Bloc<TremorEvent, TremorState> {
  final TremorRepository repository;
  final TremorDetectionService detectionService;
  StreamSubscription? _tremorStreamSubscription;

  TremorBloc({required this.repository, required this.detectionService})
    : super(TremorInitial()) {
    on<StartTremorMonitoring>(_onStartMonitoring);
    on<StopTremorMonitoring>(_onStopMonitoring);
    on<TremorDataReceived>(_onTremorDataReceived);
    on<SaveTremorReading>(_onSaveTremorReading);
    on<LoadTremorHistory>(_onLoadTremorHistory);
    on<DeleteTremorReading>(_onDeleteTremorReading);
    on<LoadEmergencyContacts>(_onLoadEmergencyContacts);
    on<AddEmergencyContact>(_onAddEmergencyContact);
    on<UpdateEmergencyContact>(_onUpdateEmergencyContact);
    on<DeleteEmergencyContact>(_onDeleteEmergencyContact);
    on<TriggerSOS>(_onTriggerSOS);
  }

  Future<void> _onStartMonitoring(
    StartTremorMonitoring event,
    Emitter<TremorState> emit,
  ) async {
    try {
      detectionService.startMonitoring();
      emit(TremorMonitoring(isRecording: true));

      await _tremorStreamSubscription?.cancel();
      _tremorStreamSubscription = detectionService.tremorStream.listen(
        (reading) => add(TremorDataReceived(reading)),
      );
    } catch (e) {
      emit(TremorError('Failed to start monitoring: $e'));
    }
  }

  Future<void> _onStopMonitoring(
    StopTremorMonitoring event,
    Emitter<TremorState> emit,
  ) async {
    try {
      detectionService.stopMonitoring();
      await _tremorStreamSubscription?.cancel();
      _tremorStreamSubscription = null;
      emit(TremorMonitoringStopped());
    } catch (e) {
      emit(TremorError('Failed to stop monitoring: $e'));
    }
  }

  Future<void> _onTremorDataReceived(
    TremorDataReceived event,
    Emitter<TremorState> emit,
  ) async {
    emit(TremorMonitoring(currentReading: event.reading, isRecording: true));
  }

  Future<void> _onSaveTremorReading(
    SaveTremorReading event,
    Emitter<TremorState> emit,
  ) async {
    try {
      await repository.saveTremorReading(event.reading);
      emit(TremorOperationSuccess('Tremor reading saved'));
    } catch (e) {
      emit(TremorError('Failed to save reading: $e'));
    }
  }

  Future<void> _onLoadTremorHistory(
    LoadTremorHistory event,
    Emitter<TremorState> emit,
  ) async {
    try {
      emit(TremorHistoryLoading());
      final readings = await repository.getTremorHistory(
        startDate: event.startDate,
        endDate: event.endDate,
      );
      emit(TremorHistoryLoaded(readings));
    } catch (e) {
      emit(TremorError('Failed to load history: $e'));
    }
  }

  Future<void> _onDeleteTremorReading(
    DeleteTremorReading event,
    Emitter<TremorState> emit,
  ) async {
    try {
      await repository.deleteTremorReading(event.id);
      emit(TremorOperationSuccess('Reading deleted'));
      add(LoadTremorHistory());
    } catch (e) {
      emit(TremorError('Failed to delete reading: $e'));
    }
  }

  Future<void> _onLoadEmergencyContacts(
    LoadEmergencyContacts event,
    Emitter<TremorState> emit,
  ) async {
    try {
      emit(EmergencyContactsLoading());
      final contacts = await repository.getEmergencyContacts();
      emit(EmergencyContactsLoaded(contacts));
    } catch (e) {
      emit(TremorError('Failed to load contacts: $e'));
    }
  }

  Future<void> _onAddEmergencyContact(
    AddEmergencyContact event,
    Emitter<TremorState> emit,
  ) async {
    try {
      await repository.addEmergencyContact(event.contact);
      emit(TremorOperationSuccess('Contact added'));
      add(LoadEmergencyContacts());
    } catch (e) {
      emit(TremorError('Failed to add contact: $e'));
    }
  }

  Future<void> _onUpdateEmergencyContact(
    UpdateEmergencyContact event,
    Emitter<TremorState> emit,
  ) async {
    try {
      await repository.updateEmergencyContact(event.contact);
      emit(TremorOperationSuccess('Contact updated'));
      add(LoadEmergencyContacts());
    } catch (e) {
      emit(TremorError('Failed to update contact: $e'));
    }
  }

  Future<void> _onDeleteEmergencyContact(
    DeleteEmergencyContact event,
    Emitter<TremorState> emit,
  ) async {
    try {
      await repository.deleteEmergencyContact(event.id);
      emit(TremorOperationSuccess('Contact deleted'));
      add(LoadEmergencyContacts());
    } catch (e) {
      emit(TremorError('Failed to delete contact: $e'));
    }
  }

  Future<void> _onTriggerSOS(
    TriggerSOS event,
    Emitter<TremorState> emit,
  ) async {
    try {
      final primaryContact = await repository.getPrimaryContact();
      emit(SOSTriggered(primaryContact: primaryContact));
    } catch (e) {
      emit(TremorError('Failed to trigger SOS: $e'));
    }
  }

  @override
  Future<void> close() {
    _tremorStreamSubscription?.cancel();
    detectionService.dispose();
    return super.close();
  }
}
