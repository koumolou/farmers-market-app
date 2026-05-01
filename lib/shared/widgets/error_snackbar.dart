import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../core/errors/app_exception.dart';

class AppSnackbar {
  static void error(BuildContext context, Object error) {
    final message = _parseError(error);
    _show(context, message, isError: true);
  }

  static void success(BuildContext context, String message) {
    _show(context, message, isError: false);
  }

  static void _show(
    BuildContext context,
    String message, {
    required bool isError,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError
            ? const Color(0xFFC62828)
            : const Color(0xFF2E7A45),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: Duration(seconds: isError ? 5 : 3),
      ),
    );
  }

  static String _parseError(Object error) {
    // AppException — our custom error with clean message
    if (error is AppException) {
      return error.message;
    }

    // DioException — extract from our interceptor's AppException
    if (error is DioException) {
      // Our interceptor wraps the real message in error.error
      if (error.error is AppException) {
        return (error.error as AppException).message;
      }

      // Fallback — parse response data directly
      final data = error.response?.data;
      if (data is Map) {
        if (data['errors'] != null && data['errors'] is Map) {
          final errors = data['errors'] as Map;
          return errors.values
              .expand((v) => v is List ? v.cast<String>() : [v.toString()])
              .join('\n');
        }
        if (data['message'] != null) {
          return data['message'].toString();
        }
      }

      // Connection errors
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Connection timed out. Check your internet.';
        case DioExceptionType.connectionError:
          return 'Cannot reach server. Make sure the API is running.';
        default:
          return 'Network error. Please try again.';
      }
    }

    // Generic exception — strip "Exception:" prefix Dart adds
    final raw = error.toString();
    if (raw.startsWith('Exception:')) {
      return raw.replaceFirst('Exception:', '').trim();
    }

    for (final prefix in [
      'DioException [unknown]:',
      'DioException [bad response]:',
      'DioException [connection error]:',
    ]) {
      if (raw.contains(prefix)) {
        final after = raw.split(prefix).last.trim();
        if (after.isNotEmpty && after != 'null') return after;
      }
    }

    return raw.isEmpty || raw == 'null' ? 'An unexpected error occurred.' : raw;
  }
}
