import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../constants/api_endpoints.dart';
import 'storage_service.dart';

class ApiService {
  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 20),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  static void initialize() {
    _dio.interceptors.clear();
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await StorageService.getToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException error, handler) async {
        if (error.response?.statusCode == 401) {
          // Attempt token refresh
          final refreshToken = await StorageService.getRefreshToken();
          if (refreshToken != null) {
            try {
              final refreshResponse = await Dio().post(
                ApiEndpoints.refreshToken,
                data: {'refreshToken': refreshToken},
              );
              if (refreshResponse.statusCode == 200) {
                final newToken = refreshResponse.data['token'];
                final newRefreshToken = refreshResponse.data['refreshToken'];
                await StorageService.saveTokens(token: newToken, refreshToken: newRefreshToken);

                // Retry original request
                final opts = Options(
                  method: error.requestOptions.method,
                  headers: {
                    ...error.requestOptions.headers,
                    'Authorization': 'Bearer $newToken',
                  },
                );
                final cloneReq = await _dio.request(
                  error.requestOptions.path,
                  options: opts,
                  data: error.requestOptions.data,
                  queryParameters: error.requestOptions.queryParameters,
                );
                return handler.resolve(cloneReq);
              }
            } catch (_) {
              await StorageService.clearTokens();
            }
          }
        }
        return handler.next(error);
      },
    ));
  }

  static Dio get client => _dio;

  // GET
  static Future<Response> get(String url, {Map<String, dynamic>? queryParameters}) async {
    return await _dio.get(url, queryParameters: queryParameters);
  }

  // POST
  static Future<Response> post(String url, {dynamic data}) async {
    return await _dio.post(url, data: data);
  }

  // PUT
  static Future<Response> put(String url, {dynamic data}) async {
    return await _dio.put(url, data: data);
  }

  // DELETE
  static Future<Response> delete(String url) async {
    return await _dio.delete(url);
  }

  // Download Attachment
  static Future<File?> downloadFile(String url, String fileName, {Function(int received, int total)? onProgress}) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final savePath = '${dir.path}/$fileName';

      final token = await StorageService.getToken();
      final options = Options(
        headers: token != null ? {'Authorization': 'Bearer $token'} : null,
        responseType: ResponseType.bytes,
      );

      final response = await _dio.get(
        url,
        options: options,
        onReceiveProgress: onProgress,
      );

      final file = File(savePath);
      await file.writeAsBytes(response.data as List<int>);
      return file;
    } catch (e) {
      return null;
    }
  }

  // Upload Attachment
  static Future<Response> uploadFile(String url, File file) async {
    final fileName = file.path.split(Platform.pathSeparator).last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: fileName),
    });

    return await _dio.post(
      url,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
  }

  // Upload Submission
  static Future<Response> uploadSubmission(String url, File file, {String? notes}) async {
    final fileName = file.path.split(Platform.pathSeparator).last;
    final map = <String, dynamic>{
      'file': await MultipartFile.fromFile(file.path, filename: fileName),
    };
    if (notes != null && notes.trim().isNotEmpty) {
      map['notes'] = notes.trim();
    }
    final formData = FormData.fromMap(map);

    return await _dio.post(
      url,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
  }
}
