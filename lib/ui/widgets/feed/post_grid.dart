import 'package:flutter/material.dart';

import '../../../data/models/post.dart';
import '../common/ad_placeholder.dart';
import 'post_card.dart';

class PostGrid extends StatelessWidget {
  final List<Post> posts;
  final Function(Post) onPostTap;
  final bool withInlineAds;

  const PostGrid({
    super.key,
    required this.posts,
    required this.onPostTap,
    this.withInlineAds = false,
  });

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return const Center(child: Text('No posts yet.'));
    }

    // Simple list + optional ad slot after 3rd item
    final children = <Widget>[];
    for (var i = 0; i < posts.length; i++) {
      if (withInlineAds && i == 3) {
        children.add(const AdPlaceholder(height: 120));
      }
      children.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: PostCard(
            post: posts[i],
            onTap: () => onPostTap(posts[i]),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}
