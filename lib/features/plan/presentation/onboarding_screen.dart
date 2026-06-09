import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/format.dart';
import '../domain/goal.dart';
import '../domain/investment_plan.dart';
import '../domain/lazy_portfolio.dart';
import '../domain/pac_calculator.dart';
import '../domain/risk_profile.dart';
import '../providers/plan_providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const _steps = 5;
  int _step = 0;

  GoalType? _goal;
  final _goalLabel = TextEditingController();
  RiskProfile? _risk;
  PlanMode _mode = PlanMode.sustainableContribution;
  int _horizon = 15;
  final _amount = TextEditingController();
  String? _lazyId;
  bool _saving = false;

  @override
  void dispose() {
    _goalLabel.dispose();
    _amount.dispose();
    super.dispose();
  }

  double? get _amountValue =>
      double.tryParse(_amount.text.replaceAll(',', '.').trim());

  double get _expectedReturn => _risk?.expectedReturn ?? 0.05;

  double? get _computedMonthly {
    final v = _amountValue;
    if (v == null || v <= 0) return null;
    if (_mode == PlanMode.targetCapital) {
      return PacCalculator.requiredMonthly(
          target: v, years: _horizon, annualReturn: _expectedReturn);
    }
    return v;
  }

  double? get _computedTarget {
    final v = _amountValue;
    if (v == null || v <= 0) return null;
    if (_mode == PlanMode.targetCapital) return v;
    return PacCalculator.futureValue(
        monthly: v, years: _horizon, annualReturn: _expectedReturn);
  }

  bool get _canAdvance => switch (_step) {
        0 => _goal != null,
        1 => _risk != null,
        2 => (_amountValue ?? 0) > 0,
        3 => _lazyId != null,
        _ => true,
      };

  /// Cosa manca per proseguire dallo step corrente (per il messaggio guida).
  String get _advanceHint => switch (_step) {
        0 => 'Scegli un obiettivo per continuare.',
        1 => 'Dimmi che tipo di investitore sei.',
        2 => 'Inserisci un importo per continuare.',
        3 => 'Scegli un portafoglio di partenza.',
        _ => 'Completa lo step per continuare.',
      };

  void _next() {
    // Il pulsante resta sempre visibile: se manca qualcosa, lo spieghiamo
    // invece di lasciarlo grigio/invisibile.
    if (!_canAdvance) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(_advanceHint)));
      return;
    }
    if (_step < _steps - 1) {
      setState(() => _step++);
    } else {
      _save();
    }
  }

  void _back() {
    if (_step == 0) {
      context.go('/');
    } else {
      setState(() => _step--);
    }
  }

  Future<void> _save() async {
    final monthly = _computedMonthly;
    if (_goal == null || _risk == null || monthly == null) return;
    setState(() => _saving = true);
    final plan = InvestmentPlan(
      goalType: _goal!,
      goalLabel: _goalLabel.text.trim().isEmpty ? null : _goalLabel.text.trim(),
      mode: _mode,
      targetAmount: _mode == PlanMode.targetCapital ? _amountValue : null,
      horizonYears: _horizon,
      monthlyContribution: monthly,
      riskProfile: _risk!,
      lazyPortfolioId: _lazyId ?? LazyPortfolio.forProfile(_risk!).id,
    );
    try {
      await ref.read(planControllerProvider.notifier).save(plan);
      if (mounted) context.go('/plan');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crea il tuo piano'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _back,
        ),
      ),
      // La barra azioni è in bottomNavigationBar: così è SEMPRE fissa in fondo
      // e visibile, indipendentemente dall'altezza del contenuto dello step.
      bottomNavigationBar: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              TextButton(
                onPressed: _saving ? null : _back,
                child: Text(_step == 0 ? 'Annulla' : 'Indietro'),
              ),
              const Spacer(),
              FilledButton(
                onPressed: _saving ? null : _next,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(_step == _steps - 1 ? 'Crea il piano' : 'Avanti'),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(value: (_step + 1) / _steps),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Row(
              children: [
                Text('Passo ${_step + 1} di $_steps',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: _buildStep(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep() => switch (_step) {
        0 => _goalStep(),
        1 => _riskStep(),
        2 => _amountStep(),
        3 => _lazyStep(),
        _ => _summaryStep(),
      };

  Widget _title(String t, String sub) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(sub, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 20),
        ],
      );

  // Step 0 — obiettivo
  Widget _goalStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title('Qual è il tuo obiettivo?',
            'Partiamo dal perché: dà un senso al piano e ti aiuta a non mollare.'),
        ...GoalType.values.map((g) {
          final selected = _goal == g;
          return Card(
            color: selected
                ? Theme.of(context).colorScheme.primaryContainer
                : null,
            child: ListTile(
              leading: Icon(g.icon),
              title: Text(g.label),
              trailing: selected ? const Icon(Icons.check_circle) : null,
              onTap: () => setState(() => _goal = g),
            ),
          );
        }),
        if (_goal == GoalType.other) ...[
          const SizedBox(height: 8),
          TextField(
            controller: _goalLabel,
            decoration: const InputDecoration(labelText: 'Descrivi il tuo obiettivo'),
          ),
        ],
      ],
    );
  }

  // Step 1 — rischio
  Widget _riskStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title('Che tipo di investitore sei?',
            'Non esistono scelte giuste o sbagliate: solo quella giusta per te.'),
        ...RiskProfile.values.map((r) {
          final selected = _risk == r;
          return Card(
            color: selected
                ? Theme.of(context).colorScheme.primaryContainer
                : null,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: InkWell(
                onTap: () => setState(() {
                  _risk = r;
                  _lazyId = LazyPortfolio.forProfile(r).id;
                }),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(r.label,
                              style: Theme.of(context).textTheme.titleMedium),
                        ),
                        if (selected) const Icon(Icons.check_circle),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(r.description),
                    const SizedBox(height: 6),
                    Text('Rendimento medio atteso ~${Fmt.pct(r.expectedReturn * 100)}/anno · ${r.worstYearText}',
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 8),
        Text('Stime indicative, non garanzie.',
            style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  // Step 2 — importi e orizzonte
  Widget _amountStep() {
    final monthly = _computedMonthly;
    final target = _computedTarget;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title('Impostiamo i numeri',
            'Puoi partire da quanto vuoi ottenere o da quanto puoi versare.'),
        SegmentedButton<PlanMode>(
          segments: const [
            ButtonSegment(
                value: PlanMode.sustainableContribution,
                label: Text('Quanto verso'),
                icon: Icon(Icons.payments_outlined)),
            ButtonSegment(
                value: PlanMode.targetCapital,
                label: Text('Quanto voglio'),
                icon: Icon(Icons.flag_outlined)),
          ],
          selected: {_mode},
          onSelectionChanged: (s) => setState(() => _mode = s.first),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _amount,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: _mode == PlanMode.targetCapital
                ? 'Capitale obiettivo (€)'
                : 'Versamento mensile (€)',
            prefixIcon: const Icon(Icons.euro),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 24),
        Text('Orizzonte: $_horizon anni',
            style: Theme.of(context).textTheme.titleMedium),
        const _Hint(
          'L\'orizzonte è per quanti anni lasci lavorare i tuoi soldi. '
          'Più tempo dai all\'investimento, più le oscillazioni hanno modo '
          'di compensarsi.',
        ),
        Slider(
          value: _horizon.toDouble(),
          min: 1,
          max: 40,
          divisions: 39,
          label: '$_horizon anni',
          onChanged: (v) => setState(() => _horizon = v.round()),
        ),
        const SizedBox(height: 8),
        if (monthly != null && target != null)
          Card(
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _mode == PlanMode.targetCapital
                  ? Text(
                      'Per arrivare a ${Fmt.money(target)} in $_horizon anni '
                      'ti servono circa ${Fmt.money(monthly)} al mese.',
                      style: Theme.of(context).textTheme.titleMedium,
                    )
                  : Text(
                      'Versando ${Fmt.money(monthly)} al mese per $_horizon anni '
                      'potresti arrivare a circa ${Fmt.money(target)}.',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
            ),
          ),
        const _Hint(
          'Versare un po\' ogni mese si chiama PAC (Piano di Accumulo): '
          'compri un po\' alla volta e non devi indovinare il momento giusto '
          'per entrare. È la difesa numero uno contro le mosse di pancia.',
        ),
      ],
    );
  }

  // Step 3 — lazy portfolio
  Widget _lazyStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title('Il tuo portafoglio di partenza',
            'Una ricetta semplice e diversificata, adatta al tuo profilo.'),
        const _Hint(
          'In breve: le azioni sono il motore di crescita (rendono di più ma '
          'oscillano), obbligazioni e liquidità danno stabilità (più calme, '
          'rendono meno). Mescolarle riduce gli sbalzi.',
        ),
        const SizedBox(height: 12),
        ...LazyPortfolio.catalog.map((p) {
          final selected = _lazyId == p.id;
          return Card(
            color: selected
                ? Theme.of(context).colorScheme.primaryContainer
                : null,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: InkWell(
                onTap: () => setState(() => _lazyId = p.id),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(p.name,
                              style: Theme.of(context).textTheme.titleMedium),
                        ),
                        if (selected) const Icon(Icons.check_circle),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(p.description),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: p.allocations.entries
                          .map((e) => Chip(
                                label: Text(
                                    '${e.key.label} ${e.value.toStringAsFixed(0)}%'),
                                visualDensity: VisualDensity.compact,
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // Step 4 — riepilogo
  Widget _summaryStep() {
    final monthly = _computedMonthly ?? 0;
    final target = _computedTarget ?? 0;
    final lazy = LazyPortfolio.byId(_lazyId);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title('Ecco il tuo piano 🎯',
            'Dai un\'occhiata: potrai modificarlo quando vuoi.'),
        _row('Obiettivo', _goal?.label ?? '—'),
        _row('Profilo', _risk?.label ?? '—'),
        _row('Orizzonte', '$_horizon anni'),
        _row('Versamento mensile', Fmt.money(monthly)),
        _row('Valore atteso', Fmt.money(target)),
        _row('Totale versato', Fmt.money(monthly * _horizon * 12)),
        _row('Portafoglio', lazy?.name ?? '—'),
        const SizedBox(height: 16),
        Card(
          color: Theme.of(context).colorScheme.tertiaryContainer,
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Ricorda: la cosa più importante non è partire perfetti, ma '
              'restare costanti. Wally è qui per questo. 💪',
            ),
          ),
        ),
      ],
    );
  }

  Widget _row(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(child: Text(k)),
            Text(v, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      );
}

/// Nota esplicativa "amichevole" per spiegare un termine senza gergo.
/// Sempre visibile (non nascosta in un expander): per chi parte da zero è più
/// utile leggere subito cosa significa.
class _Hint extends StatelessWidget {
  const _Hint(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, size: 18, color: scheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
