import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AppNetworkImage extends StatelessWidget {
  final String? url;
  final double? height;
  final double? width;
  final BoxFit fit;
  final BorderRadiusGeometry? borderRadius;

  const AppNetworkImage({
    super.key,
    required this.url,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final image = url == null || url!.isEmpty
        ? Container(
      color: Colors.grey.shade300,
      child: const Icon(Icons.image_not_supported),
    )
        : CachedNetworkImage(
      imageUrl: url!,
      fit: fit,
      placeholder: (context, _) => Container(
        color: Colors.grey.shade200,
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      errorWidget: (context, _, __) =>
      const Icon(Icons.broken_image, color: Colors.grey),
    );

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: SizedBox(
          height: height,
          width: width,
          child: image,
        ),
      );
    }

    return SizedBox(
      height: height,
      width: width,
      child: image,
    );
  }
}
