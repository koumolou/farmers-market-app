import 'package:flutter/material.dart';

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
    final raw = error.toString();

    for (final prefix in [
      'DioException [unknown]:',
      'DioException [bad response]:',
      'DioException [connection error]:',
      'DioException [connection timeout]:',
      'Exception:',
    ]) {
      if (raw.contains(prefix)) {
        return raw.split(prefix).last.trim();
      }
    }

    return raw;
  }
}
