import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/router/app_router.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository());

class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  AuthNotifier(this._repo) : super(const AsyncData(null));

  final AuthRepository _repo;

  Future<bool> login(String email, String password) async {
    state = const AsyncLoading();
    try {
      await _repo.login(email, password);
      authStateNotifier.setLoggedIn(true);
      state = const AsyncData(null);
      return true;
    } on DioException catch (e) {
      final appError = e.error is AppException
          ? e.error as AppException
          : AppException(e.message ?? 'Login failed');
      state = AsyncError(appError, StackTrace.current);
      return false;
    } catch (e) {
      state = AsyncError(AppException(e.toString()), StackTrace.current);
      return false;
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    authStateNotifier.setLoggedIn(false);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<void>>(
  (ref) => AuthNotifier(ref.read(authRepositoryProvider)),
);
