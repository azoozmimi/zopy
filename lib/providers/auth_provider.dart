import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../core/constants/api_endpoints.dart';
import '../core/services/api_service.dart';
import '../core/services/storage_service.dart';
import '../models/user.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
}

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.initial;
  User? _user;
  String? _errorMessage;

  AuthStatus get status => _status;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated && _user != null;

  AuthProvider() {
    checkAuth();
  }

  Future<void> checkAuth() async {
    _status = AuthStatus.loading;
    notifyListeners();

    // Check if custom base url saved
    final savedBaseUrl = await StorageService.getBaseUrl();
    if (savedBaseUrl != null && savedBaseUrl.isNotEmpty) {
      ApiEndpoints.setBaseUrl(savedBaseUrl);
    }

    final token = await StorageService.getToken();
    final cachedUser = await StorageService.getUser();

    if (token != null && cachedUser != null) {
      _user = cachedUser;
      _status = AuthStatus.authenticated;
      notifyListeners();

      // Optionally refresh profile from server in background
      try {
        final res = await ApiService.get(ApiEndpoints.profile);
        if (res.statusCode == 200) {
          _user = User.fromJson(res.data);
          await StorageService.saveUser(_user!);
          notifyListeners();
        }
      } catch (_) {
        // Keep cached user if offline
      }
    } else {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  Future<bool> login(String identifier, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await ApiService.post(
        ApiEndpoints.login,
        data: {'identifier': identifier, 'password': password},
      );

      if (res.statusCode == 200) {
        final data = res.data;
        final token = data['token'] as String;
        final refreshToken = data['refreshToken'] as String;
        _user = User.fromJson(data);

        await StorageService.saveTokens(token: token, refreshToken: refreshToken);
        await StorageService.saveUser(_user!);

        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else {
        _errorMessage = res.data['message'] ?? 'فشل تسجيل الدخول';
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }
    } on DioException catch (e) {
      _errorMessage = e.response?.data?['message'] ?? 'خطأ في الاتصال بالخادم. تأكد من تشغيل الـ Backend';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'حدث خطأ غير متوقع';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String username,
    required String password,
    String? studentId,
    required String joiningCode,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await ApiService.post(
        ApiEndpoints.register,
        data: {
          'fullName': fullName,
          'email': email,
          'username': username,
          'password': password,
          'studentId': studentId,
          'joiningCode': joiningCode,
        },
      );

      if (res.statusCode == 200) {
        final data = res.data;
        final token = data['token'] as String;
        final refreshToken = data['refreshToken'] as String;
        _user = User.fromJson(data);

        await StorageService.saveTokens(token: token, refreshToken: refreshToken);
        await StorageService.saveUser(_user!);

        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else {
        _errorMessage = res.data['message'] ?? 'فشل إنشاء الحساب';
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }
    } on DioException catch (e) {
      _errorMessage = e.response?.data?['message'] ?? 'خطأ في التسجيل. تأكد من صحة رمز الانضمام';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'حدث خطأ غير متوقع';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await StorageService.clearTokens();
    await StorageService.clearUser();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    try {
      final res = await ApiService.post(
        ApiEndpoints.changePassword,
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
