import 'package:flutter/material.dart';
import 'core/router/app_router.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Farmers Market',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
        useMaterial3: true,
      ),
      routerConfig: appRouter,
      builder: (context, child) {
        final width = MediaQuery.of(context).size.width;
        // Phone: constrain to 480px centered
        // Tablet (600px+): constrain to 720px centered
        // Large tablet/desktop: constrain to 800px centered
        final maxWidth = width < 600
            ? 480.0
            : width < 900
            ? 720.0
            : 800.0;

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: child!,
          ),
        );
      },
    );
  }
}
