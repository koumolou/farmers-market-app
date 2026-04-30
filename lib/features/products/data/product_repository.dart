import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../models/product_model.dart';

class ProductRepository {
  final _dio = DioClient.instance;

  Future<List<CategoryModel>> getCategories() async {
    final response = await _dio.get(ApiConstants.categories);
    return (response.data['data'] as List)
        .map((c) => CategoryModel.fromJson(c))
        .toList();
  }

  Future<List<ProductModel>> getProducts({int? categoryId}) async {
    final response = await _dio.get(
      ApiConstants.products,
      queryParameters: categoryId != null ? {'category_id': categoryId} : null,
    );
    return (response.data['data'] as List)
        .map((p) => ProductModel.fromJson(p))
        .toList();
  }
}
