import 'package:flutter/material.dart';

import '../../domain/risk_profile.dart';

/// Mini-quiz "psicanalisi" del consulente: poche domande per capire la
/// situazione (A1) e un reality-check sul rapporto rischio/rendimento (A2).
/// Ritorna il profilo suggerito (o null se annullato).
Future<RiskProfile?> showRiskQuiz(BuildContext context) {
  return showDialog<RiskProfile>(
    context: context,
    builder: (_) => const Dialog(child: _RiskQuiz()),
  );
}

class _RiskQuiz extends StatefulWidget {
  const _RiskQuiz();
  @override
  State<_RiskQuiz> createState() => _RiskQuizState();
}

class _RiskQuizState extends State<_RiskQuiz> {
  int? _horizon; // 0 <5, 1 5-10, 2 >10
  int? _reaction; // 0 vendo, 1 aspetto, 2 compro
  int? _ambition; // 0 sicuro, 1 medio, 2 massimo

  bool get _complete =>
      _horizon != null && _reaction != null && _ambition != null;

  RiskProfile get _suggested {
    final score = (_horizon ?? 0) + (_reaction ?? 0) + (_ambition ?? 0);
    if (score <= 1) return RiskProfile.prudent;
    if (score <= 4) return RiskProfile.balanced;
    return RiskProfile.aggressive;
  }

  /// Conflitto: vuole il massimo rendimento ma venderebbe al primo calo.
  bool get _conflict => _ambition == 2 && _reaction == 0;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Scopri il tuo profilo',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text('Tre domande veloci: non c\'è risposta giusta o sbagliata.',
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 16),
            _question(
              'Tra quanto ti servono questi soldi?',
              ['Meno di 5 anni', '5–10 anni', 'Più di 10 anni'],
              _horizon,
              (v) => setState(() => _horizon = v),
            ),
            _question(
              'Il mercato perde il 30% in un mese. Tu cosa fai?',
              ['Vendo per non perdere altro', 'Aspetto, ma con ansia',
                  'Approfitto e compro ancora'],
              _reaction,
              (v) => setState(() => _reaction = v),
            ),
            _question(
              'Che rendimento sogni?',
              ['Poco ma sicuro (~3%)', 'Una buona via di mezzo (~5–6%)',
                  'Il massimo possibile'],
              _ambition,
              (v) => setState(() => _ambition = v),
            ),
            if (_complete) ...[
              const SizedBox(height: 8),
              Card(
                color: _conflict
                    ? Theme.of(context).colorScheme.errorContainer
                    : Theme.of(context).colorScheme.secondaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _conflict
                            ? 'Attenzione: aspettative da riequilibrare'
                            : 'Profilo suggerito: ${_suggested.label}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(_conflict
                          ? 'Vuoi il massimo rendimento ma venderesti al primo '
                              'calo: sono in conflitto. Rendimento e rischio vanno '
                              'sempre insieme — non esiste "tanto guadagno, poco '
                              'rischio". Se non te la senti di reggere forti cali, '
                              'meglio puntare a un rendimento più realistico. Ti '
                              'consiglio di partire ${RiskProfile.balanced.label}.'
                          : '${_suggested.description} Punta a circa '
                              '${(_suggested.expectedReturn * 100).toStringAsFixed(0)}%/anno. '
                              '${_suggested.worstYearText}'),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annulla'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _complete
                      ? () => Navigator.pop(
                          context, _conflict ? RiskProfile.balanced : _suggested)
                      : null,
                  child: const Text('Usa questo profilo'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _question(
    String q,
    List<String> options,
    int? value,
    ValueChanged<int> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(q, style: const TextStyle(fontWeight: FontWeight.w600)),
        for (var i = 0; i < options.length; i++)
          ListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            leading: Icon(value == i
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked),
            title: Text(options[i]),
            onTap: () => onChanged(i),
          ),
      ],
    );
  }
}
