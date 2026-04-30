import 'package:dio/dio.dart';
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
          String message = 'Something went wrong. Please try again.';

          if (response != null) {
            final data = response.data;

            if (data is Map<String, dynamic>) {
              if (data['errors'] != null && data['errors'] is Map) {
                final errors = data['errors'] as Map<String, dynamic>;
                final messages = errors.values
                    .expand(
                      (e) => e is List ? e.cast<String>() : [e.toString()],
                    )
                    .toList();
                message = messages.join('\n');
              } else if (data['message'] != null) {
                message = data['message'].toString();
              }
            } else if (data is String && data.isNotEmpty) {
              message = 'Server error. Please try again.';
            }

            // Status-specific fallbacks
            switch (response.statusCode) {
              case 401:
                message = data is Map && data['message'] != null
                    ? data['message']
                    : 'Session expired. Please login again.';
                break;
              case 403:
                message = data is Map && data['message'] != null
                    ? data['message']
                    : 'You are not authorized to perform this action.';
                break;
              case 404:
                message = data is Map && data['message'] != null
                    ? data['message']
                    : 'Resource not found.';
                break;
              case 422:
                break;
              case 500:
                message = 'Server error. Please contact support.';
                break;
            }
          } else if (error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.receiveTimeout) {
            message = 'Connection timed out. Check your internet.';
          } else if (error.type == DioExceptionType.connectionError) {
            message = 'Cannot reach server. Make sure the API is running.';
          } else if (error.type == DioExceptionType.unknown) {
            message = 'Network error. Check your connection.';
          }

          handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: AppException(message, statusCode: response?.statusCode),
              response: response,
              type: error.type,
            ),
          );
        },
      ),
    );

    return dio;
  }
}
