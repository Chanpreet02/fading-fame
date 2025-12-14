import 'package:flutter/material.dart';

import '../../../data/models/category.dart';

class CategoryListItem extends StatelessWidget {
  final Category category;
  final VoidCallback onToggleVisibility;

  const CategoryListItem({
    super.key,
    required this.category,
    required this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white
        ),
        child: ListTile(
          title: Text(category.name),
          subtitle: Text(category.slug),
          trailing: Switch(
            value: category.isVisible,
            onChanged: (_) => onToggleVisibility(),
          ),
        ),
      ),
    );
  }
}
