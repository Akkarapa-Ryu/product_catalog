
import 'package:flutter/material.dart';

class CategorySelector extends StatelessWidget {
  final List<String> categories;
  final String? selectedCategory;
  final ValueChanged<String?> onSelected;

  const CategorySelector({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onSelected,
  });

  String _formatCategory(String category) {
    return category
        .replaceAll('-', ' ')
        .split(' ')
        .map((word) =>
            word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildChip(
            label: 'All Items',
            value: null,
          ),

          ...categories.map((category) {
            return _buildChip(
              label: _formatCategory(category),
              value: category,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildChip({
  required String label,
  required String? value,
}) {
  final isSelected = selectedCategory == value;

  return Padding(
    padding: const EdgeInsets.only(right: 8),
    child: ChoiceChip(
      label: Text(label),
      selected: isSelected,

      onSelected: (selected) {
        if (selected) {
          onSelected(value);
        }
      },

      selectedColor: Colors.black87,
      backgroundColor: Colors.grey.shade100,

      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: FontWeight.w600,
      ),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide.none,
      ),

      showCheckmark: false,
    ),
  );
}
}
