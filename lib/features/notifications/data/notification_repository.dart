import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/notification_model.dart';

class NotificationRepository {
  final SupabaseClient _supabase;

  NotificationRepository(this._supabase);

  Future<List<NotificationModel>> getNotifications() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in');
    }

    final response = await _supabase
        .from('notifications')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return response
        .map<NotificationModel>(
          (json) => NotificationModel.fromJson(json),
        )
        .toList();
  }

  Future<void> markAsRead(String notificationId) async {
    await _supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('id', notificationId);
  }

  Future<void> markAllAsRead() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in');
    }

    await _supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', user.id)
        .eq('is_read', false);
  }

  Future<void> deleteNotification(String notificationId) async {
    await _supabase
        .from('notifications')
        .delete()
        .eq('id', notificationId);
  }
}