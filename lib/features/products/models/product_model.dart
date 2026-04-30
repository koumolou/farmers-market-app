class CategoryModel {
  final int id;
  final String name;
  final int? parentId;
  final List<CategoryModel> children;

  CategoryModel({
    required this.id,
    required this.name,
    this.parentId,
    this.children = const [],
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
    id: json['id'],
    name: json['name'],
    parentId: json['parent_id'],
    children: (json['children'] as List<dynamic>? ?? [])
        .map((c) => CategoryModel.fromJson(c))
        .toList(),
  );
}

class ProductModel {
  final int id;
  final String name;
  final String? description;
  final double price;
  final int categoryId;

  ProductModel({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.categoryId,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    price: double.parse(json['price'].toString()),
    categoryId: json['category_id'],
  );
}
