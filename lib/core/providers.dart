import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../features/market/data/market_repository.dart';
import '../features/market/data/mock_market_repository.dart';
import '../features/plan/data/plan_repository.dart';
import '../features/portfolio/data/portfolio_repository.dart';
import 'config/app_config.dart';

/// True quando l'app gira con backend Supabase reale.
final isBackendConfiguredProvider = Provider<bool>((_) => AppConfig.isConfigured);

final supabaseClientProvider = Provider<SupabaseClient>((_) {
  return Supabase.instance.client;
});

final marketRepositoryProvider = Provider<MarketRepository>((ref) {
  return AppConfig.isConfigured
      ? YahooMarketRepository()
      : MockMarketRepository();
});

final portfolioRepositoryProvider = Provider<PortfolioRepository>((ref) {
  if (AppConfig.isConfigured) {
    return SupabasePortfolioRepository(ref.watch(supabaseClientProvider));
  }
  return InMemoryPortfolioRepository();
});

final planRepositoryProvider = Provider<PlanRepository>((ref) {
  if (AppConfig.isConfigured) {
    return SupabasePlanRepository(ref.watch(supabaseClientProvider));
  }
  return InMemoryPlanRepository();
});
