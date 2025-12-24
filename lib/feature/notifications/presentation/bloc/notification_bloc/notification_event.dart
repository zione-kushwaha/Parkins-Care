import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotifications extends NotificationEvent {
  const LoadNotifications();
}

class WatchNotifications extends NotificationEvent {
  const WatchNotifications();
}

class MarkAsRead extends NotificationEvent {
  final String notificationId;

  const MarkAsRead(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class MarkAllAsRead extends NotificationEvent {
  const MarkAllAsRead();
}

class DeleteNotification extends NotificationEvent {
  final String notificationId;

  const DeleteNotification(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class DeleteAllNotifications extends NotificationEvent {
  const DeleteAllNotifications();
}

class RequestPermission extends NotificationEvent {
  const RequestPermission();
}

class SubscribeToTopic extends NotificationEvent {
  final String topic;

  const SubscribeToTopic(this.topic);

  @override
  List<Object?> get props => [topic];
}

class UnsubscribeFromTopic extends NotificationEvent {
  final String topic;

  const UnsubscribeFromTopic(this.topic);

  @override
  List<Object?> get props => [topic];
}

class GetFcmToken extends NotificationEvent {
  const GetFcmToken();
}

class RefreshNotifications extends NotificationEvent {
  const RefreshNotifications();
}
