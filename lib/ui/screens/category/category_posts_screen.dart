import 'package:flutter/material.dart';

import '../../../data/models/post.dart';
import '../../../providers/post_provider.dart';
import '../../widgets/feed/post_grid.dart';
import '../../widgets/common/app_loader.dart';
import '../../widgets/common/app_error_view.dart';
import 'package:provider/provider.dart';

class CategoryPostsScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const CategoryPostsScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<CategoryPostsScreen> createState() => _CategoryPostsScreenState();
}

class _CategoryPostsScreenState extends State<CategoryPostsScreen> {
  late Future<List<Post>> _future;

  @override
  void initState() {
    super.initState();
    _future = context
        .read<PostProvider>()
        .loadCategoryPosts(widget.categoryId);
  }

  void _openPostDetail(Post post) {
    Navigator.pushNamed(context, '/post-detail',
        arguments: {'postId': post.id});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
      ),
      body: FutureBuilder<List<Post>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoader();
          }
          if (snapshot.hasError) {
            return AppErrorView(
              message: snapshot.error.toString(),
              onRetry: () {
                setState(() {
                  _future = context
                      .read<PostProvider>()
                      .loadCategoryPosts(widget.categoryId);
                });
              },
            );
          }
          final posts = snapshot.data ?? [];
          return PostGrid(
            posts: posts,
            onPostTap: _openPostDetail,
          );
        },
      ),
    );
  }
}
