// lib/data/repositories/post_repository.dart

import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/post.dart';
import '../models/post_media.dart';
import '../../core/constants/api_constants.dart';

class PostRepository {
  final String kFixedAdminAuthorId = '3a7975c6-e91d-44d0-9940-f759ba16b597';
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

  /// Old simple create (single cover) – agar kahin aur use ho raha ho to safe rahe
  Future<void> createPostOld(Map<String, dynamic> data) async {
    await _client.from('posts').insert(data);
  }

  /// Pehle jaisa single-cover create (compatibility ke liye)
  Future<void> createPost({
    required String title,
    required String excerpt,
    required String content,
    required int categoryId,
    String? coverImageUrl,
  }) async {
    await _client.from('posts').insert({
      'title': title,
      'slug': title.toLowerCase().replaceAll(' ', '-'),
      'excerpt': excerpt,
      'content': content,
      'category_id': categoryId,
      'author_id': kFixedAdminAuthorId,
      'status': 'published',
      'cover_image_url': coverImageUrl,
      'published_at': DateTime.now().toIso8601String(),
    });
  }

  /// Naya flow: ek post me multiple images
  Future<void> createPostWithMedia({
    required String title,
    required String excerpt,
    required String content,
    required int categoryId,
    required List<Uint8List> imagesBytes,
    required List<String> imageNames,
  }) async {
    // 1) Pehle post row create karo (cover_image_url abhi null rahega)
    final postData = await _client
        .from('posts')
        .insert({
      'title': title,
      'slug': title.toLowerCase().replaceAll(' ', '-'),
      'excerpt': excerpt,
      'content': content,
      'category_id': categoryId,
      'author_id': kFixedAdminAuthorId,
      'status': 'published',
      'published_at': DateTime.now().toIso8601String(),
    })
        .select()
        .single();

    final postId = postData['id'] as int;

    if (imagesBytes.isEmpty) {
      // koi image nahi – bas post hi rehne do
      return;
    }

    final storage = _client.storage.from('post-media');
    String? firstImageUrl;

    // 2) Saari images upload karo + post_media me insert karo
    for (var i = 0; i < imagesBytes.length; i++) {
      final bytes = imagesBytes[i];
      final name = imageNames[i];

      final path =
          'posts/$postId/${DateTime.now().millisecondsSinceEpoch}_$i\_$name';

      await storage.uploadBinary(
        path,
        bytes,
        fileOptions: const FileOptions(
          cacheControl: '3600',
          upsert: false,
        ),
      );

      final url = storage.getPublicUrl(path);

      // first image ka url cover ke liye store
      firstImageUrl ??= url;

      await _client.from('post_media').insert({
        'post_id': postId,
        'media_url': url,
        'media_type': 'image',
        'position': i,
      });
    }

    // 3) posts table me cover_image_url update karo (pehli image se)
    if (firstImageUrl != null) {
      await _client
          .from('posts')
          .update({'cover_image_url': firstImageUrl}).eq('id', postId);
    }
  }

  /// Single image upload helper (old use-cases ke liye)
  Future<String> uploadCoverImage(Uint8List bytes, String filename) async {
    final path = 'covers/$filename';
    final storage = _client.storage.from('post-media');

    await storage.uploadBinary(
      path,
      bytes,
      fileOptions: const FileOptions(
        cacheControl: '3600',
        upsert: false,
      ),
    );

    return storage.getPublicUrl(path);
  }

  Future<void> updatePost(int id, Map<String, dynamic> data) async {
    await _client.from('posts').update(data).eq('id', id);
  }

  /// 🔥 NEW: delete a post (admin dashboard)
  Future<void> deletePost(int id) async {
    await _client.from('posts').delete().eq('id', id);
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
