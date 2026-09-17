import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/providers.dart';
import '../../market/domain/quote.dart';
import '../../portfolio/domain/holding.dart';
import '../../portfolio/domain/position.dart';
import '../data/advisor_repository.dart';
import '../domain/advisor_client.dart';

final advisorRepositoryProvider = Provider<AdvisorRepository>((ref) {
  return SupabaseAdvisorRepository(ref.watch(supabaseClientProvider));
});

/// Vero se le funzioni consulente reali sono disponibili (serve il backend).
final advisorBackendReadyProvider =
    Provider<bool>((_) => AppConfig.isConfigured);

/// Clienti del consulente. Con backend reale li carica da Supabase (holdings +
/// quotazioni); in demo usa dati dimostrativi.
final advisorClientsProvider = FutureProvider<List<AdvisorClient>>((ref) async {
  if (!AppConfig.isConfigured) return _demoClients;

  final repo = ref.watch(advisorRepositoryProvider);
  final links = await repo.fetchActiveClients();
  if (links.isEmpty) return const [];

  // Carica gli holdings di ogni cliente e raccoglie i simboli.
  final holdingsByLink = <AdvisorClientLink, List<Holding>>{};
  final symbols = <String>{};
  for (final l in links) {
    if (l.clientId == null) continue;
    final hs = await repo.clientHoldings(l.clientId!);
    holdingsByLink[l] = hs;
    symbols.addAll(hs.map((h) => h.symbol.toUpperCase()));
  }

  final quotes = symbols.isEmpty
      ? <String, Quote>{}
      : await ref.watch(marketRepositoryProvider).quotes(symbols.toList());

  return [
    for (final entry in holdingsByLink.entries)
      AdvisorClient(
        id: entry.key.id.toString(),
        name: entry.key.label ?? entry.key.email,
        note: entry.key.label == null ? null : entry.key.email,
        positions: [
          for (final h in entry.value)
            Position(holding: h, quote: quotes[h.symbol.toUpperCase()]),
        ],
      ),
  ];
});

/// Inviti in attesa indirizzati all'utente corrente (lato cliente).
final pendingInvitesProvider =
    FutureProvider<List<AdvisorClientLink>>((ref) async {
  if (!AppConfig.isConfigured) return const [];
  return ref.watch(advisorRepositoryProvider).pendingInvitesForMe();
});

// ── Dati dimostrativi (modalità demo) ───────────────────────────────────────

Position _pos(
  String symbol,
  String name,
  AssetClass ac,
  double qty,
  double avg,
  double price, {
  double? prev,
  String? sector,
}) {
  return Position(
    holding: Holding(
      id: symbol,
      symbol: symbol,
      name: name,
      quantity: qty,
      avgPrice: avg,
      assetClass: ac,
      sector: sector,
    ),
    quote: Quote(symbol: symbol, price: price, previousClose: prev ?? price),
  );
}

final List<AdvisorClient> _demoClients = [
  AdvisorClient(
    id: 'c1',
    name: 'Marco R.',
    note: 'PAC world + obbligazioni · profilo equilibrato',
    positions: [
      _pos('SWDA.MI', 'iShares Core MSCI World', AssetClass.etf, 40, 85, 92,
          prev: 91, sector: 'Azionario globale'),
      _pos('AGGH.MI', 'iShares Core Global Aggregate Bond', AssetClass.bondMid,
          30, 5.2, 5.0, prev: 5.01),
    ],
  ),
  AdvisorClient(
    id: 'c2',
    name: 'Giulia B.',
    note: 'Aggressiva · azionario + un po\' di oro',
    positions: [
      _pos('VWCE.DE', 'Vanguard FTSE All-World', AssetClass.etf, 60, 100, 112,
          prev: 110, sector: 'Azionario globale'),
      _pos('SGLD.MI', 'Invesco Physical Gold', AssetClass.other, 15, 200, 220,
          prev: 219, sector: 'Oro'),
    ],
  ),
  AdvisorClient(
    id: 'c3',
    name: 'Antonio F.',
    note: 'Prudente · obbligazioni brevi + liquidità',
    positions: [
      _pos('IB01.MI', 'iShares Treasury Bond 0-1yr', AssetClass.bondShort, 50,
          5.0, 5.05, prev: 5.05),
      _pos('CASH', 'Liquidità', AssetClass.cash, 3000, 1, 1),
    ],
  ),
];
