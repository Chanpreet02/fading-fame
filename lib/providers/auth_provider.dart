import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/app_user.dart';
import '../data/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repo = AuthRepository();

  static const _userPrefsKey = 'ff_current_user';

  AppUser? _user;
  bool _isLoading = false;
  String? _error;

  AppUser? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get isLoggedIn => _user != null;

  bool get isAdmin =>
      _user?.role == 'admin' || _user?.role == 'client';

  /// 🔹 App start / reload pe call hoga
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_userPrefsKey);
    if (jsonString != null) {
      try {
        final map = jsonDecode(jsonString) as Map<String, dynamic>;
        _user = AppUser.fromMap(map);
      } catch (_) {
        // agar parsing fail ho jaye to ignore
      }
    }
    notifyListeners();
  }

  Future<void> _saveUserToPrefs(AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userPrefsKey, jsonEncode(user.toMap()));
  }

  Future<void> _clearUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userPrefsKey);
  }

  Future<bool> signUp({
    required String fullName,
    required String email,
    required String password,
    int? age,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newUser = await _repo.signUp(
        fullName: fullName,
        email: email,
        password: password,
        age: age,
      );
      _user = newUser;
      await _saveUserToPrefs(newUser);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final u = await _repo.login(email: email, password: password);
      if (u == null) {
        _error = 'Invalid email or password';
        return false;
      }
      _user = u;
      await _saveUserToPrefs(u);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _user = null;
    _clearUserFromPrefs();
    notifyListeners();
  }
}
