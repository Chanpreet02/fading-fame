// lib/data/repositories/post_repository.dart

import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/post.dart';
import '../models/post_media.dart';
import '../../core/constants/api_constants.dart';

class PostRepository {
  /// Fixed admin author (as per your setup)
  final String kFixedAdminAuthorId = '3a7975c6-e91d-44d0-9940-f759ba16b597';

  final SupabaseClient _client = Supabase.instance.client;

  /* -------------------------------------------------------------------------- */
  /*                               FETCH POSTS                                  */
  /* -------------------------------------------------------------------------- */

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

  /* -------------------------------------------------------------------------- */
  /*                             CREATE POST (OLD)                               */
  /* -------------------------------------------------------------------------- */

  /// Old single-cover create (safe for backward compatibility)
  Future<void> createPost({
    required String title,
    required String excerpt,
    required String content,
    required int categoryId,
    String? coverImageUrl,
  }) async {
    await _client.from('posts').insert({
      'title': title,
      'slug': _slugify(title),
      'excerpt': excerpt,
      'content': content,
      'category_id': categoryId,
      'author_id': kFixedAdminAuthorId,
      'status': 'published',
      'cover_image_url': coverImageUrl,
      'published_at': DateTime.now().toIso8601String(),
    });
  }

  /* -------------------------------------------------------------------------- */
  /*                    CREATE POST WITH MULTIPLE IMAGES                         */
  /* -------------------------------------------------------------------------- */

  /// ✅ Duplicate images ALLOWED
  /// ✅ Duplicate filenames ALLOWED
  /// ✅ Every image gets a UNIQUE storage path
  Future<void> createPostWithMedia({
    required String title,
    required String excerpt,
    required String content,
    required int categoryId,
    required List<Uint8List> imagesBytes,
    required List<String> imageNames,
  }) async {
    /// 1️⃣ Create post first
    final postData = await _client
        .from('posts')
        .insert({
      'title': title,
      'slug': _slugify(title),
      'excerpt': excerpt,
      'content': content,
      'category_id': categoryId,
      'author_id': kFixedAdminAuthorId,
      'status': 'published',
      'published_at': DateTime.now().toIso8601String(),
    })
        .select()
        .single();

    final int postId = postData['id'];

    if (imagesBytes.isEmpty) return;

    final storage = _client.storage.from('post-media');
    String? firstImageUrl;

    /// 2️⃣ Upload each image + insert into post_media
    for (int i = 0; i < imagesBytes.length; i++) {
      final Uint8List bytes = imagesBytes[i];
      final String originalName = imageNames[i];

      /// 🔥 UNIQUE PATH (duplicate safe)
      final String uniqueFileName =
          '${DateTime.now().millisecondsSinceEpoch}_$i\_$originalName';

      final String path = 'posts/$postId/$uniqueFileName';

      await storage.uploadBinary(
        path,
        bytes,
        fileOptions: const FileOptions(
          cacheControl: '3600',
          upsert: false,
        ),
      );

      final String publicUrl = storage.getPublicUrl(path);

      firstImageUrl ??= publicUrl;

      await _client.from('post_media').insert({
        'post_id': postId,
        'media_url': publicUrl,
        'media_type': 'image',
        'position': i,
      });
    }

    /// 3️⃣ Update cover image using first image
    if (firstImageUrl != null) {
      await _client
          .from('posts')
          .update({'cover_image_url': firstImageUrl})
          .eq('id', postId);
    }
  }

  /* -------------------------------------------------------------------------- */
  /*                         SINGLE IMAGE UPLOAD (SAFE)                          */
  /* -------------------------------------------------------------------------- */

  /// Used for legacy flows
  /// ✅ Duplicate filenames allowed
  Future<String> uploadCoverImage(Uint8List bytes, String filename) async {
    final storage = _client.storage.from('post-media');

    final uniqueName =
        '${DateTime.now().millisecondsSinceEpoch}_$filename';

    final path = 'covers/$uniqueName';

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

  /* -------------------------------------------------------------------------- */
  /*                             UPDATE / DELETE                                 */
  /* -------------------------------------------------------------------------- */

  Future<void> updatePost(int id, Map<String, dynamic> data) async {
    await _client.from('posts').update(data).eq('id', id);
  }

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

  /* -------------------------------------------------------------------------- */
  /*                                HELPERS                                     */
  /* -------------------------------------------------------------------------- */

  String _slugify(String text) {
    return text
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-');
  }
}
