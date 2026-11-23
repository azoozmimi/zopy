import 'assignment.dart';

enum AnnouncementPriority {
  normal,
  important,
  urgent;

  static AnnouncementPriority fromInt(int val) {
    switch (val) {
      case 1:
        return AnnouncementPriority.important;
      case 2:
        return AnnouncementPriority.urgent;
      default:
        return AnnouncementPriority.normal;
    }
  }

  int toInt() {
    switch (this) {
      case AnnouncementPriority.important:
        return 1;
      case AnnouncementPriority.urgent:
        return 2;
      default:
        return 0;
    }
  }
}

class Announcement {
  final int id;
  final int cohortId;
  final String cohortName;
  final int? courseId;
  final String? courseName;
  final String title;
  final String content;
  final AnnouncementPriority priority;
  final int createdByUserId;
  final String createdByUserName;
  final DateTime publicationDateUtc;
  final bool isCancelled;
  final DateTime createdAtUtc;
  final List<AssignmentAttachment> attachments;

  Announcement({
    required this.id,
    required this.cohortId,
    required this.cohortName,
    this.courseId,
    this.courseName,
    required this.title,
    required this.content,
    required this.priority,
    required this.createdByUserId,
    required this.createdByUserName,
    required this.publicationDateUtc,
    required this.isCancelled,
    required this.createdAtUtc,
    required this.attachments,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'] as int,
      cohortId: json['cohortId'] as int? ?? 0,
      cohortName: json['cohortName'] as String? ?? '',
      courseId: json['courseId'] as int?,
      courseName: json['courseName'] as String?,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      priority: AnnouncementPriority.fromInt(json['priority'] as int? ?? 0),
      createdByUserId: json['createdByUserId'] as int? ?? 0,
      createdByUserName: json['createdByUserName'] as String? ?? '',
      publicationDateUtc: DateTime.tryParse(json['publicationDateUtc'] as String? ?? '') ?? DateTime.now(),
      isCancelled: json['isCancelled'] as bool? ?? false,
      createdAtUtc: DateTime.tryParse(json['createdAtUtc'] as String? ?? '') ?? DateTime.now(),
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((e) => AssignmentAttachment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
