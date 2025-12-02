import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../data/models/post.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Story'),
      ),
      body: FutureBuilder<Post>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoader();
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          final post = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (post.coverImageUrl != null)
                  AppNetworkImage(
                    url: post.coverImageUrl,
                    height: 240,
                    width: double.infinity,
                  ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.title,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      if (post.excerpt != null)
                        Text(
                          post.excerpt!,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      const SizedBox(height: 16),
                      if (post.content != null)
                        Text(
                          post.content!,
                          style: const TextStyle(fontSize: 16, height: 1.4),
                        ),
                      const SizedBox(height: 16),
                      if (post.media.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Gallery',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: post.media.length,
                              itemBuilder: (context, index) {
                                final media = post.media[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      AppNetworkImage(
                                        url: media.mediaUrl,
                                        height: 220,
                                        width: double.infinity,
                                      ),
                                      if (media.caption != null)
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            media.caption!,
                                            style: const TextStyle(
                                                color: Colors.grey),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            )
                          ],
                        ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _share(post),
                            icon: const Icon(Icons.share),
                            label: const Text('Share'),
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
