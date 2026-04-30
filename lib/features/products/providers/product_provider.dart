import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/product_repository.dart';
import '../models/product_model.dart';

final productRepositoryProvider = Provider((ref) => ProductRepository());

final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  return ref.read(productRepositoryProvider).getCategories();
});

final selectedCategoryProvider = StateProvider<CategoryModel?>((ref) => null);

final productsProvider = FutureProvider<List<ProductModel>>((ref) async {
  final category = ref.watch(selectedCategoryProvider);
  return ref
      .read(productRepositoryProvider)
      .getProducts(categoryId: category?.id);
});
