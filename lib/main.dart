import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/storage/secure_storage.dart';
import 'core/providers/role_provider.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await authStateNotifier.initialize();

  final savedRole = await SecureStorage.getRole() ?? '';

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('FLUTTER ERROR: ${details.exception}');
  };

  runApp(
    ProviderScope(
      overrides: [userRoleProvider.overrideWith((ref) => savedRole)],
      child: const App(),
    ),
  );
}
