import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/investment_plan.dart';

abstract class PlanRepository {
  /// Il piano attivo dell'utente, o null se non ancora creato.
  Future<InvestmentPlan?> fetchPlan();

  /// Crea o aggiorna il piano (uno per utente).
  Future<void> savePlan(InvestmentPlan plan);
}

class SupabasePlanRepository implements PlanRepository {
  SupabasePlanRepository(this._client);
  final SupabaseClient _client;

  String get _uid => _client.auth.currentUser!.id;

  @override
  Future<InvestmentPlan?> fetchPlan() async {
    final row = await _client
        .from('plans')
        .select()
        .eq('user_id', _uid)
        .maybeSingle();
    if (row == null) return null;
    return InvestmentPlan.fromMap(row);
  }

  @override
  Future<void> savePlan(InvestmentPlan plan) async {
    await _client.from('plans').upsert(
      {
        ...plan.toInsert(_uid),
        'updated_at': DateTime.now().toIso8601String(),
      },
      onConflict: 'user_id',
    );
  }
}

/// Implementazione in-memory per la modalità demo.
class InMemoryPlanRepository implements PlanRepository {
  InvestmentPlan? _plan;

  @override
  Future<InvestmentPlan?> fetchPlan() async => _plan;

  @override
  Future<void> savePlan(InvestmentPlan plan) async {
    _plan = plan;
  }
}
