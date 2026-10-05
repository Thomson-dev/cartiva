import 'package:cartiva/features/home/model/productModel.dart';
import 'package:flutter/material.dart';

class ProductCard extends StatefulWidget {
  final Product product;

  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image with a floating favorite button — Stack is the right
        // widget for layering the heart button on top of the photo.
        AspectRatio(
          aspectRatio: 0.8,
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  widget.product.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Material(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        _isFavorite = !_isFavorite;
                      });
                    },
                    icon: Icon(
                      _isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      size: 18,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          widget.product.name,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 4),
        // Price row — Row + optional discount Text, shown with .map-free
        // conditional rendering since it's a single optional item.
        Row(
          children: [
            Text(
              widget.product.price.toString(),
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            ),
            if (widget.product.discount != null) ...[
              const SizedBox(width: 6),
              Text(
                widget.product.discount!,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
