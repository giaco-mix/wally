import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/academy/presentation/academy_screen.dart';
import '../../features/academy/presentation/glossary_screen.dart';
import '../../features/academy/presentation/tutor_screen.dart';
import '../../features/admin/presentation/admin_screen.dart';
import '../../features/advisor/presentation/advisor_home_screen.dart';
import '../../features/advisor/presentation/advisor_invites_screen.dart';
import '../../features/analysis/presentation/analysis_screen.dart';
import '../../features/instruments/presentation/instrument_finder_screen.dart';
import '../../features/lab/presentation/lab_screen.dart';
import '../../features/analysis/presentation/compare_screen.dart';
import '../../features/analysis/presentation/income_screen.dart';
import '../../features/analysis/presentation/stock_detail_screen.dart';
import '../../features/auth/presentation/account_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../../features/coach/presentation/achievements_screen.dart';
import '../../features/coach/presentation/coach_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/news/presentation/news_screen.dart';
import '../../features/plan/presentation/onboarding_screen.dart';
import '../../features/plan/presentation/plan_screen.dart';
import '../../features/portfolio/presentation/brokers_screen.dart';
import '../../features/portfolio/presentation/portfolio_screen.dart';
import '../../features/transactions/presentation/lot_performance_screen.dart';
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
      // Compatibilità: i vecchi path EN reindirizzano ai nuovi path IT, così
      // link/preferiti pre-rinomina continuano a funzionare.
      return _legacyRedirect(state.matchedLocation);
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
            path: '/portafoglio',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: PortfolioScreen()),
          ),
          GoRoute(
            path: '/ribilancia',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: RebalanceScreen()),
          ),
          GoRoute(
            path: '/analisi',
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
            path: '/piano',
            pageBuilder: (_, _) => const NoTransitionPage(child: PlanScreen()),
          ),
          GoRoute(
            path: '/piattaforme',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: BrokersScreen()),
          ),
          GoRoute(
            path: '/avvisi',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: NotificationsScreen()),
          ),
          GoRoute(
            path: '/coach',
            pageBuilder: (_, _) => const NoTransitionPage(child: CoachScreen()),
          ),
          GoRoute(
            path: '/traguardi',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: AchievementsScreen()),
          ),
          GoRoute(
            path: '/movimenti',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: TransactionsScreen()),
          ),
          GoRoute(
            path: '/rendimento',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: LotPerformanceScreen()),
          ),
          GoRoute(
            path: '/consulente',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: AdvisorHomeScreen()),
          ),
          GoRoute(
            path: '/inviti',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: AdvisorInvitesScreen()),
          ),
          GoRoute(
            path: '/admin',
            pageBuilder: (_, _) => const NoTransitionPage(child: AdminScreen()),
          ),
          GoRoute(
            path: '/confronta',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: CompareScreen()),
          ),
          GoRoute(
            path: '/rendite',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: IncomeScreen()),
          ),
          GoRoute(
            path: '/novita',
            pageBuilder: (_, _) => const NoTransitionPage(child: NewsScreen()),
          ),
          GoRoute(
            path: '/strategie',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: StrategiesScreen()),
          ),
          GoRoute(
            path: '/impara',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: AcademyScreen()),
          ),
          GoRoute(
            path: '/strumenti',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: InstrumentFinderScreen()),
          ),
          GoRoute(
            path: '/laboratorio',
            pageBuilder: (_, _) => const NoTransitionPage(child: LabScreen()),
          ),
          GoRoute(
            path: '/glossario',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: GlossaryScreen()),
          ),
          GoRoute(
            path: '/tutor',
            pageBuilder: (_, _) => const NoTransitionPage(child: TutorScreen()),
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

/// Mappa i vecchi path (prima della rinomina in italiano) sui nuovi, incluse
/// le sotto-rotte (es. /analysis/AAPL → /analisi/AAPL). Restituisce null se il
/// path è già valido.
const _legacyPaths = {
  '/portfolio': '/portafoglio',
  '/rebalance': '/ribilancia',
  '/analysis': '/analisi',
  '/plan': '/piano',
  '/brokers': '/piattaforme',
  '/notifications': '/avvisi',
  '/transactions': '/movimenti',
  '/compare': '/confronta',
  '/income': '/rendite',
  '/news': '/novita',
  '/academy': '/impara',
};

String? _legacyRedirect(String location) {
  final exact = _legacyPaths[location];
  if (exact != null) return exact;
  for (final e in _legacyPaths.entries) {
    if (location.startsWith('${e.key}/')) {
      return '${e.value}${location.substring(e.key.length)}';
    }
  }
  return null;
}
