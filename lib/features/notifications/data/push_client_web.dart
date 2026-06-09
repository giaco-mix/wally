import 'dart:convert';
import 'dart:js_interop';

import 'push_client.dart';

// Binding alle funzioni esposte da web/push/wally_push.js.
@JS('wallyPushSupported')
external JSBoolean _wallyPushSupported();

@JS('wallyEnablePush')
external JSPromise<JSString> _wallyEnablePush(JSString vapidKey);

@JS('wallyDisablePush')
external JSPromise<JSString> _wallyDisablePush();

PushClient createPushClient() => _WebPushClient();

/// Implementazione web reale: delega alle funzioni JS (service worker + Push API).
class _WebPushClient implements PushClient {
  @override
  bool get isSupported {
    try {
      return _wallyPushSupported().toDart;
    } catch (_) {
      return false;
    }
  }

  @override
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

  @override
  Future<String?> disable() async {
    final result = await _wallyDisablePush().toDart;
    final map = jsonDecode(result.toDart) as Map<String, dynamic>;
    if (map['ok'] != true) {
      throw PushException(map['error']?.toString() ?? 'unknown');
    }
    return map['endpoint'] as String?;
  }
}
