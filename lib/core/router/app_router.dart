import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/analysis/presentation/analysis_screen.dart';
import '../../features/analysis/presentation/stock_detail_screen.dart';
import '../../features/auth/presentation/account_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../../features/coach/presentation/coach_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/plan/presentation/onboarding_screen.dart';
import '../../features/plan/presentation/plan_screen.dart';
import '../../features/portfolio/presentation/brokers_screen.dart';
import '../../features/portfolio/presentation/portfolio_screen.dart';
import '../../features/transactions/presentation/transactions_screen.dart';
import '../../features/rebalance/presentation/notifications_screen.dart';
import '../../features/rebalance/presentation/rebalance_screen.dart';
import '../../features/strategies/presentation/strategies_screen.dart';
import '../../shared/widgets/app_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final rootKey = GlobalKey<NavigatorState>();
  final shellKey = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootKey,
    initialLocation: '/',
    refreshListenable: _AuthListenable(ref),
    redirect: (context, state) {
      final loggedIn = ref.read(isLoggedInProvider);
      final loggingIn =
          state.matchedLocation == '/login' || state.matchedLocation == '/signup';
      if (!loggedIn) return loggingIn ? null : '/login';
      if (loggingIn) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (_, _) => const SignupScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (_, _) => const OnboardingScreen(),
      ),
      ShellRoute(
        navigatorKey: shellKey,
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (_, _) => const NoTransitionPage(child: DashboardScreen()),
          ),
          GoRoute(
            path: '/portfolio',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: PortfolioScreen()),
          ),
          GoRoute(
            path: '/rebalance',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: RebalanceScreen()),
          ),
          GoRoute(
            path: '/analysis',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: AnalysisScreen()),
            routes: [
              GoRoute(
                path: ':symbol',
                parentNavigatorKey: rootKey,
                builder: (_, state) =>
                    StockDetailScreen(symbol: state.pathParameters['symbol']!),
              ),
            ],
          ),
          GoRoute(
            path: '/plan',
            pageBuilder: (_, _) => const NoTransitionPage(child: PlanScreen()),
          ),
          GoRoute(
            path: '/brokers',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: BrokersScreen()),
          ),
          GoRoute(
            path: '/notifications',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: NotificationsScreen()),
          ),
          GoRoute(
            path: '/coach',
            pageBuilder: (_, _) => const NoTransitionPage(child: CoachScreen()),
          ),
          GoRoute(
            path: '/transactions',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: TransactionsScreen()),
          ),
          GoRoute(
            path: '/strategie',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: StrategiesScreen()),
          ),
          GoRoute(
            path: '/account',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: AccountScreen()),
          ),
        ],
      ),
    ],
  );
});

class _AuthListenable extends ChangeNotifier {
  _AuthListenable(Ref ref) {
    ref.listen(isLoggedInProvider, (_, _) => notifyListeners());
  }
}
