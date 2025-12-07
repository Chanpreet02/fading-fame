// lib/ui/screens/post_detail/post_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/post.dart';
import '../../../data/models/post_media.dart';
import '../../../providers/post_provider.dart';
import '../../widgets/common/app_loader.dart';
import '../../widgets/common/app_network_image.dart';

class PostDetailScreen extends StatefulWidget {
  final int postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late Future<Post> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<PostProvider>().loadPostDetail(widget.postId);
  }

  void _share(Post post) {
    final text = '${post.title}\n\nFading Fame';
    Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Story'),
        centerTitle: true,
        actions: [
          FutureBuilder<Post>(
            future: _future,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.share),
                onPressed: () => _share(snapshot.data!),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<Post>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoader();
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final post = snapshot.data!;

          final date = (post.publishedAt ?? post.createdAt);
          final dateStr = DateFormat('dd MMM yyyy').format(date);

          // ---------- IMAGE LOGIC ----------
          // 1) Hero / cover image (IMAGE 1 – top, big, rounded)
          final String? coverUrl = post.coverImageUrl;

          // 2) Extra images = post.media se, cover ko hata ke
          final List<PostMedia> extraImages = List<PostMedia>.from(post.media);
          if (coverUrl != null) {
            extraImages.removeWhere((m) => m.mediaUrl == coverUrl);
          }

          // 3) Content ko paragraphs mein todhna
          final String rawContent = post.content ?? '';
          final List<String> paragraphs = rawContent
              .split(RegExp(r'\n\s*\n')) // blank line → new paragraph
              .map((p) => p.trim())
              .where((p) => p.isNotEmpty)
              .toList();

          // 4) Paragraph + inline images ke widgets
          final List<Widget> contentWidgets = [];

          for (int i = 0; i < paragraphs.length; i++) {
            // Text paragraph
            contentWidgets.add(
              Text(
                paragraphs[i],
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 16,
                  height: 1.6,
                  color: AppColors.textPrimary,
                ),
              ),
            );
            contentWidgets.add(const SizedBox(height: 16));

            // Har paragraph ke baad ek image, agar available ho
            if (i < extraImages.length) {
              final media = extraImages[i];
              contentWidgets.add(
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: AppNetworkImage(
                    url: media.mediaUrl,
                    height: 260,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              );
              contentWidgets.add(const SizedBox(height: 24));
            }
          }

          // Agar paragraphs empty hain, toh pura content ek hi text mein
          if (paragraphs.isEmpty && (post.content ?? '').isNotEmpty) {
            contentWidgets.add(
              Text(
                post.content!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 16,
                  height: 1.6,
                  color: AppColors.textPrimary,
                ),
              ),
            );
            contentWidgets.add(const SizedBox(height: 24));
          }

          // 5) Agar images paragraphs se zyada hain,
          //    bachi hui images ko last mein dikhana
          if (extraImages.length > paragraphs.length) {
            contentWidgets.add(const SizedBox(height: 8));
            contentWidgets.add(
              Text(
                'More from this story',
                style: AppTextStyles.h5.copyWith(fontSize: 18),
              ),
            );
            contentWidgets.add(const SizedBox(height: 12));

            for (int i = paragraphs.length; i < extraImages.length; i++) {
              final media = extraImages[i];
              contentWidgets.add(
                ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: AppNetworkImage(
                    url: media.mediaUrl,
                    height: 260,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              );
              contentWidgets.add(const SizedBox(height: 18));
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // -------- IMAGE 1 – Hero (old style, rounded) --------
                    if (coverUrl != null && coverUrl.isNotEmpty) ...[
                      AppNetworkImage(
                        url: coverUrl,
                        height: 360,
                        width: double.infinity,
                        borderRadius: BorderRadius.circular(28),
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Meta line
                    Text(
                      'FADING FAME  •  $dateStr',
                      style: AppTextStyles.body2.copyWith(
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Title
                    Text(
                      post.title,
                      style: AppTextStyles.h4.copyWith(
                        fontSize: 30,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Excerpt – intro block
                    if (post.excerpt != null &&
                        post.excerpt!.trim().isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          post.excerpt!,
                          style: AppTextStyles.body1.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Share row
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _share(post),
                          icon: const Icon(Icons.share),
                          label: const Text('Share story'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          onPressed: () => _share(post),
                          icon: const Icon(Icons.link),
                          tooltip: 'Share link',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Main content + inline images (IMAGE 2,3…)
                    ...contentWidgets,

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
