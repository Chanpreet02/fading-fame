import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class AdPlaceholder extends StatelessWidget {
  final double height;
  final EdgeInsetsGeometry margin;

  const AdPlaceholder({
    super.key,
    this.height = 90,
    this.margin = const EdgeInsets.symmetric(vertical: 16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
          style: BorderStyle.solid,
        ),
      ),
      child: const Center(
        child: Text(
          'Ad space · 728×90 / 320×100',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}
