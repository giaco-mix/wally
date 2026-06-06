import 'dart:convert';
import 'dart:js_interop';

import 'package:flutter/foundation.dart' show kIsWeb;

// Binding alle funzioni esposte da web/push/wally_push.js.
@JS('wallyPushSupported')
external JSBoolean _wallyPushSupported();

@JS('wallyEnablePush')
external JSPromise<JSString> _wallyEnablePush(JSString vapidKey);

@JS('wallyDisablePush')
external JSPromise<JSString> _wallyDisablePush();

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
        _ => 'Non è stato possibile attivare le notifiche push.',
      };

  @override
  String toString() => 'PushException($code)';
}

/// Wrapper Dart sopra le API browser di Web Push (delegate a JS).
class PushClient {
  const PushClient();

  /// Vero se il browser corrente supporta service worker + Push API.
  bool get isSupported {
    if (!kIsWeb) return false;
    try {
      return _wallyPushSupported().toDart;
    } catch (_) {
      return false;
    }
  }

  /// Chiede il permesso, registra il service worker e sottoscrive il push.
  Future<PushSubscriptionData> enable(String vapidPublicKey) async {
    final result = await _wallyEnablePush(vapidPublicKey.toJS).toDart;
    final map = jsonDecode(result.toDart) as Map<String, dynamic>;
    if (map['ok'] != true) {
      throw PushException(map['error']?.toString() ?? 'unknown');
    }
    return PushSubscriptionData(
      endpoint: map['endpoint'] as String,
      p256dh: map['p256dh'] as String,
      auth: map['auth'] as String,
    );
  }

  /// Annulla la sottoscrizione locale. Ritorna l'endpoint rimosso (se c'era).
  Future<String?> disable() async {
    final result = await _wallyDisablePush().toDart;
    final map = jsonDecode(result.toDart) as Map<String, dynamic>;
    if (map['ok'] != true) {
      throw PushException(map['error']?.toString() ?? 'unknown');
    }
    return map['endpoint'] as String?;
  }
}
