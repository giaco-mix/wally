import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../providers/auth_providers.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final email = session?.user.email;

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
