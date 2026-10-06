import 'package:cartiva/features/home/model/productModel.dart';
import 'package:cartiva/features/cart/provider/cart_provider.dart';
import 'package:cartiva/features/home/provider/saved_products_provider.dart';
import 'package:cartiva/features/notifications/notifications_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductDetailsScreen extends ConsumerStatefulWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  ConsumerState<ProductDetailsScreen> createState() =>
      _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends ConsumerState<ProductDetailsScreen> {
  String? _selectedSize;

  void _addToCart() {
    if (_selectedSize == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please choose a size')));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added size $_selectedSize to cart')),
    );
    ref.read(cartProvider.notifier).add(widget.product, _selectedSize!);
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final isSaved = ref.watch(savedProductsProvider).contains(product.id);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Details',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
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
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProductImage(
              imageUrl: product.imageUrl,
              isSaved: isSaved,
              onHeartTap: () =>
                  ref.read(savedProductsProvider.notifier).toggle(product.id),
            ),
            const SizedBox(height: 16),
            Text(
              product.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const RatingRow(rating: 4, reviewCount: 45),
            const SizedBox(height: 12),
            Text(
              'The name says it all, the right size slightly snugs the body '
              'leaving enough room for comfort in the sleeves and waist.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Choose size',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            SizeSelector(
              sizes: const ['S', 'M', 'L'],
              selectedSize: _selectedSize,
              onSelected: (size) => setState(() => _selectedSize = size),
            ),
          ],
        ),
      ),
      bottomNavigationBar: PriceBar(
        price: product.price.toStringAsFixed(0),
        onAddToCart: _addToCart,
      ),
    );
  }
}

class ProductImage extends StatelessWidget {
  final String imageUrl;
  final bool isSaved;
  final VoidCallback onHeartTap;

  const ProductImage({
    super.key,
    required this.imageUrl,
    required this.isSaved,
    required this.onHeartTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: .95,
            child: Container(
              color: const Color(0xFFF5F5F7),
              width: double.infinity,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.image_not_supported_outlined,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 12,
          right: 12,
          child: Material(
            color: Colors.white,
            elevation: 2,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onHeartTap,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Icon(
                  isSaved ? Icons.favorite : Icons.favorite_border,
                  color: isSaved ? Colors.red : Colors.black,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class RatingRow extends StatelessWidget {
  final double rating;
  final int reviewCount;

  const RatingRow({super.key, required this.rating, required this.reviewCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.star, color: Colors.orange, size: 20),
        const SizedBox(width: 4),
        Text(
          '${rating.toStringAsFixed(1)}/5',
          style: const TextStyle(
            fontSize: 14,
            decoration: TextDecoration.underline,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '($reviewCount reviews)',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}

class SizeSelector extends StatelessWidget {
  final List<String> sizes;
  final String? selectedSize;
  final ValueChanged<String> onSelected;

  const SizeSelector({
    super.key,
    required this.sizes,
    required this.selectedSize,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      children: sizes.map((size) {
        final isSelected = size == selectedSize;
        return ChoiceChip(
          label: Text(size),
          selected: isSelected,
          showCheckmark: false,
          onSelected: (_) => onSelected(size),
          backgroundColor: Colors.white,
          selectedColor: const Color(0xFF1A1A1A),
          labelStyle: TextStyle(
            fontSize: 16,
            color: isSelected ? Colors.white : Colors.black,
          ),
          side: const BorderSide(color: Color(0xFFE5E5E5)),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        );
      }).toList(),
    );
  }
}

class PriceBar extends StatelessWidget {
  final String price;
  final VoidCallback onAddToCart;

  const PriceBar({super.key, required this.price, required this.onAddToCart});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFEDEDED))),
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Price',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 2),
                Text(
                  '\$ $price',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 24),
            Expanded(
              child: FilledButton.icon(
                onPressed: onAddToCart,
                icon: const Icon(Icons.shopping_bag_outlined),
                label: const Text(
                  'Add to Cart',
                  style: TextStyle(fontSize: 16),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF1A1A1A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
