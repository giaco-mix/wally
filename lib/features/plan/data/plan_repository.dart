import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/investment_plan.dart';

abstract class PlanRepository {
  /// Il piano del portafoglio indicato (o globale se [portfolioId] è null).
  Future<InvestmentPlan?> fetchPlan([String? portfolioId]);

  /// Crea o aggiorna il piano del portafoglio indicato.
  Future<void> savePlan(InvestmentPlan plan, [String? portfolioId]);
}

class SupabasePlanRepository implements PlanRepository {
  SupabasePlanRepository(this._client);
  final SupabaseClient _client;

  String get _uid => _client.auth.currentUser!.id;

  @override
  Future<InvestmentPlan?> fetchPlan([String? portfolioId]) async {
    final base = _client.from('plans').select().eq('user_id', _uid);
    final row = await (portfolioId == null
            ? base.filter('portfolio_id', 'is', null)
            : base.eq('portfolio_id', int.parse(portfolioId)))
        .maybeSingle();
    if (row == null) return null;
    return InvestmentPlan.fromMap(row);
  }

  @override
  Future<void> savePlan(InvestmentPlan plan, [String? portfolioId]) async {
    await _client.from('plans').upsert(
      {
        ...plan.toInsert(_uid),
        'updated_at': DateTime.now().toIso8601String(),
        if (portfolioId != null) 'portfolio_id': int.parse(portfolioId),
      },
      onConflict: 'user_id,portfolio_id',
    );
  }
}

/// Implementazione in-memory per la modalità demo (piano per portafoglio).
class InMemoryPlanRepository implements PlanRepository {
  final Map<String?, InvestmentPlan> _plans = {};

  @override
  Future<InvestmentPlan?> fetchPlan([String? portfolioId]) async =>
      _plans[portfolioId];

  @override
  Future<void> savePlan(InvestmentPlan plan, [String? portfolioId]) async {
    _plans[portfolioId] = plan;
  }
}
