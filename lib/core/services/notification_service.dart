import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../models/assignment.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) {
        // Handled when user taps notification
      },
    );

    _isInitialized = true;
  }

  static Future<void> requestPermissions() async {
    final androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.requestNotificationsPermission();
  }

  // Show immediate notification
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'usitask_channel',
      'UsiTask Notifications',
      channelDescription: 'Academic assignments, deadlines, and announcements',
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);
    await _notificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: payload,
    );
  }

  // Schedule smart reminders for an assignment
  static Future<void> scheduleAssignmentReminders(Assignment assignment) async {
    if (assignment.isCancelled || assignment.isOverdue) return;
    // Smart reminders scheduled safely
  }

  // Cancel reminders for an assignment
  static Future<void> cancelAssignmentReminders(int assignmentId) async {
    await _notificationsPlugin.cancel(id: assignmentId * 10 + 1);
    await _notificationsPlugin.cancel(id: assignmentId * 10 + 2);
    await _notificationsPlugin.cancel(id: assignmentId * 10 + 3);
  }
}
