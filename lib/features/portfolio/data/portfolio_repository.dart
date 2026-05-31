import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/holding.dart';

abstract class PortfolioRepository {
  Future<List<Holding>> fetchHoldings();
  Future<Holding> upsertHolding(Holding holding);
  Future<void> deleteHolding(String id);

  /// Allocazioni target: mappa assetClass.name -> percentuale (0..100).
  Future<Map<String, double>> fetchTargets();
  Future<void> saveTargets(Map<String, double> targets);
}

class SupabasePortfolioRepository implements PortfolioRepository {
  SupabasePortfolioRepository(this._client);
  final SupabaseClient _client;

  String get _uid {
    final id = _client.auth.currentUser?.id;
    if (id == null) {
      throw StateError('Utente non autenticato');
    }
    return id;
  }

  @override
  Future<List<Holding>> fetchHoldings() async {
    final rows = await _client
        .from('holdings')
        .select()
        .order('symbol', ascending: true);
    return (rows as List)
        .cast<Map<String, dynamic>>()
        .map(Holding.fromMap)
        .toList();
  }

  @override
  Future<Holding> upsertHolding(Holding holding) async {
    final payload = holding.toInsert(_uid);
    final Map<String, dynamic> row;
    final existingId = int.tryParse(holding.id);
    if (existingId != null) {
      row = await _client
          .from('holdings')
          .update(payload)
          .eq('id', existingId)
          .select()
          .single();
    } else {
      row = await _client.from('holdings').insert(payload).select().single();
    }
    return Holding.fromMap(row);
  }

  @override
  Future<void> deleteHolding(String id) async {
    await _client.from('holdings').delete().eq('id', int.parse(id));
  }

  @override
  Future<Map<String, double>> fetchTargets() async {
    final rows = await _client.from('target_allocations').select();
    return {
      for (final r in (rows as List).cast<Map<String, dynamic>>())
        r['asset_class'] as String: (r['target_pct'] as num).toDouble(),
    };
  }

  @override
  Future<void> saveTargets(Map<String, double> targets) async {
    await _client.from('target_allocations').delete().eq('user_id', _uid);
    if (targets.isEmpty) return;
    await _client.from('target_allocations').insert([
      for (final e in targets.entries)
        {'user_id': _uid, 'asset_class': e.key, 'target_pct': e.value},
    ]);
  }
}

/// Repository in memoria per la modalità demo (nessun backend).
class InMemoryPortfolioRepository implements PortfolioRepository {
  final List<Holding> _holdings = [
    const Holding(
      id: '1',
      symbol: 'AAPL',
      name: 'Apple Inc.',
      quantity: 10,
      avgPrice: 150,
      assetClass: AssetClass.stock,
      sector: 'Technology',
    ),
    const Holding(
      id: '2',
      symbol: 'MSFT',
      name: 'Microsoft Corp.',
      quantity: 5,
      avgPrice: 300,
      assetClass: AssetClass.stock,
      sector: 'Technology',
    ),
    const Holding(
      id: '3',
      symbol: 'VWCE.DE',
      name: 'Vanguard FTSE All-World',
      quantity: 20,
      avgPrice: 100,
      assetClass: AssetClass.etf,
      sector: 'Global Equity',
    ),
  ];
  Map<String, double> _targets = {
    AssetClass.stock.name: 50,
    AssetClass.etf.name: 40,
    AssetClass.cash.name: 10,
  };
  int _seq = 4;

  @override
  Future<List<Holding>> fetchHoldings() async => List.unmodifiable(_holdings);

  @override
  Future<Holding> upsertHolding(Holding holding) async {
    final idx = _holdings.indexWhere((h) => h.id == holding.id);
    if (idx >= 0) {
      _holdings[idx] = holding;
      return holding;
    }
    final created = holding.copyWith();
    final withId = Holding(
      id: (_seq++).toString(),
      symbol: created.symbol,
      name: created.name,
      quantity: created.quantity,
      avgPrice: created.avgPrice,
      assetClass: created.assetClass,
      sector: created.sector,
    );
    _holdings.add(withId);
    return withId;
  }

  @override
  Future<void> deleteHolding(String id) async {
    _holdings.removeWhere((h) => h.id == id);
  }

  @override
  Future<Map<String, double>> fetchTargets() async => Map.of(_targets);

  @override
  Future<void> saveTargets(Map<String, double> targets) async {
    _targets = Map.of(targets);
  }
}
