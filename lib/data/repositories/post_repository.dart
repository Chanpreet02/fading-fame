import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/post.dart';
import '../models/post_media.dart';
import '../../core/constants/api_constants.dart';

class PostRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Post>> getHomeFeed({int offset = 0}) async {
    final response = await _client
        .from('posts')
        .select()
        .eq('status', 'published')
        .order('published_at', ascending: false)
        .range(offset, offset + ApiConstants.homePageSize - 1);

    return (response as List)
        .map((e) => Post.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<Post>> getPostsByCategory({
    required int categoryId,
    int offset = 0,
  }) async {
    final response = await _client
        .from('posts')
        .select()
        .eq('status', 'published')
        .eq('category_id', categoryId)
        .order('published_at', ascending: false)
        .range(offset, offset + ApiConstants.categoryPageSize - 1);

    return (response as List)
        .map((e) => Post.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<Post> getPostWithMedia(int postId) async {
    final postResp = await _client
        .from('posts')
        .select()
        .eq('id', postId)
        .maybeSingle();

    if (postResp == null) {
      throw Exception('Post not found');
    }

    final mediaResp = await _client
        .from('post_media')
        .select()
        .eq('post_id', postId)
        .order('position', ascending: true);

    final post = Post.fromMap(Map<String, dynamic>.from(postResp));
    final media = (mediaResp as List)
        .map((e) => PostMedia.fromMap(Map<String, dynamic>.from(e)))
        .toList();

    return post.copyWith(media: media);
  }

  // Simple admin create/edit – assume RLS allows staff
  Future<void> createPost(Map<String, dynamic> data) async {
    await _client.from('posts').insert(data);
  }

  Future<void> updatePost(int id, Map<String, dynamic> data) async {
    await _client.from('posts').update(data).eq('id', id);
  }

  Future<List<Post>> getAllPosts() async {
    final response = await _client
        .from('posts')
        .select()
        .order('created_at', ascending: false);

    return (response as List)
        .map((e) => Post.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }
}
