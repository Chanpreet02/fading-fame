import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/admin_provider.dart';
import '../../widgets/admin/post_list_item.dart';

class ManagePostsScreen extends StatelessWidget {
  const ManagePostsScreen({super.key});

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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Post creation UI can be implemented here (form + image upload).'),
                  ),
                );
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
                          'Post edit screen can be implemented here.'),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
