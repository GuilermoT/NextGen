import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nextgen_fantasy/core/providers/supabase_provider.dart';
import 'package:nextgen_fantasy/features/auth/data/repositories/auth_repository.dart';
import 'package:nextgen_fantasy/features/auth/domain/models/user_model.dart';

part 'auth_notifier.g.dart';

@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  late AuthRepository _repo;

  @override
  Future<UserModel?> build() async {
    _repo = AuthRepository(ref.watch(supabaseClientProvider));

    final sub = _repo.authStateChanges().listen((authState) {
      if (authState.event == AuthChangeEvent.signedIn) {
        _syncProfile();
      } else if (authState.event == AuthChangeEvent.signedOut) {
        state = const AsyncData(null);
      }
    });

    ref.onDispose(sub.cancel);

    return _repo.fetchCurrentProfile();
  }

  Future<void> signInWithGoogle() async {
    await _repo.signInWithGoogle();
  }

  Future<void> signOut() async {
    await _repo.signOut();
  }

  Future<void> _syncProfile() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.fetchCurrentProfile());
  }
}
