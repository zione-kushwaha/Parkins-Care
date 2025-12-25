import '../entities/reminder.dart';

abstract class ReminderEvent {}

class LoadReminders extends ReminderEvent {}

class AddReminder extends ReminderEvent {
  final Reminder reminder;

  AddReminder(this.reminder);
}

class UpdateReminder extends ReminderEvent {
  final Reminder reminder;

  UpdateReminder(this.reminder);
}

class DeleteReminder extends ReminderEvent {
  final String id;

  DeleteReminder(this.id);
}

class ToggleReminderComplete extends ReminderEvent {
  final String id;

  ToggleReminderComplete(this.id);
}
