import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/notification_repository.dart';
import '../model/notification_model.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(Supabase.instance.client);
});

final notificationProvider =
    AsyncNotifierProvider<NotificationController, List<NotificationModel>>(
  NotificationController.new,
);

class NotificationController
    extends AsyncNotifier<List<NotificationModel>> {
  late final NotificationRepository _repository;

  @override
  Future<List<NotificationModel>> build() async {
    _repository = ref.read(notificationRepositoryProvider);

    return _repository.getNotifications();
  }

  Future<void> refreshNotifications() async {
    state = const AsyncLoading();

    try {
      final notifications = await _repository.getNotifications();

      state = AsyncData(notifications);
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _repository.markAsRead(notificationId);

      final currentNotifications = state.value ?? [];

      state = AsyncData(
        currentNotifications.map((notification) {
          if (notification.id == notificationId) {
            return notification.copyWith(isRead: true);
          }

          return notification;
        }).toList(),
      );
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllAsRead();

      final currentNotifications = state.value ?? [];

      state = AsyncData(
        currentNotifications
            .map(
              (notification) => notification.copyWith(isRead: true),
            )
            .toList(),
      );
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _repository.deleteNotification(notificationId);

      final currentNotifications = state.value ?? [];

      state = AsyncData(
        currentNotifications
            .where(
              (notification) => notification.id != notificationId,
            )
            .toList(),
      );
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
    }
  }
}