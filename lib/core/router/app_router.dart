import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/farmers/screens/farmer_search_screen.dart';
import '../../features/farmers/screens/farmer_profile_screen.dart';
import '../../features/products/screens/category_screen.dart';
import '../../features/products/screens/product_list_screen.dart';
import '../../features/checkout/screens/checkout_screen.dart';
import '../../features/debts/screens/debt_list_screen.dart';
import '../../features/debts/screens/repayment_screen.dart';
import '../storage/secure_storage.dart';

final authStateNotifier = AuthNotifier();

class AuthNotifier extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool _initialized = false;

  bool get isLoggedIn => _isLoggedIn;
  bool get initialized => _initialized;

  Future<void> initialize() async {
    final token = await SecureStorage.getToken();
    _isLoggedIn = token != null;
    _initialized = true;
    notifyListeners();
  }

  void setLoggedIn(bool value) {
    _isLoggedIn = value;
    notifyListeners();
  }
}

final appRouter = GoRouter(
  initialLocation: '/login',
  refreshListenable: authStateNotifier,
  redirect: (context, state) {
    if (!authStateNotifier.initialized) return '/login';

    final onLogin = state.matchedLocation == '/login';

    if (!authStateNotifier.isLoggedIn && !onLogin) return '/login';
    if (authStateNotifier.isLoggedIn && onLogin) return '/farmers';

    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/farmers', builder: (_, __) => const FarmerSearchScreen()),
    GoRoute(
      path: '/farmers/:id',
      builder: (_, state) =>
          FarmerProfileScreen(farmerId: int.parse(state.pathParameters['id']!)),
    ),
    GoRoute(path: '/categories', builder: (_, __) => const CategoryScreen()),
    GoRoute(
      path: '/products',
      builder: (_, state) {
        final categoryId = state.uri.queryParameters['category_id'];
        return ProductListScreen(categoryId: int.tryParse(categoryId ?? ''));
      },
    ),
    GoRoute(path: '/checkout', builder: (_, __) => const CheckoutScreen()),
    GoRoute(
      path: '/debts/:farmerId',
      builder: (_, state) => DebtListScreen(
        farmerId: int.parse(state.pathParameters['farmerId']!),
      ),
    ),
    GoRoute(
      path: '/repayment/:farmerId',
      builder: (_, state) => RepaymentScreen(
        farmerId: int.parse(state.pathParameters['farmerId']!),
      ),
    ),
  ],
);
