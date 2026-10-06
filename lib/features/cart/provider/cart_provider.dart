import 'package:cartiva/features/home/model/productModel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final cartProvider = NotifierProvider<CartController, List<CartItem>>(
  CartController.new,
);

class CartItem {
  final Product product;
  final String size;
  final int quantity;

  const CartItem({
    required this.product,
    required this.size,
    this.quantity = 1,
  });

  CartItem copyWith({int? quantity}) {
    return CartItem(
      product: product,
      size: size,
      quantity: quantity ?? this.quantity,
    );
  }
}

class CartController extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() => const [];

  void add(Product product, String size) {
    final index = state.indexWhere(
      (item) => item.product.id == product.id && item.size == size,
    );

    if (index == -1) {
      state = [...state, CartItem(product: product, size: size)];
      return;
    }

    final updated = [...state];
    updated[index] = updated[index].copyWith(
      quantity: updated[index].quantity + 1,
    );
    state = updated;
  }

  void increment(CartItem item) {
    _updateQuantity(item, item.quantity + 1);
  }

  void decrement(CartItem item) {
    if (item.quantity == 1) return;
    _updateQuantity(item, item.quantity - 1);
  }

  void remove(CartItem item) {
    state = state.where((current) => current != item).toList();
  }

  void _updateQuantity(CartItem item, int quantity) {
    state = [
      for (final current in state)
        current == item ? current.copyWith(quantity: quantity) : current,
    ];
  }
}
