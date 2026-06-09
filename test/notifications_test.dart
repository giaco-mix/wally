import 'package:finance_companion/core/providers.dart';
import 'package:finance_companion/features/notifications/providers/push_providers.dart';
import 'package:finance_companion/features/portfolio/data/portfolio_repository.dart';
import 'package:finance_companion/features/rebalance/domain/rebalance_settings.dart';
import 'package:finance_companion/features/rebalance/domain/wally_notification.dart';
import 'package:finance_companion/features/rebalance/presentation/notifications_screen.dart';
import 'package:finance_companion/features/rebalance/providers/rebalance_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('un ribilanciamento scaduto genera una notifica in-app', () async {
    // Repo con cadenza mensile e ultimo ribilanciamento 60 giorni fa -> scaduto.
    final repo = InMemoryPortfolioRepository();
    await repo.saveRebalanceSettings(
      RebalanceSettings(
        frequency: RebalanceFrequency.monthly,
        lastRebalancedAt: DateTime.now().subtract(const Duration(days: 60)),
      ),
    );

    final container = ProviderContainer(
      overrides: [portfolioRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);

    await container.read(rebalanceSettingsControllerProvider.future);
    final notifs = container.read(notificationsProvider);

    expect(notifs.any((n) => n.id == 'schedule'), isTrue,
        reason: 'Atteso un promemoria di ribilanciamento');
  });

  testWidgets('la pagina Avvisi mostra le notifiche presenti', (tester) async {
    const sample = WallyNotification(
      id: 'schedule',
      title: 'È ora di ribilanciare',
      body: 'Dai un\'occhiata al piano.',
      severity: NotificationSeverity.warning,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationsProvider.overrideWithValue(const [sample]),
          pushAvailableProvider.overrideWithValue(false),
        ],
        child: const MaterialApp(home: NotificationsScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('È ora di ribilanciare'), findsOneWidget);
    expect(find.text('Dai un\'occhiata al piano.'), findsOneWidget);
  });

  testWidgets('senza notifiche mostra lo stato "tutto tranquillo"', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationsProvider.overrideWithValue(const []),
          pushAvailableProvider.overrideWithValue(false),
        ],
        child: const MaterialApp(home: NotificationsScreen()),
      ),
    );
    await tester.pump();

    expect(find.textContaining('Tutto tranquillo'), findsOneWidget);
  });
}
