enum AssignmentStatusType {
  notStarted,
  inProgress,
  completed;

  static AssignmentStatusType fromInt(int value) {
    switch (value) {
      case 1:
        return AssignmentStatusType.inProgress;
      case 2:
        return AssignmentStatusType.completed;
      default:
        return AssignmentStatusType.notStarted;
    }
  }

  int toInt() {
    switch (this) {
      case AssignmentStatusType.inProgress:
        return 1;
      case AssignmentStatusType.completed:
        return 2;
      default:
        return 0;
    }
  }
}

class AssignmentAttachment {
  final int id;
  final String fileName;
  final int fileSize;
  final String contentType;
  final DateTime uploadedAtUtc;
  final String downloadUrl;

  AssignmentAttachment({
    required this.id,
    required this.fileName,
    required this.fileSize,
    required this.contentType,
    required this.uploadedAtUtc,
    required this.downloadUrl,
  });

  factory AssignmentAttachment.fromJson(Map<String, dynamic> json) {
    return AssignmentAttachment(
      id: json['id'] as int,
      fileName: json['fileName'] as String? ?? '',
      fileSize: (json['fileSize'] as num?)?.toInt() ?? 0,
      contentType: json['contentType'] as String? ?? '',
      uploadedAtUtc: DateTime.tryParse(json['uploadedAtUtc'] as String? ?? '') ?? DateTime.now(),
      downloadUrl: json['downloadUrl'] as String? ?? '',
    );
  }
}

class StudentSubmission {
  final int id;
  final int assignmentId;
  final int userId;
  final String studentName;
  final String? studentId;
  final String originalFileName;
  final String formattedFileName;
  final String extension;
  final int fileSize;
  final String contentType;
  final int status; // 1 = Submitted, 2 = Late
  final bool isLate;
  final int version;
  final String? studentNotes;
  final DateTime submittedAtUtc;
  final DateTime? updatedAtUtc;
  final String downloadUrl;

  StudentSubmission({
    required this.id,
    required this.assignmentId,
    required this.userId,
    required this.studentName,
    this.studentId,
    required this.originalFileName,
    required this.formattedFileName,
    required this.extension,
    required this.fileSize,
    required this.contentType,
    required this.status,
    required this.isLate,
    required this.version,
    this.studentNotes,
    required this.submittedAtUtc,
    this.updatedAtUtc,
    required this.downloadUrl,
  });

  factory StudentSubmission.fromJson(Map<String, dynamic> json) {
    return StudentSubmission(
      id: json['id'] as int,
      assignmentId: json['assignmentId'] as int,
      userId: json['userId'] as int,
      studentName: json['studentName'] as String? ?? '',
      studentId: json['studentId'] as String?,
      originalFileName: json['originalFileName'] as String? ?? '',
      formattedFileName: json['formattedFileName'] as String? ?? '',
      extension: json['extension'] as String? ?? '',
      fileSize: (json['fileSize'] as num?)?.toInt() ?? 0,
      contentType: json['contentType'] as String? ?? '',
      status: (json['status'] as num?)?.toInt() ?? 1,
      isLate: json['isLate'] as bool? ?? false,
      version: (json['version'] as num?)?.toInt() ?? 1,
      studentNotes: json['studentNotes'] as String?,
      submittedAtUtc: DateTime.tryParse(json['submittedAtUtc'] as String? ?? '') ?? DateTime.now(),
      updatedAtUtc: json['updatedAtUtc'] != null ? DateTime.tryParse(json['updatedAtUtc'] as String) : null,
      downloadUrl: json['downloadUrl'] as String? ?? '',
    );
  }
}

class AssignmentSubmissionsStats {
  final int assignmentId;
  final String assignmentTitle;
  final int totalStudents;
  final int submittedCount;
  final int lateCount;
  final int pendingCount;
  final List<StudentSubmission> submissions;

  AssignmentSubmissionsStats({
    required this.assignmentId,
    required this.assignmentTitle,
    required this.totalStudents,
    required this.submittedCount,
    required this.lateCount,
    required this.pendingCount,
    required this.submissions,
  });

  factory AssignmentSubmissionsStats.fromJson(Map<String, dynamic> json) {
    return AssignmentSubmissionsStats(
      assignmentId: json['assignmentId'] as int? ?? 0,
      assignmentTitle: json['assignmentTitle'] as String? ?? '',
      totalStudents: json['totalStudents'] as int? ?? 0,
      submittedCount: json['submittedCount'] as int? ?? 0,
      lateCount: json['lateCount'] as int? ?? 0,
      pendingCount: json['pendingCount'] as int? ?? 0,
      submissions: (json['submissions'] as List<dynamic>?)
              ?.map((e) => StudentSubmission.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class Assignment {
  final int id;
  final int courseId;
  final String courseNameAr;
  final String courseNameEn;
  final String courseCode;
  final String doctorName;
  final int cohortId;
  final String cohortName;
  final String title;
  final String description;
  final String instructions;
  final DateTime publicationDateUtc;
  final DateTime deadlineUtc;
  final int createdByUserId;
  final String createdByUserName;
  final bool isPublished;
  final bool isCancelled;
  final String? cancellationReason;
  final String? externalLinks;
  final DateTime createdAtUtc;
  final DateTime? updatedAtUtc;
  final AssignmentStatusType userStatus;
  final String? userNotes;
  final List<AssignmentAttachment> attachments;
  final String allowedExtensions;
  final int maxFileSizeMB;
  final bool allowReplacement;
  final bool allowLateSubmission;
  final DateTime? submissionStartUtc;
  final StudentSubmission? mySubmission;

  Assignment({
    required this.id,
    required this.courseId,
    required this.courseNameAr,
    required this.courseNameEn,
    required this.courseCode,
    required this.doctorName,
    required this.cohortId,
    required this.cohortName,
    required this.title,
    required this.description,
    required this.instructions,
    required this.publicationDateUtc,
    required this.deadlineUtc,
    required this.createdByUserId,
    required this.createdByUserName,
    required this.isPublished,
    required this.isCancelled,
    this.cancellationReason,
    this.externalLinks,
    required this.createdAtUtc,
    this.updatedAtUtc,
    required this.userStatus,
    this.userNotes,
    required this.attachments,
    this.allowedExtensions = '.pdf,.docx,.zip',
    this.maxFileSizeMB = 25,
    this.allowReplacement = true,
    this.allowLateSubmission = false,
    this.submissionStartUtc,
    this.mySubmission,
  });

  bool get isSubmitted => mySubmission != null;

  bool get isSubmissionLate => mySubmission?.isLate ?? false;

  bool get isOverdue => DateTime.now().toUtc().isAfter(deadlineUtc) && !isSubmitted && userStatus != AssignmentStatusType.completed;

  Duration get remainingTime => deadlineUtc.difference(DateTime.now().toUtc());

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'] as int,
      courseId: json['courseId'] as int? ?? 0,
      courseNameAr: json['courseNameAr'] as String? ?? '',
      courseNameEn: json['courseNameEn'] as String? ?? '',
      courseCode: json['courseCode'] as String? ?? '',
      doctorName: json['doctorName'] as String? ?? '',
      cohortId: json['cohortId'] as int? ?? 0,
      cohortName: json['cohortName'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      instructions: json['instructions'] as String? ?? '',
      publicationDateUtc: DateTime.tryParse(json['publicationDateUtc'] as String? ?? '') ?? DateTime.now(),
      deadlineUtc: DateTime.tryParse(json['deadlineUtc'] as String? ?? '') ?? DateTime.now(),
      createdByUserId: json['createdByUserId'] as int? ?? 0,
      createdByUserName: json['createdByUserName'] as String? ?? '',
      isPublished: json['isPublished'] as bool? ?? true,
      isCancelled: json['isCancelled'] as bool? ?? false,
      cancellationReason: json['cancellationReason'] as String?,
      externalLinks: json['externalLinks'] as String?,
      createdAtUtc: DateTime.tryParse(json['createdAtUtc'] as String? ?? '') ?? DateTime.now(),
      updatedAtUtc: json['updatedAtUtc'] != null ? DateTime.tryParse(json['updatedAtUtc'] as String) : null,
      userStatus: AssignmentStatusType.fromInt(json['userStatus'] as int? ?? 0),
      userNotes: json['userNotes'] as String?,
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((e) => AssignmentAttachment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      allowedExtensions: json['allowedExtensions'] as String? ?? '.pdf,.docx,.zip',
      maxFileSizeMB: json['maxFileSizeMB'] as int? ?? 25,
      allowReplacement: json['allowReplacement'] as bool? ?? true,
      allowLateSubmission: json['allowLateSubmission'] as bool? ?? false,
      submissionStartUtc: json['submissionStartUtc'] != null ? DateTime.tryParse(json['submissionStartUtc'] as String) : null,
      mySubmission: json['mySubmission'] != null
          ? StudentSubmission.fromJson(json['mySubmission'] as Map<String, dynamic>)
          : null,
    );
  }
}
