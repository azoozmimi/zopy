import 'package:flutter/material.dart';
import '../core/constants/api_endpoints.dart';
import '../core/services/api_service.dart';
import '../models/course.dart';

class CourseProvider extends ChangeNotifier {
  List<Course> _courses = [];
  bool _isLoading = false;

  List<Course> get courses => _courses;
  bool get isLoading => _isLoading;

  Future<void> fetchCourses() async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await ApiService.get(ApiEndpoints.courses);
      if (res.statusCode == 200) {
        _courses = (res.data as List<dynamic>)
            .map((e) => Course.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      // offline fallback
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
