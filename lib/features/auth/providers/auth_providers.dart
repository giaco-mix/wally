import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/app_config.dart';
import '../../../core/providers.dart';

/// Stream dello stato di autenticazione Supabase.
final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.onAuthStateChange;
});

/// Sessione corrente (null se non loggato). In modalità demo restituisce
/// sempre una sessione fittizia così da bypassare il gate di login.
final sessionProvider = Provider<Session?>((ref) {
  if (!AppConfig.isConfigured) return _demoSession;
  ref.watch(authStateChangesProvider);
  return ref.watch(supabaseClientProvider).auth.currentSession;
});

final isLoggedInProvider = Provider<bool>((ref) {
  if (!AppConfig.isConfigured) return true; // demo: sempre dentro
  return ref.watch(sessionProvider) != null;
});

final authControllerProvider =
    AsyncNotifierProvider<AuthController, void>(AuthController.new);

class AuthController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  SupabaseClient get _client => ref.read(supabaseClientProvider);

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _client.auth.signInWithPassword(email: email, password: password);
    });
    if (state.hasError) throw state.error!;
  }

  Future<void> signUp(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _client.auth.signUp(email: email, password: password);
    });
    if (state.hasError) throw state.error!;
  }

  /// Avvia il flusso OAuth con Google. Su web reindirizza l'intera pagina a
  /// Google e poi ritorna all'origine corrente; al rientro `onAuthStateChange`
  /// aggiorna la sessione e il router porta in dashboard.
  Future<void> signInWithGoogle() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: kIsWeb ? Uri.base.origin : null,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}

// Sessione segnaposto usata solo per far girare l'app senza backend.
final _demoSession = Session(
  accessToken: 'demo',
  tokenType: 'bearer',
  user: const User(
    id: 'demo-user',
    appMetadata: {},
    userMetadata: {},
    aud: 'demo',
    createdAt: '',
  ),
);
