// lib/ui/widgets/admin/post_list_item.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/models/post.dart';

class PostListItem extends StatelessWidget {
  final Post post;
  final VoidCallback? onTap;
  final VoidCallback? onDelete; // 🔥 NEW

  const PostListItem({
    super.key,
    required this.post,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd MMM yyyy').format(post.createdAt);

    return ListTile(
      onTap: onTap,
      title: Text(post.title),
      subtitle: Text('${post.status} • $dateStr'),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: onDelete,
        tooltip: 'Delete post',
      ),
    );
  }
}
