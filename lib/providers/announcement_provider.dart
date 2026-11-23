import 'package:flutter/material.dart';
import '../core/constants/api_endpoints.dart';
import '../core/services/api_service.dart';
import '../models/announcement.dart';

class AnnouncementProvider extends ChangeNotifier {
  List<Announcement> _announcements = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Announcement> get announcements => _announcements;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchAnnouncements({int? courseId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final queryParams = <String, dynamic>{};
      if (courseId != null && courseId > 0) {
        queryParams['courseId'] = courseId;
      }

      final res = await ApiService.get(ApiEndpoints.announcements, queryParameters: queryParams);
      if (res.statusCode == 200) {
        _announcements = (res.data as List<dynamic>)
            .map((e) => Announcement.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        _errorMessage = 'فشل تحميل الإعلانات';
      }
    } catch (_) {
      _errorMessage = 'تعذر الاتصال بالخادم لجلب الإعلانات';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createAnnouncement({
    int? courseId,
    required String title,
    required String content,
    AnnouncementPriority priority = AnnouncementPriority.normal,
  }) async {
    try {
      final res = await ApiService.post(
        ApiEndpoints.announcements,
        data: {
          'courseId': courseId,
          'title': title,
          'content': content,
          'priority': priority.toInt(),
        },
      );

      if (res.statusCode == 200) {
        await fetchAnnouncements();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> cancelAnnouncement(int id) async {
    try {
      final res = await ApiService.post(ApiEndpoints.cancelAnnouncement(id));
      if (res.statusCode == 200) {
        await fetchAnnouncements();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
