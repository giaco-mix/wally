import 'package:supabase_flutter/supabase_flutter.dart';

import '../../coach/domain/mood.dart';
import '../../coach/domain/mood_checkin.dart';
import '../../rebalance/domain/rebalance_settings.dart';
import '../../transactions/domain/transaction.dart';
import '../domain/broker.dart';
import '../domain/holding.dart';
import '../domain/portfolio.dart';
import '../domain/portfolio_snapshot.dart';

abstract class PortfolioRepository {
  /// Posizioni del portafoglio indicato (o tutte se [portfolioId] è null).
  Future<List<Holding>> fetchHoldings([String? portfolioId]);
  Future<Holding> upsertHolding(Holding holding);
  Future<void> deleteHolding(String id);

  /// Portafogli dell'utente (multi-portafoglio).
  Future<List<Portfolio>> fetchPortfolios();
  Future<Portfolio> createPortfolio(String name);

  /// Garantisce l'esistenza di un portafoglio "Principale" e vi assegna le
  /// posizioni/operazioni ancora non collegate. Ritorna il suo id.
  Future<String> ensureDefaultPortfolio();

  /// Inserisce più posizioni in blocco (import CSV). Gli `id` sono ignorati.
  Future<void> importHoldings(List<Holding> holdings);

  /// Allocazioni target: mappa assetClass.name -> percentuale (0..100).
  Future<Map<String, double>> fetchTargets();
  Future<void> saveTargets(Map<String, double> targets);

  /// Storico del valore del portafoglio (ordinato per data crescente).
  Future<List<PortfolioSnapshot>> fetchSnapshots();

  /// Registra (o aggiorna) lo snapshot del giorno indicato.
  Future<void> recordSnapshot(DateTime date, double totalValue);

  /// Broker/piattaforme dell'utente.
  Future<List<Broker>> fetchBrokers();
  Future<void> upsertBroker(Broker broker);
  Future<void> deleteBroker(String id);

  /// Impostazioni di ribilanciamento schedulato.
  Future<RebalanceSettings> fetchRebalanceSettings();
  Future<void> saveRebalanceSettings(RebalanceSettings settings);

  /// Check-in dello stato d'animo (più recenti prima).
  Future<List<MoodCheckin>> fetchMoodCheckins();
  Future<void> recordMood(Mood mood);

  /// Registro operazioni del portafoglio indicato (o tutte se null).
  Future<List<Transaction>> fetchTransactions([String? portfolioId]);

  /// Registra un'operazione e aggiorna di conseguenza la posizione aggregata.
  Future<void> recordTransaction(Transaction tx);
  Future<void> deleteTransaction(String id);
}

/// Applica un'operazione alla posizione aggregata. Ritorna la nuova posizione,
/// oppure null se la posizione va eliminata (venduta del tutto).
Holding? applyTransaction(Holding? existing, Transaction tx) {
  if (tx.side == TxSide.buy) {
    if (existing == null) {
      return Holding(
        id: '',
        symbol: tx.symbol,
        name: tx.name,
        quantity: tx.quantity,
        avgPrice: tx.price,
        assetClass: tx.assetClass,
        ter: tx.ter,
        distribution: tx.distribution,
        currency: tx.currency,
        leverage: tx.leverage,
        portfolioId: tx.portfolioId,
      );
    }
    final newQty = existing.quantity + tx.quantity;
    final newAvg = (existing.costBasis + tx.amount) / newQty;
    return existing.copyWith(quantity: newQty, avgPrice: newAvg);
  }
  // Vendita
  if (existing == null) return existing;
  final newQty = existing.quantity - tx.quantity;
  if (newQty <= 0.0000001) return null;
  return existing.copyWith(quantity: newQty);
}

String _dateKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

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
  Future<List<Holding>> fetchHoldings([String? portfolioId]) async {
    final base = _client.from('holdings').select();
    final rows = portfolioId == null
        ? await base.order('symbol', ascending: true)
        : await base
            .eq('portfolio_id', int.parse(portfolioId))
            .order('symbol', ascending: true);
    return (rows as List)
        .cast<Map<String, dynamic>>()
        .map(Holding.fromMap)
        .toList();
  }

  @override
  Future<List<Portfolio>> fetchPortfolios() async {
    final rows =
        await _client.from('portfolios').select().order('id', ascending: true);
    return (rows as List)
        .cast<Map<String, dynamic>>()
        .map(Portfolio.fromMap)
        .toList();
  }

  @override
  Future<Portfolio> createPortfolio(String name) async {
    final row = await _client
        .from('portfolios')
        .insert({'user_id': _uid, 'name': name})
        .select()
        .single();
    return Portfolio.fromMap(row);
  }

  @override
  Future<String> ensureDefaultPortfolio() async {
    final existing = await _client
        .from('portfolios')
        .select()
        .order('id', ascending: true)
        .limit(1)
        .maybeSingle();
    if (existing != null) return existing['id'].toString();
    final created = await _client
        .from('portfolios')
        .insert({'user_id': _uid, 'name': 'Principale'})
        .select()
        .single();
    final id = created['id'];
    // Collega le righe ancora senza portafoglio.
    await _client
        .from('holdings')
        .update({'portfolio_id': id})
        .eq('user_id', _uid)
        .filter('portfolio_id', 'is', null);
    await _client
        .from('transactions')
        .update({'portfolio_id': id})
        .eq('user_id', _uid)
        .filter('portfolio_id', 'is', null);
    return id.toString();
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
  Future<void> importHoldings(List<Holding> holdings) async {
    if (holdings.isEmpty) return;
    final payload = [for (final h in holdings) h.toInsert(_uid)];
    await _client.from('holdings').insert(payload);
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

  @override
  Future<List<PortfolioSnapshot>> fetchSnapshots() async {
    final rows = await _client
        .from('portfolio_snapshots')
        .select()
        .order('snapshot_date', ascending: true);
    return (rows as List)
        .cast<Map<String, dynamic>>()
        .map(PortfolioSnapshot.fromMap)
        .toList();
  }

  @override
  Future<void> recordSnapshot(DateTime date, double totalValue) async {
    await _client.from('portfolio_snapshots').upsert(
      {
        'user_id': _uid,
        'snapshot_date': _dateKey(date),
        'total_value': totalValue,
      },
      onConflict: 'user_id,snapshot_date',
    );
  }

  @override
  Future<List<Broker>> fetchBrokers() async {
    final rows =
        await _client.from('brokers').select().order('name', ascending: true);
    return (rows as List)
        .cast<Map<String, dynamic>>()
        .map(Broker.fromMap)
        .toList();
  }

  @override
  Future<void> upsertBroker(Broker broker) async {
    final payload = broker.toInsert(_uid);
    final existingId = int.tryParse(broker.id);
    if (existingId != null) {
      await _client.from('brokers').update(payload).eq('id', existingId);
    } else {
      await _client.from('brokers').insert(payload);
    }
  }

  @override
  Future<void> deleteBroker(String id) async {
    await _client.from('brokers').delete().eq('id', int.parse(id));
  }

  @override
  Future<RebalanceSettings> fetchRebalanceSettings() async {
    final row = await _client
        .from('rebalance_settings')
        .select()
        .eq('user_id', _uid)
        .maybeSingle();
    if (row == null) return const RebalanceSettings();
    return RebalanceSettings.fromMap(row);
  }

  @override
  Future<void> saveRebalanceSettings(RebalanceSettings settings) async {
    await _client.from('rebalance_settings').upsert(
      {
        'user_id': _uid,
        'frequency': settings.frequency.name,
        'last_rebalanced_at': settings.lastRebalancedAt == null
            ? null
            : _dateKey(settings.lastRebalancedAt!),
        'updated_at': DateTime.now().toIso8601String(),
      },
      onConflict: 'user_id',
    );
  }

  @override
  Future<List<MoodCheckin>> fetchMoodCheckins() async {
    final rows = await _client
        .from('mood_checkins')
        .select()
        .order('created_at', ascending: false)
        .limit(60);
    return (rows as List)
        .cast<Map<String, dynamic>>()
        .map(MoodCheckin.fromMap)
        .toList();
  }

  @override
  Future<void> recordMood(Mood mood) async {
    await _client.from('mood_checkins').insert({
      'user_id': _uid,
      'mood': mood.name,
    });
  }

  @override
  Future<List<Transaction>> fetchTransactions([String? portfolioId]) async {
    final base = _client.from('transactions').select();
    final filtered =
        portfolioId == null ? base : base.eq('portfolio_id', int.parse(portfolioId));
    final rows = await filtered
        .order('tx_date', ascending: false)
        .order('id', ascending: false);
    return (rows as List)
        .cast<Map<String, dynamic>>()
        .map(Transaction.fromMap)
        .toList();
  }

  @override
  Future<void> recordTransaction(Transaction tx) async {
    await _client.from('transactions').insert(tx.toInsert(_uid));
    // Aggiorna la posizione aggregata corrispondente (stesso portafoglio).
    final base = _client
        .from('holdings')
        .select()
        .eq('user_id', _uid)
        .eq('symbol', tx.symbol.toUpperCase());
    final existingRow = await (tx.portfolioId == null
            ? base.filter('portfolio_id', 'is', null)
            : base.eq('portfolio_id', int.parse(tx.portfolioId!)))
        .limit(1)
        .maybeSingle();
    final existing =
        existingRow == null ? null : Holding.fromMap(existingRow);
    final updated = applyTransaction(existing, tx);
    if (updated == null) {
      if (existing != null) await deleteHolding(existing.id);
      return;
    }
    if (existing == null) {
      await _client.from('holdings').insert(updated.toInsert(_uid));
    } else {
      await _client
          .from('holdings')
          .update(updated.toInsert(_uid))
          .eq('id', int.parse(existing.id));
    }
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await _client.from('transactions').delete().eq('id', int.parse(id));
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

  final List<Portfolio> _portfolios = [];
  int _pfSeq = 1;

  @override
  Future<List<Holding>> fetchHoldings([String? portfolioId]) async {
    if (portfolioId == null) return List.unmodifiable(_holdings);
    return List.unmodifiable(
        _holdings.where((h) => h.portfolioId == portfolioId));
  }

  @override
  Future<List<Portfolio>> fetchPortfolios() async =>
      List.unmodifiable(_portfolios);

  @override
  Future<Portfolio> createPortfolio(String name) async {
    final p = Portfolio(id: 'p${_pfSeq++}', name: name);
    _portfolios.add(p);
    return p;
  }

  @override
  Future<String> ensureDefaultPortfolio() async {
    if (_portfolios.isNotEmpty) return _portfolios.first.id;
    final p = Portfolio(id: 'p${_pfSeq++}', name: 'Principale');
    _portfolios.add(p);
    for (var i = 0; i < _holdings.length; i++) {
      if (_holdings[i].portfolioId == null) {
        _holdings[i] = _holdings[i].copyWith(portfolioId: p.id);
      }
    }
    return p.id;
  }

  @override
  Future<Holding> upsertHolding(Holding holding) async {
    final idx = _holdings.indexWhere((h) => h.id == holding.id);
    if (idx >= 0) {
      _holdings[idx] = holding;
      return holding;
    }
    final withId = Holding(
      id: (_seq++).toString(),
      symbol: holding.symbol,
      name: holding.name,
      quantity: holding.quantity,
      avgPrice: holding.avgPrice,
      assetClass: holding.assetClass,
      sector: holding.sector,
      ter: holding.ter,
      distribution: holding.distribution,
      currency: holding.currency,
      leverage: holding.leverage,
    );
    _holdings.add(withId);
    return withId;
  }

  @override
  Future<void> deleteHolding(String id) async {
    _holdings.removeWhere((h) => h.id == id);
  }

  @override
  Future<void> importHoldings(List<Holding> holdings) async {
    for (final h in holdings) {
      _holdings.add(Holding(
        id: (_seq++).toString(),
        symbol: h.symbol,
        name: h.name,
        quantity: h.quantity,
        avgPrice: h.avgPrice,
        assetClass: h.assetClass,
        sector: h.sector,
        ter: h.ter,
        distribution: h.distribution,
      ));
    }
  }

  @override
  Future<Map<String, double>> fetchTargets() async => Map.of(_targets);

  @override
  Future<void> saveTargets(Map<String, double> targets) async {
    _targets = Map.of(targets);
  }

  final Map<String, PortfolioSnapshot> _snapshots = {};
  bool _seeded = false;

  void _seedSnapshots() {
    if (_seeded) return;
    _seeded = true;
    final now = DateTime.now();
    var value = 7000.0;
    for (var d = 30; d >= 1; d--) {
      value += (15 - (d % 7) * 4) + (d.isEven ? 25 : -10);
      final day = now.subtract(Duration(days: d));
      _snapshots[_dateKey(day)] =
          PortfolioSnapshot(date: day, totalValue: double.parse(value.toStringAsFixed(2)));
    }
  }

  @override
  Future<List<PortfolioSnapshot>> fetchSnapshots() async {
    _seedSnapshots();
    final list = _snapshots.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  @override
  Future<void> recordSnapshot(DateTime date, double totalValue) async {
    _seedSnapshots();
    final day = DateTime(date.year, date.month, date.day);
    _snapshots[_dateKey(day)] =
        PortfolioSnapshot(date: day, totalValue: totalValue);
  }

  final List<Broker> _brokers = [
    const Broker(
      id: 'b1',
      name: 'Directa',
      accountFeeAnnual: 0,
      orderFeeFixed: 5,
      orderFeePercent: 0,
    ),
  ];
  int _brokerSeq = 2;

  @override
  Future<List<Broker>> fetchBrokers() async => List.unmodifiable(_brokers);

  @override
  Future<void> upsertBroker(Broker broker) async {
    final idx = _brokers.indexWhere((b) => b.id == broker.id);
    if (idx >= 0) {
      _brokers[idx] = broker;
    } else {
      _brokers.add(Broker(
        id: 'b${_brokerSeq++}',
        name: broker.name,
        accountFeeAnnual: broker.accountFeeAnnual,
        orderFeeFixed: broker.orderFeeFixed,
        orderFeePercent: broker.orderFeePercent,
      ));
    }
  }

  @override
  Future<void> deleteBroker(String id) async {
    _brokers.removeWhere((b) => b.id == id);
  }

  RebalanceSettings _rebalanceSettings = const RebalanceSettings();

  @override
  Future<RebalanceSettings> fetchRebalanceSettings() async =>
      _rebalanceSettings;

  @override
  Future<void> saveRebalanceSettings(RebalanceSettings settings) async {
    _rebalanceSettings = settings;
  }

  final List<MoodCheckin> _moods = [];

  @override
  Future<List<MoodCheckin>> fetchMoodCheckins() async =>
      List.unmodifiable(_moods);

  @override
  Future<void> recordMood(Mood mood) async {
    _moods.insert(0, MoodCheckin(mood: mood, createdAt: DateTime.now()));
  }

  final List<Transaction> _txs = [];

  @override
  Future<List<Transaction>> fetchTransactions([String? portfolioId]) async {
    final list = [..._txs]
        .where((t) => portfolioId == null || t.portfolioId == portfolioId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return List.unmodifiable(list);
  }

  @override
  Future<void> recordTransaction(Transaction tx) async {
    _txs.insert(
      0,
      Transaction(
        id: (_seq++).toString(),
        symbol: tx.symbol,
        name: tx.name,
        side: tx.side,
        kind: tx.kind,
        date: tx.date,
        quantity: tx.quantity,
        price: tx.price,
        assetClass: tx.assetClass,
        currency: tx.currency,
        ter: tx.ter,
        distribution: tx.distribution,
        leverage: tx.leverage,
      ),
    );
    final idx = _holdings.indexWhere((h) =>
        h.symbol.toUpperCase() == tx.symbol.toUpperCase() &&
        h.portfolioId == tx.portfolioId);
    final existing = idx >= 0 ? _holdings[idx] : null;
    final updated = applyTransaction(existing, tx);
    if (updated == null) {
      if (idx >= 0) _holdings.removeAt(idx);
      return;
    }
    if (idx >= 0) {
      _holdings[idx] = updated.copyWith();
    } else {
      _holdings.add(Holding(
        id: (_seq++).toString(),
        symbol: updated.symbol,
        name: updated.name,
        quantity: updated.quantity,
        avgPrice: updated.avgPrice,
        assetClass: updated.assetClass,
        ter: updated.ter,
        distribution: updated.distribution,
        currency: updated.currency,
        leverage: updated.leverage,
        portfolioId: updated.portfolioId,
      ));
    }
  }

  @override
  Future<void> deleteTransaction(String id) async {
    _txs.removeWhere((t) => t.id == id);
  }
}
