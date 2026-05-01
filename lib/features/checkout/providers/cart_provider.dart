import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart_model.dart';
import '../../products/models/product_model.dart';
import '../../farmers/models/farmer_model.dart';

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addProduct(ProductModel product) {
    final existing = state.indexWhere((i) => i.product.id == product.id);
    if (existing >= 0) {
      final updated = List<CartItem>.from(state);
      updated[existing].quantity++;
      state = updated;
    } else {
      state = [...state, CartItem(product: product)];
    }
  }

  void removeProduct(int productId) {
    state = state.where((i) => i.product.id != productId).toList();
  }

  void updateQuantity(int productId, int quantity) {
    if (quantity <= 0) {
      removeProduct(productId);
      return;
    }
    state = state.map((i) {
      if (i.product.id == productId) i.quantity = quantity;
      return i;
    }).toList();
  }

  void clear() => state = [];

  double get subtotal => state.fold(0, (s, i) => s + i.subtotal);
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>(
  (ref) => CartNotifier(),
);

final paymentMethodProvider = StateProvider<String>((ref) => 'cash');

// MOVED HERE — selectedFarmerProvider lives in cart_provider so it persists
// through the full navigation stack: search → categories → products → checkout
final selectedFarmerProvider = StateProvider<FarmerModel?>((ref) => null);
