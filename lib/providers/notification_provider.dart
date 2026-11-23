import 'package:flutter/material.dart';
import '../core/constants/api_endpoints.dart';
import '../core/services/api_service.dart';
import '../models/notification_item.dart';

class NotificationProvider extends ChangeNotifier {
  List<NotificationItem> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;

  List<NotificationItem> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  Future<void> fetchNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await ApiService.get(ApiEndpoints.notifications);
      if (res.statusCode == 200) {
        _notifications = (res.data as List<dynamic>)
            .map((e) => NotificationItem.fromJson(e as Map<String, dynamic>))
            .toList();
        _unreadCount = _notifications.where((n) => !n.isRead).length;
      }
    } catch (_) {
      // offline fallback
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUnreadCount() async {
    try {
      final res = await ApiService.get(ApiEndpoints.unreadNotificationsCount);
      if (res.statusCode == 200) {
        _unreadCount = res.data['unreadCount'] as int? ?? 0;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> markAsRead(int id) async {
    try {
      await ApiService.post(ApiEndpoints.markNotificationRead(id));
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1 && !_notifications[index].isRead) {
        _notifications[index].isRead = true;
        _unreadCount = (_unreadCount - 1).clamp(0, 999);
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    try {
      await ApiService.post(ApiEndpoints.markAllNotificationsRead);
      for (final n in _notifications) {
        n.isRead = true;
      }
      _unreadCount = 0;
      notifyListeners();
    } catch (_) {}
  }
}
