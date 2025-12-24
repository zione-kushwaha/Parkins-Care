import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/notification_entity.dart';
import '../../../domain/repository/notification_repository.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository _notificationRepository;
  StreamSubscription? _notificationSubscription;

  NotificationBloc(this._notificationRepository)
    : super(const NotificationState()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<WatchNotifications>(_onWatchNotifications);
    on<MarkAsRead>(_onMarkAsRead);
    on<MarkAllAsRead>(_onMarkAllAsRead);
    on<DeleteNotification>(_onDeleteNotification);
    on<DeleteAllNotifications>(_onDeleteAllNotifications);
    on<RequestPermission>(_onRequestPermission);
    on<SubscribeToTopic>(_onSubscribeToTopic);
    on<UnsubscribeFromTopic>(_onUnsubscribeFromTopic);
    on<GetFcmToken>(_onGetFcmToken);
    on<RefreshNotifications>(_onRefreshNotifications);
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      emit(state.copyWith(status: NotificationStatus.loading));

      final notifications = await _notificationRepository.getNotifications();
      final unreadCount = await _notificationRepository.getUnreadCount();

      emit(
        state.copyWith(
          status: NotificationStatus.success,
          notifications: notifications,
          unreadCount: unreadCount,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: NotificationStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onWatchNotifications(
    WatchNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _notificationSubscription?.cancel();

      await emit.forEach<List<NotificationEntity>>(
        _notificationRepository.watchNotifications(),
        onData: (notifications) {
          // Calculate unread count from the notifications list
          final unreadCount = notifications.where((n) => !n.isRead).length;
          return state.copyWith(
            status: NotificationStatus.success,
            notifications: notifications,
            unreadCount: unreadCount,
          );
        },
        onError: (error, stackTrace) {
          return state.copyWith(
            status: NotificationStatus.error,
            errorMessage: error.toString(),
          );
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: NotificationStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onMarkAsRead(
    MarkAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _notificationRepository.markAsRead(event.notificationId);

      // Update local state
      final updatedNotifications = state.notifications.map((notification) {
        if (notification.id == event.notificationId) {
          return notification.copyWith(isRead: true);
        }
        return notification;
      }).toList();

      final unreadCount = await _notificationRepository.getUnreadCount();

      emit(
        state.copyWith(
          notifications: updatedNotifications,
          unreadCount: unreadCount,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: NotificationStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onMarkAllAsRead(
    MarkAllAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _notificationRepository.markAllAsRead();

      // Update local state
      final updatedNotifications = state.notifications
          .map((notification) => notification.copyWith(isRead: true))
          .toList();

      emit(state.copyWith(notifications: updatedNotifications, unreadCount: 0));
    } catch (e) {
      emit(
        state.copyWith(
          status: NotificationStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onDeleteNotification(
    DeleteNotification event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _notificationRepository.deleteNotification(event.notificationId);

      // Update local state
      final updatedNotifications = state.notifications
          .where((notification) => notification.id != event.notificationId)
          .toList();

      final unreadCount = await _notificationRepository.getUnreadCount();

      emit(
        state.copyWith(
          notifications: updatedNotifications,
          unreadCount: unreadCount,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: NotificationStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onDeleteAllNotifications(
    DeleteAllNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _notificationRepository.deleteAllNotifications();

      emit(state.copyWith(notifications: [], unreadCount: 0));
    } catch (e) {
      emit(
        state.copyWith(
          status: NotificationStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onRequestPermission(
    RequestPermission event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      final granted = await _notificationRepository.requestPermission();
      emit(state.copyWith(permissionGranted: granted));
    } catch (e) {
      emit(
        state.copyWith(
          status: NotificationStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onSubscribeToTopic(
    SubscribeToTopic event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _notificationRepository.subscribeToTopic(event.topic);
    } catch (e) {
      emit(
        state.copyWith(
          status: NotificationStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onUnsubscribeFromTopic(
    UnsubscribeFromTopic event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _notificationRepository.unsubscribeFromTopic(event.topic);
    } catch (e) {
      emit(
        state.copyWith(
          status: NotificationStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onGetFcmToken(
    GetFcmToken event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      final token = await _notificationRepository.getFcmToken();
      emit(state.copyWith(fcmToken: token));
    } catch (e) {
      emit(
        state.copyWith(
          status: NotificationStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onRefreshNotifications(
    RefreshNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      final notifications = await _notificationRepository.getNotifications();
      final unreadCount = await _notificationRepository.getUnreadCount();

      emit(
        state.copyWith(
          status: NotificationStatus.success,
          notifications: notifications,
          unreadCount: unreadCount,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: NotificationStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _notificationSubscription?.cancel();
    return super.close();
  }
}
