import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/format.dart';
import '../../../market/domain/fundamentals.dart';
import '../../domain/dcf.dart';

/// Stima del valore intrinseco (DCF) con assunzioni regolabili dall'utente.
/// Solo per azioni con flussi di cassa e azioni disponibili. È una **stima
/// educativa**, non un prezzo obiettivo.
class DcfCard extends StatefulWidget {
  const DcfCard({super.key, required this.f});
  final Fundamentals f;

  /// Vero se ci sono i dati minimi per il calcolo.
  static bool canCompute(Fundamentals f) =>
      !f.isFund &&
      (f.freeCashflow ?? 0) > 0 &&
      (f.sharesOutstanding ?? 0) > 0;

  @override
  State<DcfCard> createState() => _DcfCardState();
}

class _DcfCardState extends State<DcfCard> {
  late double _growth; // %
  double _discount = 9; // %
  static const _terminal = 2.5; // %
  static const _years = 10;

  @override
  void initState() {
    super.initState();
    // Default: crescita ricavi (se nota) limitata a un range prudente.
    final g = (widget.f.revenueGrowth ?? 0.08) * 100;
    _growth = g.clamp(0, 15).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.f;
    final netDebt = (f.totalDebt ?? 0) - (f.totalCash ?? 0);
    final inputs = DcfInputs(
      freeCashflow: f.freeCashflow!,
      growthRate: _growth / 100,
      discountRate: _discount / 100,
      terminalGrowth: _terminal / 100,
      years: _years,
      sharesOutstanding: f.sharesOutstanding!,
      netDebt: netDebt,
    );
    final valid = Dcf.isValid(inputs);
    final res = valid ? Dcf.compute(inputs) : null;
    final price = f.impliedPrice;

    double? upside;
    if (res != null && price != null && price > 0) {
      upside = (res.intrinsicPerShare - price) / price * 100;
    }
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Valore intrinseco (DCF)',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Stima quanto "vale" l\'azienda dai flussi di cassa futuri '
              'attualizzati. Cambia le assunzioni: il risultato cambia.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            _slider('Crescita flussi (primi $_years anni)', _growth, 0, 20,
                (v) => setState(() => _growth = v), suffix: '%/anno'),
            _slider('Tasso di sconto (rendimento richiesto)', _discount, 4, 15,
                (v) => setState(() => _discount = v), suffix: '%'),
            const SizedBox(height: 8),
            if (res == null)
              Text(
                'Il tasso di sconto deve essere maggiore della crescita '
                'perpetua (${Fmt.pct(_terminal)}). Alza lo sconto.',
                style: TextStyle(color: scheme.error),
              )
            else ...[
              Row(
                children: [
                  Expanded(
                    child: _metric(context, 'Valore intrinseco / azione',
                        Fmt.money(res.intrinsicPerShare)),
                  ),
                  Expanded(
                    child: _metric(context, 'Prezzo attuale (stima)',
                        price == null ? '—' : Fmt.money(price)),
                  ),
                ],
              ),
              if (upside != null) ...[
                const SizedBox(height: 8),
                Text(
                  upside >= 0
                      ? 'Potenzialmente SOTTOVALUTATO di ${Fmt.pct(upside)} '
                          'rispetto alla stima'
                      : 'Potenzialmente SOPRAVVALUTATO di ${Fmt.pct(upside.abs())} '
                          'rispetto alla stima',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: upside >= 0 ? AppTheme.positive : AppTheme.negative,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Text('Prezzo con margine di sicurezza',
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 4),
              for (final m in const [20.0, 30.0, 40.0])
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      SizedBox(
                          width: 90,
                          child: Text('margine ${Fmt.pct(m, decimals: 0)}')),
                      Text(Fmt.money(res.priceWithMargin(m)),
                          style:
                              const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                'Regola pratica: azienda stabile ~20-30% di margine, poco '
                'stabile ~40-50%. Il margine copre gli errori di stima.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Stima educativa con assunzioni semplificate (no net-debt '
              'dettagliato, crescita costante). Non è un prezzo obiettivo né '
              'un consiglio.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _slider(String label, double value, double min, double max,
      ValueChanged<double> onChanged,
      {String suffix = ''}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${Fmt.pct(value)} $suffix',
            style: Theme.of(context).textTheme.bodySmall),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          divisions: ((max - min) * 2).round(),
          label: Fmt.pct(value),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _metric(BuildContext context, String label, String value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
        ],
      );
}
