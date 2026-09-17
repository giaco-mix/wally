import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../portfolio/providers/portfolio_providers.dart';
import '../domain/lot_performance.dart';
import '../domain/transaction.dart';

/// Registro delle operazioni dell'utente.
final transactionsControllerProvider =
    AsyncNotifierProvider<TransactionsController, List<Transaction>>(
        TransactionsController.new);

class TransactionsController extends AsyncNotifier<List<Transaction>> {
  @override
  Future<List<Transaction>> build() async {
    final pid = ref.watch(currentPortfolioIdProvider);
    return ref.watch(portfolioRepositoryProvider).fetchTransactions(pid);
  }

  Future<void> record(Transaction tx) async {
    final pid = ref.read(currentPortfolioIdProvider);
    final stamped = pid == null ? tx : tx.copyWith(portfolioId: pid);
    await ref.read(portfolioRepositoryProvider).recordTransaction(stamped);
    ref.invalidateSelf();
    // Le posizioni aggregate sono cambiate: rinfresca portafoglio e quotazioni.
    ref.invalidate(holdingsControllerProvider);
    await future;
  }

  Future<void> delete(String id) async {
    await ref.read(portfolioRepositoryProvider).deleteTransaction(id);
    ref.invalidateSelf();
    await future;
  }
}

/// Rendimento per singolo accumulo (per simbolo), calcolato dal ledger e dai
/// prezzi correnti. Base per la vista "Rendimento accumuli".
final lotPerformanceProvider =
    Provider<AsyncValue<List<SymbolPerformance>>>((ref) {
  final txs = ref.watch(transactionsControllerProvider);
  final quotes = ref.watch(quotesProvider);
  return txs.whenData((list) {
    final prices = <String, double>{
      for (final e in (quotes.asData?.value ?? const {}).entries)
        e.key.toUpperCase(): e.value.price,
    };
    return LotEngine.forPortfolio(list, prices);
  });
});
