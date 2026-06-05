import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/format.dart';
import '../../plan/providers/plan_providers.dart';
import '../domain/broker.dart';
import '../providers/portfolio_providers.dart';

class BrokersScreen extends ConsumerWidget {
  const BrokersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brokersAsync = ref.watch(brokersControllerProvider);
    final plan = ref.watch(planControllerProvider).asData?.value;

    return Scaffold(
      appBar: AppBar(title: const Text('Piattaforme e commissioni')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Aggiungi'),
      ),
      body: brokersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Errore: $e')),
        data: (brokers) {
          if (brokers.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Aggiungi le piattaforme su cui investi e le loro commissioni: '
                  'Wally calcolerà i costi e il netto.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              for (final b in brokers)
                Card(
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.account_balance)),
                    title: Text(b.name,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Canone ${Fmt.money(b.accountFeeAnnual)}/anno · '
                            'ordine ${Fmt.money(b.orderFeeFixed)}'
                            '${b.orderFeePercent > 0 ? ' + ${Fmt.pct(b.orderFeePercent, decimals: 2)}' : ''}'),
                        if (plan != null)
                          Text(
                            'Con il tuo PAC (${Fmt.money(plan.monthlyContribution)}/mese): '
                            '~${Fmt.money(b.annualPacCost(plan.monthlyContribution))}/anno di costi',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (v) {
                        if (v == 'edit') _showForm(context, ref, existing: b);
                        if (v == 'delete') {
                          ref
                              .read(brokersControllerProvider.notifier)
                              .delete(b.id);
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('Modifica')),
                        PopupMenuItem(value: 'delete', child: Text('Elimina')),
                      ],
                    ),
                    onTap: () => _showForm(context, ref, existing: b),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _showForm(BuildContext context, WidgetRef ref, {Broker? existing}) {
    showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: _BrokerForm(existing: existing),
        ),
      ),
    );
  }
}

class _BrokerForm extends ConsumerStatefulWidget {
  const _BrokerForm({this.existing});
  final Broker? existing;

  @override
  ConsumerState<_BrokerForm> createState() => _BrokerFormState();
}

class _BrokerFormState extends ConsumerState<_BrokerForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _account;
  late final TextEditingController _orderFixed;
  late final TextEditingController _orderPct;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final b = widget.existing;
    _name = TextEditingController(text: b?.name ?? '');
    _account = TextEditingController(
        text: b != null && b.accountFeeAnnual > 0
            ? b.accountFeeAnnual.toString()
            : '');
    _orderFixed = TextEditingController(
        text: b != null && b.orderFeeFixed > 0 ? b.orderFeeFixed.toString() : '');
    _orderPct = TextEditingController(
        text: b != null && b.orderFeePercent > 0
            ? b.orderFeePercent.toString()
            : '');
  }

  @override
  void dispose() {
    _name.dispose();
    _account.dispose();
    _orderFixed.dispose();
    _orderPct.dispose();
    super.dispose();
  }

  double _num(TextEditingController c) =>
      double.tryParse(c.text.replaceAll(',', '.')) ?? 0;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final broker = Broker(
      id: widget.existing?.id ?? '',
      name: _name.text.trim(),
      accountFeeAnnual: _num(_account),
      orderFeeFixed: _num(_orderFixed),
      orderFeePercent: _num(_orderPct),
    );
    try {
      await ref.read(brokersControllerProvider.notifier).save(broker);
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.existing == null ? 'Nuova piattaforma' : 'Modifica piattaforma',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Nome (es. Directa)'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Obbligatorio' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _account,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              decoration: const InputDecoration(
                labelText: 'Canone annuo (€)',
                hintText: 'es. 0',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _orderFixed,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Commissione ordine (€)',
                      hintText: 'es. 5',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _orderPct,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Commissione %',
                      suffixText: '%',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _saving ? null : () => Navigator.of(context).pop(),
                  child: const Text('Annulla'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Salva'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
