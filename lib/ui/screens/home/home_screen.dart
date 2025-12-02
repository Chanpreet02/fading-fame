import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_routes.dart';
import '../../../data/models/post.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/category_provider.dart';
import '../../../providers/post_provider.dart';
import '../../widgets/common/app_loader.dart';
import '../../widgets/common/app_error_view.dart';
import '../../widgets/feed/post_grid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final postProvider = context.read<PostProvider>();
    if (!_scrollController.hasClients || postProvider.isHomeLoading) return;

    final threshold = 300.0;
    if (_scrollController.position.extentAfter < threshold &&
        postProvider.hasMoreHome) {
      postProvider.loadHomeFeed();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _openPostDetail(Post post) {
    Navigator.pushNamed(context, AppRoutes.postDetail,
        arguments: {'postId': post.id});
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final categoryProvider = context.watch<CategoryProvider>();
    final postProvider = context.watch<PostProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fading Fame'),
        actions: [
          if (auth.isAdmin)
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.adminDashboard);
              },
              icon: const Icon(Icons.admin_panel_settings),
            ),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.profile);
            },
            icon: const Icon(Icons.person),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 60,
            child: categoryProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: categoryProvider.categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = categoryProvider.categories[index];
                return ActionChip(
                  label: Text(cat.name),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.categoryPosts,
                      arguments: {
                        'categoryId': cat.id,
                        'categoryName': cat.name,
                      },
                    );
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: Builder(
              builder: (context) {
                if (postProvider.homeError != null) {
                  return AppErrorView(
                    message: postProvider.homeError!,
                    onRetry: () =>
                        postProvider.loadHomeFeed(refresh: true),
                  );
                }
                if (postProvider.homePosts.isEmpty &&
                    postProvider.isHomeLoading) {
                  return const AppLoader(message: 'Loading stories...');
                }
                return RefreshIndicator(
                  onRefresh: () =>
                      postProvider.loadHomeFeed(refresh: true),
                  child: Stack(
                    children: [
                      PostGrid(
                        posts: postProvider.homePosts,
                        onPostTap: _openPostDetail,
                      ),
                      if (postProvider.isHomeLoading)
                        const Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
