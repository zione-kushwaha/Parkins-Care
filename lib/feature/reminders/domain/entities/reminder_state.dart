import '../entities/reminder.dart';

abstract class ReminderState {}

class ReminderInitial extends ReminderState {}

class ReminderLoading extends ReminderState {}

class ReminderLoaded extends ReminderState {
  final List<Reminder> reminders;
  final List<Reminder> upcomingReminders;
  final List<Reminder> completedReminders;

  ReminderLoaded({
    required this.reminders,
    required this.upcomingReminders,
    required this.completedReminders,
  });
}

class ReminderError extends ReminderState {
  final String message;

  ReminderError(this.message);
}

class ReminderOperationSuccess extends ReminderLoaded {
  final String message;

  ReminderOperationSuccess({
    required this.message,
    required super.reminders,
    required super.upcomingReminders,
    required super.completedReminders,
  });
}
