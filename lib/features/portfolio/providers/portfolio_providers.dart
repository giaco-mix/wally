import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../market/domain/quote.dart';
import '../domain/broker.dart';
import '../domain/holding.dart';
import '../domain/portfolio.dart';
import '../domain/portfolio_costs.dart';
import '../domain/portfolio_snapshot.dart';
import '../domain/position.dart';

/// Portafogli dell'utente (multi-portafoglio). Garantisce il "Principale".
final portfoliosControllerProvider =
    AsyncNotifierProvider<PortfoliosController, List<Portfolio>>(
        PortfoliosController.new);

class PortfoliosController extends AsyncNotifier<List<Portfolio>> {
  @override
  Future<List<Portfolio>> build() async {
    final repo = ref.watch(portfolioRepositoryProvider);
    var list = await repo.fetchPortfolios();
    if (list.isEmpty) {
      await repo.ensureDefaultPortfolio();
      list = await repo.fetchPortfolios();
    }
    return list;
  }

  Future<void> create(String name) async {
    await ref.read(portfolioRepositoryProvider).createPortfolio(name);
    ref.invalidateSelf();
    await future;
  }
}

/// Portafoglio selezionato manualmente (null = usa il primo disponibile).
final selectedPortfolioIdProvider =
    NotifierProvider<SelectedPortfolioId, String?>(SelectedPortfolioId.new);

class SelectedPortfolioId extends Notifier<String?> {
  @override
  String? build() => null;
  void select(String? id) => state = id;
}

/// Id del portafoglio attualmente in vista.
final currentPortfolioIdProvider = Provider<String?>((ref) {
  final selected = ref.watch(selectedPortfolioIdProvider);
  final list = ref.watch(portfoliosControllerProvider).asData?.value ?? const [];
  if (selected != null && list.any((p) => p.id == selected)) return selected;
  return list.isEmpty ? null : list.first.id;
});

/// Lista delle posizioni del portafoglio in vista (CRUD).
final holdingsControllerProvider =
    AsyncNotifierProvider<HoldingsController, List<Holding>>(
        HoldingsController.new);

class HoldingsController extends AsyncNotifier<List<Holding>> {
  @override
  Future<List<Holding>> build() async {
    final pid = ref.watch(currentPortfolioIdProvider);
    return ref.watch(portfolioRepositoryProvider).fetchHoldings(pid);
  }

  Future<void> save(Holding holding) async {
    final repo = ref.read(portfolioRepositoryProvider);
    final pid = ref.read(currentPortfolioIdProvider);
    await repo.upsertHolding(
        pid == null ? holding : holding.copyWith(portfolioId: pid));
    ref.invalidateSelf();
    await future;
  }

  Future<void> delete(String id) async {
    final repo = ref.read(portfolioRepositoryProvider);
    await repo.deleteHolding(id);
    ref.invalidateSelf();
    await future;
  }

  /// Import in blocco (CSV broker).
  Future<void> importHoldings(List<Holding> holdings) async {
    final repo = ref.read(portfolioRepositoryProvider);
    final pid = ref.read(currentPortfolioIdProvider);
    final stamped = pid == null
        ? holdings
        : holdings.map((h) => h.copyWith(portfolioId: pid)).toList();
    await repo.importHoldings(stamped);
    ref.invalidateSelf();
    await future;
  }
}

/// Momento dell'ultimo aggiornamento riuscito delle quotazioni (per la UI).
final lastQuotesRefreshProvider =
    NotifierProvider<LastQuotesRefresh, DateTime?>(LastQuotesRefresh.new);

class LastQuotesRefresh extends Notifier<DateTime?> {
  @override
  DateTime? build() => null;

  void stampNow() => state = DateTime.now();
}

/// Quotazioni correnti per i simboli presenti in portafoglio.
final quotesProvider = FutureProvider<Map<String, Quote>>((ref) async {
  final holdings = await ref.watch(holdingsControllerProvider.future);
  final symbols = holdings.map((h) => h.symbol).toSet().toList();
  if (symbols.isEmpty) return {};
  return ref.watch(marketRepositoryProvider).quotes(symbols);
});

/// Posizioni arricchite con la quotazione (per dashboard e liste).
final positionsProvider = Provider<AsyncValue<List<Position>>>((ref) {
  final holdings = ref.watch(holdingsControllerProvider);
  final quotes = ref.watch(quotesProvider);
  return holdings.whenData((list) {
    final q = quotes.asData?.value ?? const {};
    return list
        .map((h) => Position(holding: h, quote: q[h.symbol.toUpperCase()]))
        .toList();
  });
});

/// Broker/piattaforme dell'utente (CRUD).
final brokersControllerProvider =
    AsyncNotifierProvider<BrokersController, List<Broker>>(
        BrokersController.new);

class BrokersController extends AsyncNotifier<List<Broker>> {
  @override
  Future<List<Broker>> build() async {
    return ref.watch(portfolioRepositoryProvider).fetchBrokers();
  }

  Future<void> save(Broker broker) async {
    await ref.read(portfolioRepositoryProvider).upsertBroker(broker);
    ref.invalidateSelf();
    await future;
  }

  Future<void> delete(String id) async {
    await ref.read(portfolioRepositoryProvider).deleteBroker(id);
    ref.invalidateSelf();
    await future;
  }
}

/// Stima dei costi annui del portafoglio (TER + canoni broker) e netto.
final portfolioCostsProvider = Provider<AsyncValue<PortfolioCosts>>((ref) {
  final positions = ref.watch(positionsProvider);
  final brokers = ref.watch(brokersControllerProvider);
  if (brokers.isLoading) return const AsyncValue.loading();
  return positions.whenData((list) {
    return PortfolioCosts.compute(
      positions: list,
      brokers: brokers.asData?.value ?? const [],
    );
  });
});

/// Allocazioni target per asset class (name -> percentuale 0..100).
final targetsControllerProvider =
    AsyncNotifierProvider<TargetsController, Map<String, double>>(
        TargetsController.new);

class TargetsController extends AsyncNotifier<Map<String, double>> {
  @override
  Future<Map<String, double>> build() async {
    return ref.watch(portfolioRepositoryProvider).fetchTargets();
  }

  Future<void> save(Map<String, double> targets) async {
    await ref.read(portfolioRepositoryProvider).saveTargets(targets);
    ref.invalidateSelf();
    await future;
  }
}

/// Storico del valore del portafoglio per la curva di performance.
final performanceControllerProvider =
    AsyncNotifierProvider<PerformanceController, List<PortfolioSnapshot>>(
        PerformanceController.new);

class PerformanceController extends AsyncNotifier<List<PortfolioSnapshot>> {
  double? _lastRecorded;

  @override
  Future<List<PortfolioSnapshot>> build() async {
    return ref.watch(portfolioRepositoryProvider).fetchSnapshots();
  }

  /// Registra lo snapshot di oggi se il valore è cambiato in modo
  /// significativo rispetto all'ultimo registrato in questa sessione.
  Future<void> recordToday(double totalValue) async {
    if (totalValue <= 0) return;
    if (_lastRecorded != null && (_lastRecorded! - totalValue).abs() < 0.01) {
      return;
    }
    _lastRecorded = totalValue;
    await ref
        .read(portfolioRepositoryProvider)
        .recordSnapshot(DateTime.now(), totalValue);
    ref.invalidateSelf();
  }
}
