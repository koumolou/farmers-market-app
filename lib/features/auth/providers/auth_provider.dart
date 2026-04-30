import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';
import '../../../core/router/app_router.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository());

class AuthNotifierProvider extends StateNotifier<AsyncValue<void>> {
  AuthNotifierProvider(this._repo) : super(const AsyncData(null));

  final AuthRepository _repo;

  Future<bool> login(String email, String password) async {
    state = const AsyncLoading();
    try {
      await _repo.login(email, password);
      authStateNotifier.setLoggedIn(true);
      state = const AsyncData(null);
      return true;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    authStateNotifier.setLoggedIn(false);
  }
}

final authProvider =
    StateNotifierProvider<AuthNotifierProvider, AsyncValue<void>>(
      (ref) => AuthNotifierProvider(ref.read(authRepositoryProvider)),
    );
