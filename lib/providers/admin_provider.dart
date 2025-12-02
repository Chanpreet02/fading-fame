import 'package:flutter/foundation.dart' hide Category;

import '../data/models/category.dart';
import '../data/models/post.dart';
import '../data/models/user_profile.dart';
import '../data/repositories/category_repository.dart';
import '../data/repositories/post_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  Future<void> loadAllAdminData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _categories = await _categoryRepo.getAllCategories();
      _posts = await _postRepo.getAllPosts();
      final resp = await _client.from('profiles').select();
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

  Future<void> toggleCategoryVisibility(Category category) async {
    await _categoryRepo.updateCategoryVisibility(category.id, !category.isVisible);
    await loadAllAdminData();
  }

  Future<void> createCategory({
    required String name,
    required String slug,
    String? description,
  }) async {
    await _categoryRepo.createCategory(
      name: name,
      slug: slug,
      description: description,
    );
    await loadAllAdminData();
  }

  Future<void> changeUserRole(String userId, String role) async {
    await _client
        .from('profiles')
        .update({'role': role})
        .eq('id', userId);
    await loadAllAdminData();
  }
}
