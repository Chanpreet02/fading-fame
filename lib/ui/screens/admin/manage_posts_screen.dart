// lib/ui/screens/admin/manage_posts_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_routes.dart';
import '../../../data/models/post.dart';
import '../../../providers/admin_provider.dart';
import '../../widgets/admin/post_list_item.dart';

class ManagePostsScreen extends StatelessWidget {
  const ManagePostsScreen({super.key});

  Future<void> _confirmDelete(BuildContext context, Post post) async {
    final admin = context.read<AdminProvider>();

    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete post?'),
        content: Text(
          'Are you sure you want to delete:\n\n"${post.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    try {
      await admin.deletePost(post, context);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post deleted')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete post. Please try again.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.createPost);
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Post'),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: admin.posts.length,
            itemBuilder: (context, index) {
              final post = admin.posts[index];
              return PostListItem(
                post: post,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Post edit screen can be implemented here.',
                      ),
                    ),
                  );
                },
                onDelete: () => _confirmDelete(context, post), // 🔥 NEW
              );
            },
          ),
        ),
      ],
    );
  }
}
