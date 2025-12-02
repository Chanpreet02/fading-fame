import 'package:supabase_flutter/supabase_flutter.dart';

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

  Future<bool> signInWithGoogle() {
    return _client.auth.signInWithOAuth(OAuthProvider.google);
  }

  Future<bool> signInWithFacebook() {
    return _client.auth.signInWithOAuth(OAuthProvider.facebook);
  }
}
