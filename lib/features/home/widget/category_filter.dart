import 'package:flutter/material.dart';
import '../model/productModel.dart';

class CategoryFilter extends StatelessWidget {
  final ProductCategory? selectedCategory;
  final ValueChanged<ProductCategory?> onCategorySelected;

  const CategoryFilter({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  static const categories = [
    ProductCategory.tshirts,
    ProductCategory.jeans,
    ProductCategory.shoes,
  ];

  String _categoryName(ProductCategory category) {
    switch (category) {
      case ProductCategory.tshirts:
        return 'Tshirts';
      case ProductCategory.jeans:
        return 'Jeans';
      case ProductCategory.shoes:
        return 'Shoes';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildChip(
            label: 'All',
            isSelected: selectedCategory == null,
            onTap: () => onCategorySelected(null),
          ),

          ...categories.map(
            (category) => _buildChip(
              label: _categoryName(category),
              isSelected: selectedCategory == category,
              onTap: () => onCategorySelected(category),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        showCheckmark: false,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w500,
        ),
        backgroundColor: Colors.white,
        selectedColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide.none,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }
}