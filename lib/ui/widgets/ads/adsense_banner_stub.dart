import 'package:flutter/material.dart';

class AdsenseBannerImpl extends StatelessWidget {
  final String adSlot;
  final double height;

  const AdsenseBannerImpl({
    super.key,
    required this.adSlot,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
