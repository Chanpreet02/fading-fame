import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/category.dart';

class CategoryRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Category>> getVisibleCategories() async {
    final response = await _client
        .from('categories')
        .select()
        .eq('is_visible', true)
        .order('name', ascending: true);

    return (response as List)
        .map((e) => Category.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<Category>> getAllCategories() async {
    final response = await _client
        .from('categories')
        .select()
        .order('name', ascending: true);

    return (response as List)
        .map((e) => Category.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> createCategory({
    required String name,
    required String slug,
    String? description,
  }) async {
    await _client.from('categories').insert({
      'name': name,
      'slug': slug,
      'description': description,
      'is_visible': true,
    });
  }

  Future<void> updateCategoryVisibility(int id, bool visible) async {
    await _client
        .from('categories')
        .update({'is_visible': visible}).eq('id', id);
  }
}
