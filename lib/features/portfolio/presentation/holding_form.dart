import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../market/providers/market_providers.dart';
import '../domain/holding.dart';
import '../providers/portfolio_providers.dart';

/// Apre il form (dialog) per creare o modificare una posizione.
Future<void> showHoldingForm(BuildContext context, {Holding? existing}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _HoldingForm(existing: existing),
  );
}

class _HoldingForm extends ConsumerStatefulWidget {
  const _HoldingForm({this.existing});
  final Holding? existing;

  @override
  ConsumerState<_HoldingForm> createState() => _HoldingFormState();
}

class _HoldingFormState extends ConsumerState<_HoldingForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _symbol;
  late final TextEditingController _name;
  late final TextEditingController _qty;
  late final TextEditingController _price;
  late final TextEditingController _ter;
  late AssetClass _assetClass;
  late DistributionPolicy _distribution;
  bool _saving = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final h = widget.existing;
    _symbol = TextEditingController(text: h?.symbol ?? '');
    _name = TextEditingController(text: h?.name ?? '');
    _qty = TextEditingController(text: h?.quantity.toString() ?? '');
    _price = TextEditingController(text: h?.avgPrice.toString() ?? '');
    _ter = TextEditingController(
      text: (h != null && h.ter > 0) ? h.ter.toString() : '',
    );
    _assetClass = h?.assetClass ?? AssetClass.stock;
    _distribution = h?.distribution ?? DistributionPolicy.none;
  }

  @override
  void dispose() {
    _symbol.dispose();
    _name.dispose();
    _qty.dispose();
    _price.dispose();
    _ter.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final qty = double.parse(_qty.text.replaceAll(',', '.'));
    final price = double.parse(_price.text.replaceAll(',', '.'));
    final ter = double.tryParse(_ter.text.replaceAll(',', '.')) ?? 0;
    final holding = Holding(
      id: widget.existing?.id ?? '',
      symbol: _symbol.text.trim().toUpperCase(),
      name: _name.text.trim().isEmpty ? _symbol.text.trim() : _name.text.trim(),
      quantity: qty,
      avgPrice: price,
      assetClass: _assetClass,
      sector: widget.existing?.sector,
      ter: ter,
      distribution: _distribution,
    );
    try {
      await ref.read(holdingsControllerProvider.notifier).save(holding);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Errore: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _numberValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Obbligatorio';
    final parsed = double.tryParse(v.replaceAll(',', '.'));
    if (parsed == null || parsed <= 0) return 'Valore non valido';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // Larghezza contenuto: ~460 su desktop, ridotta su finestre strette.
    final width = math.min(460.0, MediaQuery.sizeOf(context).width - 48);
    return AlertDialog(
      title: Text(_isEdit ? 'Modifica posizione' : 'Nuova posizione'),
      // scrollable: il contenuto scorre se non ci sta; le actions (Annulla/
      // Salva) restano SEMPRE fisse e visibili in fondo.
      scrollable: true,
      content: SizedBox(
        width: width,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SymbolField(
                controller: _symbol,
                enabled: !_isEdit,
                onSelected: (res) {
                  _symbol.text = res.symbol;
                  if (_name.text.trim().isEmpty) _name.text = res.name;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(
                  labelText: 'Nome (opzionale)',
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _qty,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                      ],
                      decoration: const InputDecoration(labelText: 'Quantità'),
                      validator: _numberValidator,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _price,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Prezzo medio',
                      ),
                      validator: _numberValidator,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<AssetClass>(
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
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ter,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'TER % (opzionale)',
                        hintText: 'es. 0.20',
                        suffixText: '%',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<DistributionPolicy>(
                      initialValue: _distribution,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Dividendi'),
                      items: [
                        for (final d in DistributionPolicy.values)
                          DropdownMenuItem(value: d, child: Text(d.label)),
                      ],
                      onChanged: (v) =>
                          setState(() => _distribution = v ?? _distribution),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Annulla'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Salva'),
        ),
      ],
    );
  }
}

/// Campo simbolo con autocompletamento via ricerca Yahoo.
class _SymbolField extends ConsumerWidget {
  const _SymbolField({
    required this.controller,
    required this.enabled,
    required this.onSelected,
  });

  final TextEditingController controller;
  final bool enabled;
  final void Function(dynamic) onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!enabled) {
      return TextFormField(
        controller: controller,
        enabled: false,
        decoration: const InputDecoration(labelText: 'Simbolo / Ticker'),
      );
    }
    return Autocomplete<String>(
      optionsBuilder: (value) async {
        final text = value.text.trim();
        if (text.length < 2) return const Iterable<String>.empty();
        final results = await ref.read(symbolSearchProvider(text).future);
        return results.map((r) => '${r.symbol}  •  ${r.name}');
      },
      onSelected: (s) {
        final sym = s.split('  •  ').first.trim();
        controller.text = sym;
      },
      fieldViewBuilder: (context, textCtrl, focusNode, _) {
        textCtrl.text = controller.text;
        return TextFormField(
          controller: textCtrl,
          focusNode: focusNode,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(
            labelText: 'Simbolo / Ticker',
            hintText: 'es. AAPL',
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
