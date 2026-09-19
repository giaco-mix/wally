import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../admin/providers/admin_providers.dart';
import '../../advisor/providers/advisor_providers.dart';
import '../providers/auth_providers.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final email = session?.user.email;
    final inviteCount =
        ref.watch(pendingInvitesProvider).asData?.value.length ?? 0;
    final isAdmin = ref.watch(isAdminProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(
                email == null || email.isEmpty ? 'Utente' : email,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                AppConfig.isConfigured ? 'Connesso' : 'Modalità demo',
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.self_improvement),
                  title: const Text('Wally Coach'),
                  subtitle: const Text('Check-in e supporto comportamentale'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/coach'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.school_outlined),
                  title: const Text('Strategie'),
                  subtitle: const Text('Come strutturare un piano + modelli'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/strategie'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.receipt_long_outlined),
                  title: const Text('Movimenti'),
                  subtitle: const Text('Registro operazioni (PAC, extra, vendite)'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/transactions'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.article_outlined),
                  title: const Text('Novità sul portafoglio'),
                  subtitle: const Text('Notizie sui tuoi titoli'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/news'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.account_balance_outlined),
                  title: const Text('Piattaforme e commissioni'),
                  subtitle: const Text('Gestisci broker e costi'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/brokers'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.flag_outlined),
                  title: const Text('Il tuo piano'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/plan'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.groups_outlined),
                  title: const Text('Modalità consulente'),
                  subtitle:
                      const Text('Segui i portafogli dei tuoi clienti'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/consulente'),
                ),
                if (inviteCount > 0) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.handshake_outlined),
                    title: const Text('Inviti da consulente'),
                    subtitle: Text('$inviteCount in attesa'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.go('/inviti'),
                  ),
                ],
                if (isAdmin) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.admin_panel_settings_outlined),
                    title: const Text('Amministrazione'),
                    subtitle: const Text('Utenti e ruoli'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.go('/admin'),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (AppConfig.isConfigured)
            FilledButton.tonalIcon(
              onPressed: () => _confirmLogout(context, ref),
              icon: const Icon(Icons.logout),
              label: const Text('Esci'),
            )
          else
            Card(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Sei in modalità demo: non è richiesto alcun login, quindi '
                  'non c\'è logout. Configura Supabase per usare un account reale.',
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Esci da Wally?'),
        content: const Text('Dovrai accedere di nuovo per rientrare.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Esci'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(authControllerProvider.notifier).signOut();
    }
  }
}
