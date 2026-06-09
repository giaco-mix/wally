import 'push_client.dart';

/// Implementazione no-op per piattaforme senza Web Push (VM/test, mobile).
PushClient createPushClient() => _StubPushClient();

class _StubPushClient implements PushClient {
  @override
  bool get isSupported => false;

  @override
  Future<PushSubscriptionData> enable(String vapidPublicKey) async =>
      throw PushException('unsupported');

  @override
  Future<String?> disable() async => null;
}
