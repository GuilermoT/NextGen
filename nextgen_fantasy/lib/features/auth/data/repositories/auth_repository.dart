import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nextgen_fantasy/features/auth/domain/models/user_model.dart';

class AuthRepository {
  final SupabaseClient _client;

  const AuthRepository(this._client);

  Future<void> signInWithGoogle() async {
    await _client.auth.signInWithOAuth(OAuthProvider.google);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Stream<AuthState> authStateChanges() {
    return _client.auth.onAuthStateChange;
  }

  /// Fetches the authenticated user's row from [profiles].
  /// Returns null when no session exists.
  /// Called by AuthNotifier after receiving a signedIn AuthState event.
  Future<UserModel?> fetchCurrentProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    final data = await _client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();
    return UserModel.fromJson(data);
  }
}
