import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../portfolio/providers/portfolio_providers.dart';
import '../domain/transaction.dart';

/// Registro delle operazioni dell'utente.
final transactionsControllerProvider =
    AsyncNotifierProvider<TransactionsController, List<Transaction>>(
        TransactionsController.new);

class TransactionsController extends AsyncNotifier<List<Transaction>> {
  @override
  Future<List<Transaction>> build() async {
    return ref.watch(portfolioRepositoryProvider).fetchTransactions();
  }

  Future<void> record(Transaction tx) async {
    await ref.read(portfolioRepositoryProvider).recordTransaction(tx);
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
