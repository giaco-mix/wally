import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/app_config.dart';
import '../../features/admin/providers/admin_providers.dart';

class _Destination {
  const _Destination(
    this.label,
    this.icon,
    this.selectedIcon,
    this.path,
    this.tooltip,
  );
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String path;
  final String tooltip;
}

/// Destinazioni di primo livello, in funzione del ruolo. Una sola lista per
/// mobile (NavigationBar) e wide (NavigationRail) per evitare incoerenze.
///
/// - retail / client / admin: Dashboard · Portafoglio · Ribilancia · Impara · Account
/// - advisor: in più "Clienti" (il suo book a un tap), subito dopo Dashboard.
///
/// Analisi, Movimenti, Rendimento, Novità e Piattaforme vivono dentro l'hub
/// Portafoglio; Strategie/Strumenti/Laboratorio/Glossario/Tutor dentro Impara.
List<_Destination> _destinationsFor(String role) {
  return [
    const _Destination('Dashboard', Icons.dashboard_outlined, Icons.dashboard,
        '/', 'Colpo d\'occhio sul tuo patrimonio'),
    if (role == 'advisor')
      const _Destination('Clienti', Icons.groups_outlined, Icons.groups,
          '/consulente', 'I portafogli dei tuoi clienti (sola lettura)'),
    const _Destination(
        'Portafoglio',
        Icons.account_balance_wallet_outlined,
        Icons.account_balance_wallet,
        '/portafoglio',
        'Cosa possiedi: posizioni, movimenti, analisi'),
    const _Destination('Ribilancia', Icons.balance_outlined, Icons.balance,
        '/ribilancia', 'Cosa aggiustare per restare in rotta'),
    const _Destination('Impara', Icons.school_outlined, Icons.school,
        '/impara', 'Lezioni, strumenti e laboratorio'),
    const _Destination('Account', Icons.person_outline, Icons.person,
        '/account', 'Profilo, piano e impostazioni'),
  ];
}

/// Mappa una qualsiasi rotta sulla destinazione di primo livello che la
/// "possiede", così la voce giusta resta evidenziata anche nelle sotto-pagine.
String _sectionPath(String location, bool advisor) {
  if (location == '/') return '/';
  bool match(String p) => location == p || location.startsWith('$p/');

  if (match('/consulente') || match('/inviti')) {
    return advisor ? '/consulente' : '/account';
  }
  if (match('/portafoglio') ||
      match('/movimenti') ||
      match('/rendimento') ||
      match('/analisi') ||
      match('/confronta') ||
      match('/rendite') ||
      match('/novita') ||
      match('/piattaforme')) {
    return '/portafoglio';
  }
  if (match('/ribilancia') || match('/avvisi')) return '/ribilancia';
  if (match('/impara') ||
      match('/strategie') ||
      match('/strumenti') ||
      match('/laboratorio') ||
      match('/glossario') ||
      match('/tutor')) {
    return '/impara';
  }
  // Account e ciò che ci sta sotto (Coach, Traguardi, Piano, Admin).
  return '/account';
}

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child});
  final Widget child;

  int _indexFor(List<_Destination> dests, String location, bool advisor) {
    final path = _sectionPath(location, advisor);
    final i = dests.indexWhere((d) => d.path == path);
    return i < 0 ? 0 : i;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(currentUserRoleProvider).asData?.value ?? 'retail';
    final destinations = _destinationsFor(role);
    final location = GoRouterState.of(context).uri.path;
    final index = _indexFor(destinations, location, role == 'advisor');
    final isWide = MediaQuery.sizeOf(context).width >= 760;

    void go(int i) => context.go(destinations[i].path);

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: index,
              onDestinationSelected: go,
              labelType: NavigationRailLabelType.all,
              leading: const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Icon(Icons.savings, size: 32),
              ),
              destinations: [
                for (final d in destinations)
                  NavigationRailDestination(
                    icon: Tooltip(message: d.tooltip, child: Icon(d.icon)),
                    selectedIcon:
                        Tooltip(message: d.tooltip, child: Icon(d.selectedIcon)),
                    label: Text(d.label),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: _Body(child: child)),
          ],
        ),
      );
    }

    return Scaffold(
      body: _Body(child: child),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: go,
        destinations: [
          for (final d in destinations)
            NavigationDestination(
              icon: Icon(d.icon),
              selectedIcon: Icon(d.selectedIcon),
              label: d.label,
              tooltip: d.tooltip,
            ),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!AppConfig.isConfigured) const _DemoBanner(),
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}

class _DemoBanner extends StatelessWidget {
  const _DemoBanner();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(Icons.science_outlined,
                size: 18, color: scheme.onTertiaryContainer),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Modalità demo: dati locali sintetici. Configura Supabase '
                '(--dart-define) per dati reali e salvataggio.',
                style: TextStyle(color: scheme.onTertiaryContainer, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
