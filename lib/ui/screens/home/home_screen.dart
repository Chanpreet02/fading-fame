import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_routes.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/post.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/category_provider.dart';
import '../../../providers/post_provider.dart';
import '../../widgets/ads/adsense_banner.dart';
import '../../widgets/common/app_loader.dart';
import '../../widgets/common/app_error_view.dart';
import '../../widgets/common/ad_placeholder.dart';
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

    const threshold = 300.0;
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
    Navigator.pushNamed(
      context,
      AppRoutes.postDetail,
      arguments: {'postId': post.id},
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final categoryProvider = context.watch<CategoryProvider>();
    final postProvider = context.watch<PostProvider>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              children: [
                // Top app bar style header
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: InkWell(
                          onTap:(){
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomeScreen()));
                          },
                          child: Text(
                            'Fading Fame',
                            style: AppTextStyles.h4.copyWith(
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (auth.isAdmin)
                        IconButton(
                          tooltip: 'Admin dashboard',
                          onPressed: () {
                            Navigator.pushNamed(
                                context, AppRoutes.adminDashboard);
                          },
                          icon: const Icon(Icons.admin_panel_settings),
                        ),
                      if (auth.isLoggedIn) ...[
                        IconButton(
                          tooltip: 'Profile',
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.profile);
                          },
                          icon: const CircleAvatar(
                            radius: 16,
                            child: Icon(Icons.person, size: 18),
                          ),
                        ),
                      ] else ...[
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.login);
                          },
                          child: const Text('Login / Sign up'),
                        ),
                      ],
                      if (auth.isAdmin)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('New post'),
                            onPressed: () {
                              Navigator.pushNamed(
                                  context, AppRoutes.createPost);
                            },
                          ),
                        ),
                    ],
                  ),
                ),

                // Categories row
                SizedBox(
                  height: 56,
                  child: categoryProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: categoryProvider.categories.length,
                    separatorBuilder: (_, __) =>
                    const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final cat = categoryProvider.categories[index];
                      return ChoiceChip(
                        label: Text(cat.name),
                        selected: false, // currently just navigation
                        onSelected: (_) {
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
                        child: ListView(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(
                              16, 16, 16, 24), // global padding
                          children: [
                            // Hero heading
                            Text(
                              'Today\'s stories',
                              style: AppTextStyles.h5,
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Handpicked moments from around the world.',
                              style: AppTextStyles.body2,
                            ),

                            const SizedBox(height: 12),

                            const AdsenseBanner(
                              adSlot: '1111111111', // change slot here
                              height: 90,
                            ),

                            const SizedBox(height: 24),
                            // Post list
                            PostGrid(
                              posts: postProvider.homePosts,
                              onPostTap: _openPostDetail,
                              withInlineAds: true,
                            ),

                            if (postProvider.isHomeLoading)
                              const Padding(
                                padding: EdgeInsets.only(top: 16),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
