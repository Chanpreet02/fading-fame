import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/models/user_profile.dart';
import '../data/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repo = AuthRepository();

  UserProfile? _profile;
  bool _isLoading = false;
  String? _error;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _repo.currentUser != null;
  bool get isAdmin => _profile?.isStaff ?? false;

  void init() {
    _subscribeAuthChanges();
    _loadInitialProfile();
  }

  Future<void> _loadInitialProfile() async {
    if (_repo.currentUser == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      _profile = await _repo.getCurrentProfile();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _subscribeAuthChanges() {
    _repo.authStateChanges.listen((event) async {
      final type = event.event;
      if (type == AuthChangeEvent.signedIn) {
        _profile = await _repo.getCurrentProfile();
      } else if (type == AuthChangeEvent.signedOut) {
        _profile = null;
      }
      notifyListeners();
    });
  }

  Future<void> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repo.signInWithGoogle();
      // On web, redirect; on mobile, will come back via deep link
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithFacebook() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repo.signInWithFacebook();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repo.signOut();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
