import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/app_config.dart';
import '../../features/auth/providers/auth_providers.dart';

class _Destination {
  const _Destination(this.label, this.icon, this.selectedIcon, this.path);
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String path;
}

const _destinations = [
  _Destination('Dashboard', Icons.dashboard_outlined, Icons.dashboard, '/'),
  _Destination('Portafoglio', Icons.account_balance_wallet_outlined,
      Icons.account_balance_wallet, '/portfolio'),
  _Destination('Ribilancia', Icons.balance_outlined, Icons.balance, '/rebalance'),
  _Destination('Analisi', Icons.insights_outlined, Icons.insights, '/analysis'),
];

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child});
  final Widget child;

  int _indexFor(String location) {
    final i = _destinations.lastIndexWhere(
      (d) => d.path == '/' ? location == '/' : location.startsWith(d.path),
    );
    return i < 0 ? 0 : i;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.path;
    final index = _indexFor(location);
    final isWide = MediaQuery.sizeOf(context).width >= 760;

    void go(int i) => context.go(_destinations[i].path);

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
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _LogoutButton(),
                  ),
                ),
              ),
              destinations: [
                for (final d in _destinations)
                  NavigationRailDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon),
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
          for (final d in _destinations)
            NavigationDestination(
              icon: Icon(d.icon),
              selectedIcon: Icon(d.selectedIcon),
              label: d.label,
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

class _LogoutButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!AppConfig.isConfigured) return const SizedBox.shrink();
    return IconButton(
      tooltip: 'Esci',
      icon: const Icon(Icons.logout),
      onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
    );
  }
}
