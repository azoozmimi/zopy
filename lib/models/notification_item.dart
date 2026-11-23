enum NotificationType {
  newAssignment,
  deadlineReminder,
  deadlineChange,
  cancellation,
  announcement;

  static NotificationType fromInt(int val) {
    switch (val) {
      case 1:
        return NotificationType.deadlineReminder;
      case 2:
        return NotificationType.deadlineChange;
      case 3:
        return NotificationType.cancellation;
      case 4:
        return NotificationType.announcement;
      default:
        return NotificationType.newAssignment;
    }
  }
}

class NotificationItem {
  final int id;
  final String title;
  final String body;
  final NotificationType type;
  final int? referenceId;
  bool isRead;
  final DateTime createdAtUtc;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.referenceId,
    required this.isRead,
    required this.createdAtUtc,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      type: NotificationType.fromInt(json['type'] as int? ?? 0),
      referenceId: json['referenceId'] as int?,
      isRead: json['isRead'] as bool? ?? false,
      createdAtUtc: DateTime.tryParse(json['createdAtUtc'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
