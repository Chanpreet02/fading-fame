import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/models/category.dart';
import '../data/models/post.dart';
import '../data/models/user_profile.dart';
import '../data/repositories/category_repository.dart';
import '../data/repositories/post_repository.dart';
import 'category_provider.dart';
import 'post_provider.dart';

class AdminProvider extends ChangeNotifier {
  final CategoryRepository _categoryRepo = CategoryRepository();
  final PostRepository _postRepo = PostRepository();
  final SupabaseClient _client = Supabase.instance.client;

  bool _isLoading = false;
  String? _error;

  List<Category> _categories = [];
  List<Post> _posts = [];
  List<UserProfile> _users = [];

  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Category> get categories => _categories;
  List<Post> get posts => _posts;
  List<UserProfile> get users => _users;

  List<UserProfile> get admins =>
      _users.where((u) => u.role == 'admin').toList();

  /* ---------------- AUTH SESSION FIX ---------------- */

  Future<void> _ensureSessionReady() async {
    if (_client.auth.currentSession != null) return;

    await _client.auth.onAuthStateChange.firstWhere(
          (event) => event.session != null,
    );
  }

  /* ---------------- LOAD DATA ---------------- */

  Future<void> loadAllAdminData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _categories = await _categoryRepo.getAllCategories();
      _posts = await _postRepo.getAllPosts();

      final resp = await _client.from('app_users').select();
      _users = (resp as List)
          .map((e) => UserProfile.fromMap(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /* ---------------- USER DELETE (FULL) ---------------- */

  Future<void> deleteUserCompletely(String userId) async {
    try {
      // 🔥 DIRECT DB DELETE (NO EDGE FUNCTION)
      await _client.from('app_users').delete().eq('id', userId);

      // UI update
      _users.removeWhere((u) => u.id == userId);
      notifyListeners();
    } catch (e) {
      log('Delete failed: $e');
      rethrow;
    }
  }

  Future<void> createCategory({
    required BuildContext context,
    required String name,
    String? description,
  }) async {
    final slug = _generateSlug(name);

    await _categoryRepo.createCategory(
      name: name,
      slug: slug,
      description: description,
    );
    await context.read<CategoryProvider>().loadCategories();
    await loadAllAdminData();
  }

  String _generateSlug(String text) {
    return text
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-');
  }

  Future<void> toggleCategoryVisibility(Category category) async {
    category.isVisible = !category.isVisible;
    notifyListeners();

    try {
      await _categoryRepo.updateCategoryVisibility(
        category.id,
        category.isVisible,
      );
    } catch (e) {
      category.isVisible = !category.isVisible;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> changeUserRole(String userId, String role) async {
    await _client.from('app_users').update({'role': role}).eq('id', userId);
    await loadAllAdminData();
  }

  Future<void> deletePost(Post post, BuildContext context) async {
    await _postRepo.deletePost(post.id);
    _posts.removeWhere((p) => p.id == post.id);

    Provider.of<PostProvider>(context, listen: false)
        .loadHomeFeed(refresh: true);

    notifyListeners();
  }

  Future<Session> _getSessionOrThrow() async {
    final client = Supabase.instance.client;
    final session = client.auth.currentSession;
    if (session == null) {
      throw Exception('Auth session not ready. Please try again.');
    }
    return session;
  }

}
