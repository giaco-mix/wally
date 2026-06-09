// Interfaccia portabile del client Web Push. L'implementazione reale (js_interop)
// è in push_client_web.dart e viene selezionata solo su web tramite import
// condizionale; su VM/test si usa lo stub (no-op), così il codice compila ovunque.
import 'push_client_stub.dart'
    if (dart.library.js_interop) 'push_client_web.dart';

/// Dati di una sottoscrizione push, pronti per essere salvati su Supabase.
class PushSubscriptionData {
  const PushSubscriptionData({
    required this.endpoint,
    required this.p256dh,
    required this.auth,
  });

  final String endpoint;
  final String p256dh;
  final String auth;
}

/// Errore "amichevole" durante l'attivazione/disattivazione del push.
class PushException implements Exception {
  PushException(this.code);
  final String code;

  /// Messaggio in italiano per la UI.
  String get message => switch (code) {
        'unsupported' => 'Il tuo browser non supporta le notifiche push.',
        'missing-vapid-key' =>
          'Le notifiche push non sono ancora configurate sul server.',
        'permission-denied' =>
          'Hai bloccato le notifiche. Riattivale dalle impostazioni del browser.',
        'permission-default' => 'Permesso non concesso. Riprova quando vuoi.',
        // Per gli errori non mappati mostriamo il dettaglio reale (utile a
        // capire cosa è andato storto: DOMException da register/subscribe, ecc.).
        _ => 'Notifiche non attivate: $code',
      };

  @override
  String toString() => 'PushException($code)';
}

/// Client Web Push. Usa [PushClient.new] (delega all'implementazione di
/// piattaforma): web reale via js_interop, stub no-op altrove.
abstract class PushClient {
  factory PushClient() => createPushClient();

  /// Vero se il browser corrente supporta service worker + Push API.
  bool get isSupported;

  /// Chiede il permesso, registra il service worker e sottoscrive il push.
  Future<PushSubscriptionData> enable(String vapidPublicKey);

  /// Annulla la sottoscrizione locale. Ritorna l'endpoint rimosso (se c'era).
  Future<String?> disable();
}
