import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart'; // authStateNotifier lives here
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await authStateNotifier.initialize();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('FLUTTER ERROR: ${details.exception}');
  };

  runApp(const ProviderScope(child: App()));
}
