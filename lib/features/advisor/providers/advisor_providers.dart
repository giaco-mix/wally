import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../market/domain/quote.dart';
import '../../portfolio/domain/holding.dart';
import '../../portfolio/domain/position.dart';
import '../domain/advisor_client.dart';

/// Elenco dei clienti del consulente. **Prototipo**: dati dimostrativi in
/// memoria. Nella fase reale interrogherà Supabase (advisor_clients + RLS).
final advisorClientsProvider =
    Provider<List<AdvisorClient>>((ref) => _demoClients);

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
    quote: Quote(
      symbol: symbol,
      price: price,
      previousClose: prev ?? price,
    ),
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
