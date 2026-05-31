/// Configurazione applicazione, valorizzata via --dart-define a build/run time:
///   flutter run -d chrome \
///     --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
///     --dart-define=SUPABASE_ANON_KEY=eyJ...
class AppConfig {
  const AppConfig._();

  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY');

  /// Vero quando le credenziali Supabase non sono state fornite. In questo
  /// caso l'app gira in "modalità demo" senza backend (dati locali in memoria).
  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  /// Endpoint dell'edge function proxy verso Yahoo Finance.
  static String get yahooFunctionUrl => '$supabaseUrl/functions/v1/yahoo';
}
