import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../core/constants/api_endpoints.dart';
import '../core/services/api_service.dart';
import '../core/services/notification_service.dart';
import '../models/assignment.dart';

class AssignmentProvider extends ChangeNotifier {
  List<Assignment> _assignments = [];
  bool _isLoading = false;
  String? _errorMessage;

  String _filter = 'all'; // all, new, in_progress, completed, overdue
  int? _selectedCourseId;
  String _searchQuery = '';
  String _sortBy = 'deadline'; // deadline, created
  String _sortOrder = 'asc';

  List<Assignment> get assignments => _assignments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get filter => _filter;
  int? get selectedCourseId => _selectedCourseId;
  String get searchQuery => _searchQuery;

  void setFilter(String filter) {
    _filter = filter;
    fetchAssignments();
  }

  void setCourseFilter(int? courseId) {
    _selectedCourseId = courseId;
    fetchAssignments();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    fetchAssignments();
  }

  Future<void> fetchAssignments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final queryParams = <String, dynamic>{
        'filter': _filter,
        'sortBy': _sortBy,
        'sortOrder': _sortOrder,
      };

      if (_selectedCourseId != null && _selectedCourseId! > 0) {
        queryParams['courseId'] = _selectedCourseId;
      }

      if (_searchQuery.trim().isNotEmpty) {
        queryParams['search'] = _searchQuery.trim();
      }

      final res = await ApiService.get(ApiEndpoints.assignments, queryParameters: queryParams);

      if (res.statusCode == 200) {
        final list = (res.data as List<dynamic>)
            .map((e) => Assignment.fromJson(e as Map<String, dynamic>))
            .toList();
        _assignments = list;

        // Schedule local reminders for active assignments
        for (final a in _assignments) {
          LocalNotificationService.scheduleAssignmentReminders(a);
        }
      } else {
        _errorMessage = 'فشل تحميل التكاليف';
      }
    } catch (e) {
      _errorMessage = 'تعذر الاتصال بالخادم لجلب التكاليف';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateStatus(int assignmentId, AssignmentStatusType newStatus, {String? notes}) async {
    try {
      final res = await ApiService.post(
        ApiEndpoints.assignmentStatus(assignmentId),
        data: {
          'status': newStatus.toInt(),
          'notes': notes,
        },
      );

      if (res.statusCode == 200) {
        final index = _assignments.indexWhere((a) => a.id == assignmentId);
        if (index != -1) {
          final old = _assignments[index];
          _assignments[index] = Assignment(
            id: old.id,
            courseId: old.courseId,
            courseNameAr: old.courseNameAr,
            courseNameEn: old.courseNameEn,
            courseCode: old.courseCode,
            doctorName: old.doctorName,
            cohortId: old.cohortId,
            cohortName: old.cohortName,
            title: old.title,
            description: old.description,
            instructions: old.instructions,
            publicationDateUtc: old.publicationDateUtc,
            deadlineUtc: old.deadlineUtc,
            createdByUserId: old.createdByUserId,
            createdByUserName: old.createdByUserName,
            isPublished: old.isPublished,
            isCancelled: old.isCancelled,
            cancellationReason: old.cancellationReason,
            externalLinks: old.externalLinks,
            createdAtUtc: old.createdAtUtc,
            updatedAtUtc: old.updatedAtUtc,
            userStatus: newStatus,
            userNotes: notes ?? old.userNotes,
            attachments: old.attachments,
          );
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<Assignment?> fetchAssignmentDetails(int id) async {
    try {
      final res = await ApiService.get(ApiEndpoints.assignmentDetails(id));
      if (res.statusCode == 200) {
        final a = Assignment.fromJson(res.data as Map<String, dynamic>);
        final idx = _assignments.indexWhere((x) => x.id == id);
        if (idx != -1) {
          _assignments[idx] = a;
          notifyListeners();
        }
        return a;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> createAssignment({
    required int courseId,
    required String title,
    required String description,
    required String instructions,
    required DateTime deadlineUtc,
    String? externalLinks,
    bool isPublished = true,
    String allowedExtensions = '.pdf,.docx,.zip',
    int maxFileSizeMB = 25,
    bool allowReplacement = true,
    bool allowLateSubmission = false,
    DateTime? submissionStartUtc,
  }) async {
    try {
      final res = await ApiService.post(
        ApiEndpoints.assignments,
        data: {
          'courseId': courseId,
          'title': title,
          'description': description,
          'instructions': instructions,
          'deadlineUtc': deadlineUtc.toIso8601String(),
          'externalLinks': externalLinks,
          'isPublished': isPublished,
          'allowedExtensions': allowedExtensions,
          'maxFileSizeMB': maxFileSizeMB,
          'allowReplacement': allowReplacement,
          'allowLateSubmission': allowLateSubmission,
          if (submissionStartUtc != null)
            'submissionStartUtc': submissionStartUtc.toIso8601String(),
        },
      );

      if (res.statusCode == 200) {
        await fetchAssignments();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateAssignment({
    required int id,
    required String title,
    required String description,
    required String instructions,
    required DateTime deadlineUtc,
    String? externalLinks,
    required bool isPublished,
    String? changeReason,
    String? allowedExtensions,
    int? maxFileSizeMB,
    bool? allowReplacement,
    bool? allowLateSubmission,
    DateTime? submissionStartUtc,
  }) async {
    try {
      final res = await ApiService.put(
        ApiEndpoints.assignmentDetails(id),
        data: {
          'title': title,
          'description': description,
          'instructions': instructions,
          'deadlineUtc': deadlineUtc.toIso8601String(),
          'externalLinks': externalLinks,
          'isPublished': isPublished,
          'changeReason': changeReason,
          if (allowedExtensions != null) 'allowedExtensions': allowedExtensions,
          if (maxFileSizeMB != null) 'maxFileSizeMB': maxFileSizeMB,
          if (allowReplacement != null) 'allowReplacement': allowReplacement,
          if (allowLateSubmission != null) 'allowLateSubmission': allowLateSubmission,
          if (submissionStartUtc != null)
            'submissionStartUtc': submissionStartUtc.toIso8601String(),
        },
      );

      if (res.statusCode == 200) {
        await fetchAssignments();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<String?> submitAssignmentFile(int assignmentId, File file, {String? notes}) async {
    try {
      final res = await ApiService.uploadSubmission(
        ApiEndpoints.submitAssignment(assignmentId),
        file,
        notes: notes,
      );

      if (res.statusCode == 200) {
        // Refresh details for this assignment
        await fetchAssignmentDetails(assignmentId);
        await fetchAssignments();
        return null; // Success (no error message)
      } else {
        final data = res.data;
        if (data is Map && data['message'] != null) {
          return data['message'].toString();
        }
        return 'فشل تسليم الواجب / Submission failed';
      }
    } on DioException catch (dioErr) {
      if (dioErr.response?.data is Map && dioErr.response?.data['message'] != null) {
        return dioErr.response?.data['message'].toString();
      }
      return 'تعذر تسليم الملف: ${dioErr.message}';
    } catch (e) {
      return 'حدث خطأ أثناء رفع ملف التسليم: $e';
    }
  }

  Future<AssignmentSubmissionsStats?> fetchSubmissionsStats(int assignmentId, {String? statusFilter}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (statusFilter != null && statusFilter.isNotEmpty) {
        queryParams['statusFilter'] = statusFilter;
      }

      final res = await ApiService.get(
        ApiEndpoints.assignmentSubmissions(assignmentId),
        queryParameters: queryParams,
      );

      if (res.statusCode == 200) {
        return AssignmentSubmissionsStats.fromJson(res.data as Map<String, dynamic>);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> cancelAssignment(int id, String reason) async {
    try {
      final res = await ApiService.post(
        ApiEndpoints.cancelAssignment(id),
        data: {'reason': reason},
      );

      if (res.statusCode == 200) {
        await LocalNotificationService.cancelAssignmentReminders(id);
        await fetchAssignments();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
