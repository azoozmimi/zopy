import 'dart:io';

class ApiEndpoints {
  // Default development URL: 10.0.2.2 for Android emulator, localhost for Windows/web
  static String defaultBaseUrl = Platform.isAndroid ? 'http://10.0.2.2:5000' : 'http://localhost:5000';

  static String baseUrl = defaultBaseUrl;

  static void setBaseUrl(String url) {
    baseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  // Auth
  static String get login => '$baseUrl/api/auth/login';
  static String get register => '$baseUrl/api/auth/register';
  static String get refreshToken => '$baseUrl/api/auth/refresh-token';
  static String get profile => '$baseUrl/api/auth/profile';
  static String get changePassword => '$baseUrl/api/auth/change-password';

  // Dashboard
  static String get studentDashboard => '$baseUrl/api/dashboard/student';
  static String get representativeDashboard => '$baseUrl/api/dashboard/representative';

  // Assignments
  static String get assignments => '$baseUrl/api/assignments';
  static String assignmentDetails(int id) => '$baseUrl/api/assignments/$id';
  static String assignmentStatus(int id) => '$baseUrl/api/assignments/$id/status';
  static String cancelAssignment(int id) => '$baseUrl/api/assignments/$id/cancel';
  static String assignmentAttachments(int id) => '$baseUrl/api/assignments/$id/attachments';
  static String deleteAssignmentAttachment(int id, int attachmentId) => '$baseUrl/api/assignments/$id/attachments/$attachmentId';

  // Submissions
  static String submitAssignment(int id) => '$baseUrl/api/assignments/$id/submit';
  static String mySubmission(int id) => '$baseUrl/api/assignments/$id/my-submission';
  static String assignmentSubmissions(int id) => '$baseUrl/api/assignments/$id/submissions';
  static String downloadSubmissionsZip(int id) => '$baseUrl/api/assignments/$id/submissions/download-zip';
  static String downloadSubmission(int assignmentId, int subId) => '$baseUrl/api/assignments/$assignmentId/submissions/$subId/download';

  // Announcements
  static String get announcements => '$baseUrl/api/announcements';
  static String announcementDetails(int id) => '$baseUrl/api/announcements/$id';
  static String cancelAnnouncement(int id) => '$baseUrl/api/announcements/$id/cancel';
  static String announcementAttachments(int id) => '$baseUrl/api/announcements/$id/attachments';

  // Courses
  static String get courses => '$baseUrl/api/courses';
  static String courseDetails(int id) => '$baseUrl/api/courses/$id';

  // Notifications
  static String get notifications => '$baseUrl/api/notifications';
  static String get unreadNotificationsCount => '$baseUrl/api/notifications/unread-count';
  static String markNotificationRead(int id) => '$baseUrl/api/notifications/$id/read';
  static String get markAllNotificationsRead => '$baseUrl/api/notifications/read-all';
  static String get notificationPreferences => '$baseUrl/api/notifications/preferences';

  // Calendar
  static String get calendar => '$baseUrl/api/calendar';

  // Admin
  static String get adminUsers => '$baseUrl/api/admin/users';
  static String assignUserRole(int id) => '$baseUrl/api/admin/users/$id/role';
  static String updateUserStatus(int id) => '$baseUrl/api/admin/users/$id/status';
  static String get adminHierarchy => '$baseUrl/api/admin/hierarchy';
  static String get adminAuditLogs => '$baseUrl/api/admin/audit-logs';
  static String get createCourse => '$baseUrl/api/admin/courses';
  static String get createCohort => '$baseUrl/api/admin/cohorts';
}
