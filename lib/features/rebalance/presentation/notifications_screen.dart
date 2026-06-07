import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../notifications/data/push_client.dart';
import '../../notifications/providers/push_providers.dart';
import '../domain/wally_notification.dart';
import '../providers/rebalance_providers.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);
    final scheme = Theme.of(context).colorScheme;
    final pushAvailable = ref.watch(pushAvailableProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Avvisi')),
      body: notifications.isEmpty && !pushAvailable
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_outline,
                        size: 56, color: scheme.primary),
                    const SizedBox(height: 16),
                    Text('Tutto tranquillo 👌',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    const Text(
                      'Nessun avviso al momento. Continua così: il bello '
                      'dell\'investire è anche non dover fare nulla.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(12),
              children: [
                if (pushAvailable) const _PushToggleCard(),
                if (notifications.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Nessun avviso al momento 👌 Continua così.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                for (final n in notifications) _NotificationCard(notification: n),
              ],
            ),
    );
  }
}

/// Card per attivare/disattivare le notifiche push del browser.
class _PushToggleCard extends ConsumerWidget {
  const _PushToggleCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(pushEnabledProvider);

    Future<void> toggle(bool value) async {
      // Catturiamo il messenger prima degli await: niente BuildContext oltre
      // i confini async.
      final messenger = ScaffoldMessenger.of(context);
      final controller = ref.read(pushEnabledProvider.notifier);
      try {
        if (value) {
          await controller.enable();
          _snack(messenger, 'Notifiche push attivate 🔔');
        } else {
          await controller.disable();
          _snack(messenger, 'Notifiche push disattivate.');
        }
      } on PushException catch (e) {
        _snack(messenger, e.message);
      } catch (e) {
        _snack(messenger, 'Errore: $e');
      }
    }

    return Card(
      child: SwitchListTile(
        secondary: const Icon(Icons.notifications_active_outlined),
        title: const Text('Notifiche push'),
        subtitle: const Text(
          'Ricevi un promemoria anche quando Wally è chiuso: ribilanciamento '
          'in scadenza e check-in periodici.',
        ),
        value: enabled.asData?.value ?? false,
        onChanged: enabled.isLoading ? null : toggle,
      ),
    );
  }

  static void _snack(ScaffoldMessengerState messenger, String msg) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.notification});
  final WallyNotification notification;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final warning = notification.severity == NotificationSeverity.warning;
    final color = warning ? scheme.error : scheme.primary;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  warning
                      ? Icons.warning_amber_rounded
                      : Icons.info_outline,
                  color: color,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(notification.title,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(notification.body),
            if (notification.route != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.tonal(
                  onPressed: () => context.go(notification.route!),
                  child: Text(notification.actionLabel ?? 'Apri'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
