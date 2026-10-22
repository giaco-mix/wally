import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../shared/widgets/hub.dart';
import '../../admin/providers/admin_providers.dart';
import '../../advisor/providers/advisor_providers.dart';
import '../providers/auth_providers.dart';

/// Hub "Account": profilo + impostazioni personali, organizzato in sezioni.
/// Le funzioni operative (movimenti, novità, broker, strategie…) vivono nei
/// rispettivi hub (Portafoglio, Impara): qui restano profilo, crescita,
/// consulenza (adattata al ruolo) e sistema.
class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final email = session?.user.email;
    final inviteCount =
        ref.watch(pendingInvitesProvider).asData?.value.length ?? 0;
    final role = ref.watch(currentUserRoleProvider).asData?.value ?? 'retail';
    final isAdmin = role == 'admin';

    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Profilo ────────────────────────────────────────────────────
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

          // ── Cresci con Wally ───────────────────────────────────────────
          const SectionHeader('Cresci con Wally',
              blurb: 'Abitudini, obiettivi e disciplina.'),
          HubNavCard(
            icon: Icons.self_improvement,
            title: 'Wally Coach',
            subtitle: 'Check-in e supporto comportamentale',
            onTap: () => context.go('/coach'),
          ),
          HubNavCard(
            icon: Icons.flag_outlined,
            title: 'Il tuo piano',
            subtitle: 'Obiettivo, rischio e PAC',
            onTap: () => context.go('/piano'),
          ),

          // ── Consulenza (adattata al ruolo) ─────────────────────────────
          const SectionHeader('Consulenza'),
          ..._consulenza(context, role, inviteCount),

          // ── Sistema (solo admin) ───────────────────────────────────────
          if (isAdmin) ...[
            const SectionHeader('Sistema'),
            HubNavCard(
              icon: Icons.admin_panel_settings_outlined,
              title: 'Amministrazione',
              subtitle: 'Utenti e ruoli',
              onTap: () => context.go('/admin'),
            ),
          ],

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

  /// Voci della sezione Consulenza in base al ruolo dell'utente.
  List<Widget> _consulenza(BuildContext context, String role, int inviteCount) {
    switch (role) {
      case 'advisor':
        return [
          HubNavCard(
            icon: Icons.groups_outlined,
            title: 'I tuoi clienti',
            subtitle: 'Libro clienti e portafogli in sola lettura',
            onTap: () => context.go('/consulente'),
          ),
        ];
      case 'client':
        return [
          HubNavCard(
            icon: Icons.handshake_outlined,
            title: 'Il mio consulente',
            subtitle: inviteCount > 0
                ? '$inviteCount invito/i in attesa · accesso in sola lettura'
                : 'Inviti e accesso in sola lettura',
            onTap: () => context.go('/inviti'),
          ),
        ];
      default: // retail, admin
        return [
          HubNavCard(
            icon: Icons.groups_outlined,
            title: 'Diventa consulente',
            subtitle: 'Segui i portafogli dei tuoi clienti in sola lettura. '
                'Invitando il primo cliente diventerai consulente.',
            onTap: () => context.go('/consulente'),
          ),
          if (inviteCount > 0)
            HubNavCard(
              icon: Icons.handshake_outlined,
              title: 'Inviti da consulente',
              subtitle: '$inviteCount in attesa',
              onTap: () => context.go('/inviti'),
            ),
        ];
    }
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
