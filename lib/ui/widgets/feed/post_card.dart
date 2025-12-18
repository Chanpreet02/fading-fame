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
      hoverColor: Colors.transparent,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,

      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LEFT IMAGE
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AppNetworkImage(
                  url: post.coverImageUrl,
                  width: 300,
                  height: 300,
                ),
              ),

              const SizedBox(width: 14),

              // RIGHT CONTENT
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TITLE (bold like your example)
                    Text(
                      post.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.h5,
                    ),

                    const SizedBox(height: 8),

                    // EXCERPT / CONTENT
                    if (post.excerpt != null && post.excerpt!.isNotEmpty)
                      Text(
                        post.excerpt!,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body2,
                      ),

                    const SizedBox(height: 12),
                    if(post.content!=null ) Text(post.content??'', maxLines: 5,),
                    const SizedBox(height: 10,),
                    // META ROW
                    Row(
                      children: [
                        const Text(
                          'Fading Fame',
                          style: AppTextStyles.body2,
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.circle,
                          size: 4,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          dateStr,
                          style: AppTextStyles.body2,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
