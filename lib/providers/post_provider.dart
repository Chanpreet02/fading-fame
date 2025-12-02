import 'package:flutter/foundation.dart';

import '../data/models/post.dart';
import '../data/repositories/post_repository.dart';

class PostProvider extends ChangeNotifier {
  final PostRepository _repo = PostRepository();

  List<Post> _homePosts = [];
  bool _isHomeLoading = false;
  String? _homeError;
  bool _hasMoreHome = true;
  int _homeOffset = 0;

  List<Post> get homePosts => _homePosts;
  bool get isHomeLoading => _isHomeLoading;
  String? get homeError => _homeError;
  bool get hasMoreHome => _hasMoreHome;

  Future<void> loadHomeFeed({bool refresh = false}) async {
    if (_isHomeLoading) return;
    if (refresh) {
      _homeOffset = 0;
      _homePosts = [];
      _hasMoreHome = true;
    }
    if (!_hasMoreHome) return;

    _isHomeLoading = true;
    _homeError = null;
    notifyListeners();
    try {
      final posts = await _repo.getHomeFeed(offset: _homeOffset);
      if (posts.isEmpty) {
        _hasMoreHome = false;
      } else {
        _homeOffset += posts.length;
        _homePosts.addAll(posts);
      }
    } catch (e) {
      _homeError = e.toString();
    } finally {
      _isHomeLoading = false;
      notifyListeners();
    }
  }

  Future<List<Post>> loadCategoryPosts(int categoryId,
      {int offset = 0}) async {
    return _repo.getPostsByCategory(categoryId: categoryId, offset: offset);
  }

  Future<Post> loadPostDetail(int postId) async {
    return _repo.getPostWithMedia(postId);
  }
}
