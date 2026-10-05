import 'package:cartiva/core/app_theme_color.dart';
import 'package:cartiva/features/notifications/provider/notification_provider.dart';
import 'package:cartiva/features/notifications/model/notification_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsState = ref.watch(notificationProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          notificationsState.when(
            data: (notifications) {
              final hasUnread =
                  notifications.any((notification) => !notification.isRead);

              if (!hasUnread) {
                return const SizedBox();
              }

              return TextButton(
                onPressed: () {
                  ref
                      .read(notificationProvider.notifier)
                      .markAllAsRead();
                },
                child: const Text('Read all'),
              );
            },
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
        ],
      ),
      body: notificationsState.when(
        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        error: (error, stackTrace) {
          return _ErrorState(
            onRetry: () {
              ref
                  .read(notificationProvider.notifier)
                  .refreshNotifications();
            },
          );
        },
        data: (notifications) {
          if (notifications.isEmpty) {
            return const _EmptyState();
          }

          final sections = _groupNotifications(notifications);

          return RefreshIndicator(
            onRefresh: () {
              return ref
                  .read(notificationProvider.notifier)
                  .refreshNotifications();
            },
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 20),
              itemCount: sections.length,
              itemBuilder: (context, index) {
                final section = sections[index];

                return _NotificationSection(
                  title: section.title,
                  notifications: section.notifications,
                  onNotificationTap: (notification) {
                    ref
                        .read(notificationProvider.notifier)
                        .markAsRead(notification.id);

                    _handleNotificationTap(
                      context,
                      notification,
                    );
                  },
                  onDelete: (notification) {
                    ref
                        .read(notificationProvider.notifier)
                        .deleteNotification(notification.id);
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _handleNotificationTap(
    BuildContext context,
    NotificationModel notification,
  ) {
    // Later, use notification.type to navigate
    // to the correct screen.

    switch (notification.type) {
      case 'order':
        // Navigator.push(...)
        break;

      case 'promotion':
        // Navigator.push(...)
        break;

      case 'payment':
        // Navigator.push(...)
        break;

      default:
        break;
    }
  }

  List<NotificationSectionData> _groupNotifications(
    List<NotificationModel> notifications,
  ) {
    final Map<String, List<NotificationModel>> grouped = {};

    for (final notification in notifications) {
      final title = _getDateTitle(notification.createdAt);

      grouped.putIfAbsent(title, () => []);

      grouped[title]!.add(notification);
    }

    return grouped.entries
        .map(
          (entry) => NotificationSectionData(
            title: entry.key,
            notifications: entry.value,
          ),
        )
        .toList();
  }

  String _getDateTitle(DateTime date) {
    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final notificationDate = DateTime(
      date.year,
      date.month,
      date.day,
    );

    final difference = today.difference(notificationDate).inDays;

    if (difference == 0) {
      return 'Today';
    }

    if (difference == 1) {
      return 'Yesterday';
    }

    return '${_monthName(date.month)} ${date.day}, ${date.year}';
  }

  String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return months[month - 1];
  }
}


class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 14,
        ),
        color: notification.isRead
            ? Colors.white
            : Colors.grey.shade100,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // _NotificationIcon(
            //   type: notification.type,
            // ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontWeight: notification.isRead
                          ? FontWeight.w500
                          : FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _formatTime(notification.createdAt),
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (!notification.isRead)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 5),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;

    final minute = date.minute.toString().padLeft(2, '0');

    final period = date.hour >= 12 ? 'PM' : 'AM';

    final displayHour = hour == 0 ? 12 : hour;

    return '$displayHour:$minute $period';
  }
}



class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 20),
            const Text(
              "You haven't gotten any\nnotifications yet!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "We'll alert you when something\ncool happens.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.secondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorState({
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'We could not load your notifications.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}



class _NotificationSection extends StatelessWidget {
  final String title;
  final List<NotificationModel> notifications;
  final void Function(NotificationModel notification) onNotificationTap;
  final void Function(NotificationModel notification) onDelete;

  const _NotificationSection({
    required this.title,
    required this.notifications,
    required this.onNotificationTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            18,
            20,
            18,
            8,
          ),
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
        ...notifications.map(
          (notification) {
            return Dismissible(
              key: ValueKey(notification.id),
              direction: DismissDirection.endToStart,
              onDismissed: (_) {
                onDelete(notification);
              },
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                color: Colors.red,
                child: const Icon(
                  Icons.delete_outline,
                  color: Colors.white,
                ),
              ),
              child: _NotificationTile(
                notification: notification,
                onTap: () {
                  onNotificationTap(notification);
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class NotificationSectionData {
  final String title;
  final List<NotificationModel> notifications;

  const NotificationSectionData({
    required this.title,
    required this.notifications,
  });
}