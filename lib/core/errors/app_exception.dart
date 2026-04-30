class AppException implements Exception {
  final String message;
  final int? statusCode;

  AppException(this.message, {this.statusCode});

  @override
  String toString() => message;

  // Call this anywhere you catch a DioException to get a clean string
  static String parse(Object error) {
    if (error is AppException) return error.message;

    if (error is Exception) {
      final msg = error.toString();
      // Strip "Exception:" prefix Dart adds
      if (msg.startsWith('Exception:')) {
        return msg.replaceFirst('Exception:', '').trim();
      }
      return msg;
    }

    return 'An unexpected error occurred.';
  }
}
