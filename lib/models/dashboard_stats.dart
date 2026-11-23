import 'announcement.dart';
import 'assignment.dart';

class DashboardStats {
  final int totalPendingAssignments;
  final int dueSoonAssignments;
  final int overdueAssignments;
  final int totalCompletedAssignments;
  final int unreadNotificationsCount;
  final List<Assignment> upcomingAssignments;
  final List<Announcement> recentAnnouncements;

  DashboardStats({
    required this.totalPendingAssignments,
    required this.dueSoonAssignments,
    required this.overdueAssignments,
    required this.totalCompletedAssignments,
    required this.unreadNotificationsCount,
    required this.upcomingAssignments,
    required this.recentAnnouncements,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalPendingAssignments: (json['totalPendingAssignments'] as num?)?.toInt() ?? 0,
      dueSoonAssignments: (json['dueSoonAssignments'] as num?)?.toInt() ?? 0,
      overdueAssignments: (json['overdueAssignments'] as num?)?.toInt() ?? 0,
      totalCompletedAssignments: (json['totalCompletedAssignments'] as num?)?.toInt() ?? 0,
      unreadNotificationsCount: (json['unreadNotificationsCount'] as num?)?.toInt() ?? 0,
      upcomingAssignments: (json['upcomingAssignments'] as List<dynamic>?)
              ?.map((e) => Assignment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      recentAnnouncements: (json['recentAnnouncements'] as List<dynamic>?)
              ?.map((e) => Announcement.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
