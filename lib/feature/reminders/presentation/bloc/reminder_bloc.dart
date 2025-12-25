import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/reminder.dart';
import '../../domain/entities/reminder_event.dart';
import '../../domain/entities/reminder_state.dart';
import '../../domain/repositories/reminder_repository.dart';

class ReminderBloc extends Bloc<ReminderEvent, ReminderState> {
  final ReminderRepository repository;

  ReminderBloc({required this.repository}) : super(ReminderInitial()) {
    on<LoadReminders>(_onLoadReminders);
    on<AddReminder>(_onAddReminder);
    on<UpdateReminder>(_onUpdateReminder);
    on<DeleteReminder>(_onDeleteReminder);
    on<ToggleReminderComplete>(_onToggleReminderComplete);
  }

  Future<void> _onLoadReminders(
    LoadReminders event,
    Emitter<ReminderState> emit,
  ) async {
    emit(ReminderLoading());
    try {
      final reminders = await repository.getReminders();
      final now = DateTime.now();

      final upcomingReminders = reminders
          .where((r) => !r.isCompleted && r.dateTime.isAfter(now))
          .toList();

      final completedReminders = reminders.where((r) => r.isCompleted).toList();

      emit(
        ReminderLoaded(
          reminders: reminders,
          upcomingReminders: upcomingReminders,
          completedReminders: completedReminders,
        ),
      );
    } catch (e) {
      emit(ReminderError(e.toString()));
    }
  }

  Future<void> _onAddReminder(
    AddReminder event,
    Emitter<ReminderState> emit,
  ) async {
    try {
      await repository.addReminder(event.reminder);
      // Reload reminders
      final reminders = await repository.getReminders();
      final now = DateTime.now();

      final upcomingReminders = reminders
          .where((r) => !r.isCompleted && r.dateTime.isAfter(now))
          .toList();

      final completedReminders = reminders
          .where((r) => r.isCompleted || r.dateTime.isBefore(now))
          .toList();

      // Emit success with data
      emit(
        ReminderOperationSuccess(
          message: 'Reminder added successfully',
          reminders: reminders,
          upcomingReminders: upcomingReminders,
          completedReminders: completedReminders,
        ),
      );
    } catch (e) {
      emit(ReminderError(e.toString()));
    }
  }

  Future<void> _onUpdateReminder(
    UpdateReminder event,
    Emitter<ReminderState> emit,
  ) async {
    try {
      await repository.updateReminder(event.reminder);
      // Reload reminders
      final reminders = await repository.getReminders();
      final now = DateTime.now();

      final upcomingReminders = reminders
          .where((r) => !r.isCompleted && r.dateTime.isAfter(now))
          .toList();

      final completedReminders = reminders
          .where((r) => r.isCompleted || r.dateTime.isBefore(now))
          .toList();

      // Emit success with data
      emit(
        ReminderOperationSuccess(
          message: 'Reminder updated successfully',
          reminders: reminders,
          upcomingReminders: upcomingReminders,
          completedReminders: completedReminders,
        ),
      );
    } catch (e) {
      emit(ReminderError(e.toString()));
    }
  }

  Future<void> _onDeleteReminder(
    DeleteReminder event,
    Emitter<ReminderState> emit,
  ) async {
    try {
      await repository.deleteReminder(event.id);
      // Reload reminders
      final reminders = await repository.getReminders();
      final now = DateTime.now();

      final upcomingReminders = reminders
          .where((r) => !r.isCompleted && r.dateTime.isAfter(now))
          .toList();

      final completedReminders = reminders
          .where((r) => r.isCompleted || r.dateTime.isBefore(now))
          .toList();

      // Emit success with data
      emit(
        ReminderOperationSuccess(
          message: 'Reminder deleted successfully',
          reminders: reminders,
          upcomingReminders: upcomingReminders,
          completedReminders: completedReminders,
        ),
      );
    } catch (e) {
      emit(ReminderError(e.toString()));
    }
  }

  Future<void> _onToggleReminderComplete(
    ToggleReminderComplete event,
    Emitter<ReminderState> emit,
  ) async {
    try {
      await repository.toggleReminderComplete(event.id);
      add(LoadReminders());
    } catch (e) {
      emit(ReminderError(e.toString()));
    }
  }
}
