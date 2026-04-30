import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
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
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    // Auth interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SecureStorage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          // Debug — remove after testing
          if (kDebugMode) {
            print('REQUEST: ${options.method} ${options.uri}');
            print('HEADERS: ${options.headers}');
            if (options.data != null) print('BODY: ${options.data}');
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print('RESPONSE ${response.statusCode}: ${response.data}');
          }
          handler.next(response);
        },
        onError: (error, handler) {
          if (kDebugMode) {
            print('ERROR: ${error.response?.statusCode} ${error.message}');
            print('ERROR DATA: ${error.response?.data}');
          }

          final response = error.response;
          String message = 'Something went wrong';

          if (response != null) {
            final data = response.data;
            if (data is Map && data['message'] != null) {
              message = data['message'];
            }
            if (data is Map && data['errors'] != null) {
              final errors = data['errors'] as Map;
              message = errors.values
                  .expand((e) => e is List ? e : [e])
                  .join('\n');
            }
          } else {
            message = 'No internet connection or server unreachable';
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
