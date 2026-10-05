import 'package:flutter/material.dart';

class NotificationItem {
  final IconData icon;
  final String title;
  final String subtitle;
 
  const NotificationItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}
 
class NotificationSection {
  final String date;
  final List<NotificationItem> items;
 
  const NotificationSection({required this.date, required this.items});
}
 