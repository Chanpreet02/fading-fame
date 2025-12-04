import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_user.dart';
import '../models/user_profile.dart';

class AuthRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Session? get currentSession => _client.auth.currentSession;
  User? get currentUser => _client.auth.currentUser;

  Future<UserProfile?> getCurrentProfile() async {
    final user = currentUser;
    if (user == null) return null;
    final response = await _client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();
    if (response == null) return null;
    return UserProfile.fromMap(Map<String, dynamic>.from(response));
  }

  Future<void> upsertProfile(UserProfile profile) async {
    await _client.from('profiles').upsert(profile.toMap());
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    String? fullName,
  }) async {
    // Bas itna hi kaam Flutter karega
    final res = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        if (fullName != null && fullName.isNotEmpty) 'full_name': fullName,
      },
    );

    return res;
  }


  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AppUser> signUp({
    required String fullName,
    required String email,
    required String password,
    int? age,
  }) async {
    // Check if email already exists
    final existing = await _client
        .from('app_users')
        .select('id')
        .eq('email', email)
        .maybeSingle();

    if (existing != null) {
      throw Exception('Email already registered');
    }

    final data = await _client
        .from('app_users')
        .insert({
      'full_name': fullName,
      'email': email,
      'password': password, // demo only (not secure)
      'age': age,
    })
        .select()
        .single();

    return AppUser.fromMap(Map<String, dynamic>.from(data));
  }

  /// Login: match email + password
  Future<AppUser?> login({
    required String email,
    required String password,
  }) async {
    final data = await _client
        .from('app_users')
        .select()
        .eq('email', email)
        .eq('password', password)
        .maybeSingle();

    if (data == null) return null;
    return AppUser.fromMap(Map<String, dynamic>.from(data));
  }

  Future<void> signInWithGoogle() async {
    await _client.auth.signInWithOAuth(OAuthProvider.google);
  }

  Future<void> signInWithFacebook() async {
    await _client.auth.signInWithOAuth(OAuthProvider.facebook);
  }
}
