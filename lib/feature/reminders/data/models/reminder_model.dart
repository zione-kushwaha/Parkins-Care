import '../../domain/entities/reminder.dart';

class ReminderModel extends Reminder {
  ReminderModel({
    required super.id,
    required super.title,
    required super.description,
    required super.dateTime,
    required super.type,
    super.isRecurring,
    super.recurringPattern,
    super.isCompleted,
    required super.createdAt,
  });

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      type: json['type'] as String,
      isRecurring: json['isRecurring'] as bool? ?? false,
      recurringPattern: json['recurringPattern'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dateTime': dateTime.toIso8601String(),
      'type': type,
      'isRecurring': isRecurring,
      'recurringPattern': recurringPattern,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ReminderModel.fromEntity(Reminder reminder) {
    return ReminderModel(
      id: reminder.id,
      title: reminder.title,
      description: reminder.description,
      dateTime: reminder.dateTime,
      type: reminder.type,
      isRecurring: reminder.isRecurring,
      recurringPattern: reminder.recurringPattern,
      isCompleted: reminder.isCompleted,
      createdAt: reminder.createdAt,
    );
  }
}
