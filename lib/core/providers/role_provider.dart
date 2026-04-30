import 'package:flutter_riverpod/flutter_riverpod.dart';

final userRoleProvider = StateProvider<String>((ref) => '');

extension RoleCheck on String {
  bool get isAdmin => this == 'admin';
  bool get isSupervisor => this == 'supervisor';
  bool get isOperator => this == 'operator';
}
