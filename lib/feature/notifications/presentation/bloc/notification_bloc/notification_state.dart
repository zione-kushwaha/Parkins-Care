import 'package:equatable/equatable.dart';
import '../../../domain/entities/notification_entity.dart';

enum NotificationStatus { initial, loading, success, error }

class NotificationState extends Equatable {
  final NotificationStatus status;
  final List<NotificationEntity> notifications;
  final int unreadCount;
  final String? fcmToken;
  final String? errorMessage;
  final bool permissionGranted;

  const NotificationState({
    this.status = NotificationStatus.initial,
    this.notifications = const [],
    this.unreadCount = 0,
    this.fcmToken,
    this.errorMessage,
    this.permissionGranted = false,
  });

  NotificationState copyWith({
    NotificationStatus? status,
    List<NotificationEntity>? notifications,
    int? unreadCount,
    String? fcmToken,
    String? errorMessage,
    bool? permissionGranted,
  }) {
    return NotificationState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      fcmToken: fcmToken ?? this.fcmToken,
      errorMessage: errorMessage ?? this.errorMessage,
      permissionGranted: permissionGranted ?? this.permissionGranted,
    );
  }

  @override
  List<Object?> get props => [
        status,
        notifications,
        unreadCount,
        fcmToken,
        errorMessage,
        permissionGranted,
      ];
}
