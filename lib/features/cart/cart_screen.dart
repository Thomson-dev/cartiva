import 'package:cartiva/features/cart/provider/cart_provider.dart';
import 'package:cartiva/features/notifications/notifications_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  static const double vat = 0;
  static const double shippingFee = 80;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(cartProvider);
    final subTotal = items.fold<double>(
      0,
      (sum, item) => sum + item.product.price * item.quantity,
    );
    final total = subTotal + vat + (items.isEmpty ? 0 : shippingFee);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'My Cart',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1),
        ),
      ),
      body: items.isEmpty
          ? const EmptyCart()
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      for (final item in items)
                        CartItemCard(
                          item: item,
                          onIncrease: () =>
                              ref.read(cartProvider.notifier).increment(item),
                          onDecrease: () =>
                              ref.read(cartProvider.notifier).decrement(item),
                          onDelete: () =>
                              ref.read(cartProvider.notifier).remove(item),
                        ),
                      const SizedBox(height: 8),
                      SummaryRow(label: 'Sub-total', amount: subTotal),
                      const SummaryRow(label: 'VAT (%)', amount: vat),
                      const SummaryRow(
                        label: 'Shipping fee',
                        amount: shippingFee,
                      ),
                      const Divider(height: 32),
                      SummaryRow(label: 'Total', amount: total, isBold: true),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Checkout is coming soon'),
                          ),
                        );
                      },
                      iconAlignment: IconAlignment.end,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Go To Checkout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A1A1A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class CartItemCard extends StatelessWidget {
  final CartItem item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onDelete;

  const CartItemCard({
    super.key,
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.network(
              item.product.imageUrl,
              width: 74,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                width: 74,
                height: 70,
                color: Colors.grey.shade200,
                child: const Icon(Icons.image, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Size ${item.size}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 14),
                Text(
                  '\$ ${formatMoney(item.product.price)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                tooltip: 'Remove item',
                onPressed: onDelete,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 20,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  QuantityButton(icon: Icons.remove, onTap: onDecrease),
                  SizedBox(
                    width: 28,
                    child: Text(
                      '${item.quantity}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  QuantityButton(icon: Icons.add, onTap: onIncrease),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const QuantityButton({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black54),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }
}

class SummaryRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool isBold;

  const SummaryRow({
    super.key,
    required this.label,
    required this.amount,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: isBold ? Colors.black : Colors.grey.shade600,
            ),
          ),
          Text(
            '\$ ${formatMoney(amount)}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

String formatMoney(double value) {
  if (value == 0) return '0.00';
  return value
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',');
}

class EmptyCart extends StatelessWidget {
  const EmptyCart({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 24),
          const Text(
            'Your Cart Is Empty!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "When you add products, they'll\nappear here.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
