import '../../products/models/product_model.dart';

class CartItem {
  final ProductModel product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get subtotal => product.price * quantity;
}

class CartModel {
  final List<CartItem> items;

  CartModel({this.items = const []});

  double get subtotal => items.fold(0, (sum, i) => sum + i.subtotal);

  double grandTotal(String paymentMethod, double interestRate) {
    if (paymentMethod == 'credit') {
      return subtotal * (1 + interestRate);
    }
    return subtotal;
  }
}
