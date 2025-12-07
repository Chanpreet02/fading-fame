import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/post.dart';
import '../common/app_network_image.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onTap;

  const PostCard({
    super.key,
    required this.post,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = post.publishedAt != null
        ? DateFormat('dd MMM yyyy').format(post.publishedAt!)
        : '';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with gradient overlay + title
            Stack(
              children: [
                AppNetworkImage(
                  url: post.coverImageUrl,
                  height: 220,
                  width: double.infinity,
                  borderRadius: BorderRadius.zero,
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.05),
                          Colors.black.withOpacity(0.55),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Text(
                    post.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.h5.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (post.excerpt != null && post.excerpt!.isNotEmpty)
                    Text(
                      post.excerpt!,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body2,
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text(
                        'Fading Fame',
                        style: AppTextStyles.body2,
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.circle,
                          size: 4, color: AppColors.textMuted),
                      const SizedBox(width: 8),
                      Text(
                        dateStr,
                        style: AppTextStyles.body2,
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: AppColors.textMuted,
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
