import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/format.dart';
import '../../market/domain/price_point.dart';
import '../../market/providers/market_providers.dart';
import '../../portfolio/domain/holding.dart';
import '../domain/transaction.dart';
import '../providers/transactions_providers.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txs = ref.watch(transactionsControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Movimenti')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog<void>(
          context: context,
          builder: (_) => const Dialog(child: _TxForm()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Registra'),
      ),
      body: txs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Errore: $e')),
        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Registra qui i tuoi acquisti (PAC, versamenti extra, quota '
                  'iniziale): Wally aggiorna le posizioni e tiene traccia del '
                  'bilanciamento nel tempo.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: list.length,
            itemBuilder: (_, i) {
              final t = list[i];
              final buy = t.side == TxSide.buy;
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: (buy ? Colors.green : Colors.red)
                        .withValues(alpha: 0.15),
                    child: Icon(buy ? Icons.add : Icons.remove,
                        color: buy ? Colors.green : Colors.red),
                  ),
                  title: Text(
                      '${t.symbol} · ${t.kind.label}'
                      '${t.sleeve == TxSleeve.none ? '' : ' · ${t.sleeve.label}'}',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                      '${_d(t.date)} · ${Fmt.ratio(t.quantity)} × ${Fmt.money(t.price)}'),
                  trailing: Text(
                    '${buy ? '+' : '-'}${Fmt.money(t.amount)}',
                    style: TextStyle(
                        color: buy ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold),
                  ),
                  onLongPress: () => ref
                      .read(transactionsControllerProvider.notifier)
                      .delete(t.id!),
                ),
              );
            },
          );
        },
      ),
    );
  }

  static String _d(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

class _TxForm extends ConsumerStatefulWidget {
  const _TxForm();
  @override
  ConsumerState<_TxForm> createState() => _TxFormState();
}

class _TxFormState extends ConsumerState<_TxForm> {
  final _formKey = GlobalKey<FormState>();
  final _symbol = TextEditingController();
  final _name = TextEditingController();
  final _qty = TextEditingController();
  final _price = TextEditingController();
  TxSide _side = TxSide.buy;
  TxKind _kind = TxKind.pac;
  TxSleeve _sleeve = TxSleeve.none;
  AssetClass _assetClass = AssetClass.etf;
  String _currency = 'EUR';
  DateTime _date = DateTime.now();
  bool _saving = false;
  bool _loadingPrice = false;

  @override
  void dispose() {
    _symbol.dispose();
    _name.dispose();
    _qty.dispose();
    _price.dispose();
    super.dispose();
  }

  double? _num(TextEditingController c) =>
      double.tryParse(c.text.replaceAll(',', '.').trim());

  Future<void> _fillPriceAtDate() async {
    final sym = _symbol.text.trim();
    if (sym.isEmpty) return;
    setState(() => _loadingPrice = true);
    try {
      final hist = await ref.read(
        priceHistoryProvider((symbol: sym, range: HistoryRange.oneYear)).future,
      );
      if (hist.points.isEmpty) return;
      // Punto con la data più vicina a quella scelta.
      PricePoint nearest = hist.points.first;
      var best = (nearest.date.difference(_date)).abs();
      for (final p in hist.points) {
        final d = (p.date.difference(_date)).abs();
        if (d < best) {
          best = d;
          nearest = p;
        }
      }
      _price.text = nearest.close.toStringAsFixed(2);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Prezzo non disponibile per quella data')),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingPrice = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final tx = Transaction(
      symbol: _symbol.text.trim().toUpperCase(),
      name: _name.text.trim().isEmpty ? _symbol.text.trim() : _name.text.trim(),
      side: _side,
      kind: _kind,
      date: _date,
      quantity: _num(_qty)!,
      price: _num(_price)!,
      assetClass: _assetClass,
      currency: _currency,
      sleeve: _sleeve,
    );
    try {
      await ref.read(transactionsControllerProvider.notifier).record(tx);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Errore: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _req(String? v) =>
      (v == null || _num(TextEditingController(text: v)) == null)
          ? 'Valore non valido'
          : null;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 480),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Registra operazione',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              SegmentedButton<TxSide>(
                segments: const [
                  ButtonSegment(value: TxSide.buy, label: Text('Acquisto')),
                  ButtonSegment(value: TxSide.sell, label: Text('Vendita')),
                ],
                selected: {_side},
                onSelectionChanged: (s) => setState(() => _side = s.first),
              ),
              const SizedBox(height: 12),
              _SymbolField(
                controller: _symbol,
                onPicked: (sym, name) {
                  _symbol.text = sym;
                  if (_name.text.trim().isEmpty) _name.text = name;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<TxKind>(
                      initialValue: _kind,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Tipo'),
                      items: [
                        for (final k in TxKind.values)
                          DropdownMenuItem(value: k, child: Text(k.label)),
                      ],
                      onChanged: (v) => setState(() => _kind = v ?? _kind),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<TxSleeve>(
                      initialValue: _sleeve,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Comparto'),
                      items: [
                        for (final s in TxSleeve.values)
                          DropdownMenuItem(value: s, child: Text(s.label)),
                      ],
                      onChanged: (v) => setState(() => _sleeve = v ?? _sleeve),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => _date = picked);
                },
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Data'),
                  child: Text(TransactionsScreen._d(_date)),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _qty,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                      ],
                      decoration: const InputDecoration(labelText: 'Quantità'),
                      validator: _req,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _price,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Prezzo',
                        suffixIcon: IconButton(
                          tooltip: 'Prezzo alla data',
                          icon: _loadingPrice
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.history),
                          onPressed: _loadingPrice ? null : _fillPriceAtDate,
                        ),
                      ),
                      validator: _req,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<AssetClass>(
                      initialValue: _assetClass,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Asset class'),
                      items: [
                        for (final ac in AssetClass.values)
                          DropdownMenuItem(value: ac, child: Text(ac.label)),
                      ],
                      onChanged: (v) =>
                          setState(() => _assetClass = v ?? _assetClass),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _currency,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Valuta'),
                      items: const [
                        DropdownMenuItem(value: 'EUR', child: Text('EUR €')),
                        DropdownMenuItem(value: 'USD', child: Text('USD \$')),
                      ],
                      onChanged: (v) => setState(() => _currency = v ?? _currency),
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
                        : const Text('Registra'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SymbolField extends ConsumerWidget {
  const _SymbolField({required this.controller, required this.onPicked});
  final TextEditingController controller;
  final void Function(String symbol, String name) onPicked;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Autocomplete<String>(
      optionsBuilder: (value) async {
        final text = value.text.trim();
        if (text.length < 2) return const Iterable<String>.empty();
        final results = await ref.read(symbolSearchProvider(text).future);
        return results.map((r) => '${r.symbol}  •  ${r.name}');
      },
      onSelected: (s) {
        final parts = s.split('  •  ');
        controller.text = parts.first.trim();
        onPicked(parts.first.trim(), parts.length > 1 ? parts[1].trim() : '');
      },
      fieldViewBuilder: (context, textCtrl, focusNode, _) {
        textCtrl.text = controller.text;
        return TextFormField(
          controller: textCtrl,
          focusNode: focusNode,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(
            labelText: 'Simbolo / Ticker',
            hintText: 'es. VWCE.DE',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (v) => controller.text = v,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Obbligatorio' : null,
        );
      },
    );
  }
}
