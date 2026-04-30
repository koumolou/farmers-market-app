import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../models/debt_model.dart';

class DebtRepository {
  final _dio = DioClient.instance;

  Future<List<DebtModel>> getFarmerDebts(int farmerId) async {
    final response = await _dio.get('${ApiConstants.farmers}/$farmerId');
    final debts = response.data['data']['open_debts'] as List;
    return debts.map((d) => DebtModel.fromJson(d)).toList();
  }

  Future<Map<String, dynamic>> recordRepayment(
    int farmerId,
    double kgReceived,
  ) async {
    final response = await _dio.post(
      ApiConstants.repayments,
      data: {'farmer_id': farmerId, 'kg_received': kgReceived},
    );
    return response.data['data'];
  }
}

final debtRepositoryProvider = Provider((ref) => DebtRepository());
