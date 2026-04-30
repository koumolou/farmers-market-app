import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../errors/app_exception.dart';
import '../storage/secure_storage.dart';

class DioClient {
  static Dio? _dio;

  static Dio get instance {
    _dio ??= _createDio();
    return _dio!;
  }

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Accept': 'application/json'},
      ),
    );

    // Auth interceptor — attaches token to every request
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SecureStorage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          final response = error.response;
          String message = 'Something went wrong';

          if (response != null) {
            final data = response.data;
            if (data is Map && data['message'] != null) {
              message = data['message'];
            }
            // Collect validation errors if present
            if (data is Map && data['errors'] != null) {
              final errors = data['errors'] as Map;
              message = errors.values
                  .expand((e) => e is List ? e : [e])
                  .join('\n');
            }
          } else {
            message = 'No internet connection';
          }

          handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: AppException(message, statusCode: response?.statusCode),
              response: response,
            ),
          );
        },
      ),
    );

    return dio;
  }
}
