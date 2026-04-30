import 'dart:convert';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/storage/secure_storage.dart';

class AuthRepository {
  final _dio = DioClient.instance;

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _dio.post(
      ApiConstants.login,
      data: {'email': email, 'password': password},
    );
    final data = response.data['data'];
    await SecureStorage.saveToken(data['token']);
    await SecureStorage.saveUser(jsonEncode(data['user']));
    return data;
  }

  Future<void> logout() async {
    await _dio.post(ApiConstants.logout);
    await SecureStorage.clearAll();
  }
}
