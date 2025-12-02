import 'package:flutter/material.dart';

import '../../../data/models/post.dart';
import 'post_card.dart';

class PostGrid extends StatelessWidget {
  final List<Post> posts;
  final Function(Post) onPostTap;

  const PostGrid({
    super.key,
    required this.posts,
    required this.onPostTap,
  });

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return const Center(child: Text('No posts yet.'));
    }

    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return PostCard(
          post: post,
          onTap: () => onPostTap(post),
        );
      },
    );
  }
}
