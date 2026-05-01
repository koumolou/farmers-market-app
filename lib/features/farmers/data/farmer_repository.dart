import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../models/farmer_model.dart';

class FarmerRepository {
  final _dio = DioClient.instance;

  Future<FarmerModel> search(String query) async {
    final response = await _dio.get(
      ApiConstants.farmerSearch,
      queryParameters: {'query': query},
    );
    return FarmerModel.fromJson(response.data['data']);
  }

  Future<FarmerModel> create(Map<String, dynamic> data) async {
    final response = await _dio.post(ApiConstants.farmers, data: data);
    return FarmerModel.fromJson(response.data['data']);
  }

  Future<Map<String, dynamic>> getProfile(int farmerId) async {
    final response = await _dio.get('${ApiConstants.farmers}/$farmerId');
    return response.data['data'];
  }
}

final farmerRepositoryProvider = Provider<FarmerRepository>(
  (ref) => FarmerRepository(),
);
