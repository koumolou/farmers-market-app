import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/secure_storage.dart';

final userRoleProvider = FutureProvider<String?>((ref) async {
  return await SecureStorage.getRole();
});

extension RoleCheck on String? {
  bool get isAdmin => this == 'admin';
  bool get isSupervisor => this == 'supervisor';
  bool get isOperator => this == 'operator';
}
