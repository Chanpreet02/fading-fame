import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/app_user.dart';
import '../data/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repo = AuthRepository();
  final SupabaseClient _supabase = Supabase.instance.client;

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

  Future<bool> sendPasswordReset(String email) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _supabase.auth.resetPasswordForEmail(email);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final email = _user?.email;
      if (email == null) {
        _error = 'User not logged in';
        return false;
      }

      /// 🔐 STEP 1: Re-authenticate with OLD password
      final res = await _supabase.auth.signInWithPassword(
        email: email,
        password: oldPassword,
      );

      if (res.session == null) {
        _error = 'Old password is incorrect';
        return false;
      }

      /// 🔐 STEP 2: Update password
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyPasswordAndSendReset({
    required String oldPassword,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final email = user!.email.toLowerCase().trim();

      /// 🔐 VERIFY password via fresh login
      final res = await _supabase.auth.signInWithPassword(
        email: email,
        password: oldPassword,
      );

      if (res.user == null) {
        throw 'Invalid password';
      }

      /// 🔥 IMPORTANT: sign out immediately
      await _supabase.auth.signOut();

      /// 🔁 Send reset email
      await _supabase.auth.resetPasswordForEmail(email);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Current password is incorrect';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }


}
