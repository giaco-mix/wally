import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/format.dart';
import '../import/csv_importer.dart';
import '../providers/portfolio_providers.dart';

/// Schermata di import delle posizioni da un CSV esportato dal broker.
/// Mostra un'anteprima (colonne riconosciute, righe valide/scartate) prima di
/// confermare l'import.
class ImportCsvScreen extends ConsumerStatefulWidget {
  const ImportCsvScreen({super.key});

  @override
  ConsumerState<ImportCsvScreen> createState() => _ImportCsvScreenState();
}

class _ImportCsvScreenState extends ConsumerState<ImportCsvScreen> {
  String? _fileName;
  CsvImportResult? _result;
  String? _error;
  bool _busy = false;

  Future<void> _pickFile() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['csv', 'txt'],
        withData: true,
      );
      if (picked == null || picked.files.isEmpty) return;
      final file = picked.files.first;
      final bytes = file.bytes;
      if (bytes == null) {
        setState(() => _error = 'Non sono riuscito a leggere il file.');
        return;
      }
      final content = utf8.decode(bytes, allowMalformed: true);
      final result = CsvImporter.parse(content);
      setState(() {
        _fileName = file.name;
        _result = result;
      });
    } on CsvImportException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'File non valido o non leggibile.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _confirmImport() async {
    final result = _result;
    if (result == null) return;
    final holdings = [
      for (final r in result.validRows)
        if (r.holding != null) r.holding!,
    ];
    if (holdings.isEmpty) return;

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _busy = true);
    try {
      await ref
          .read(holdingsControllerProvider.notifier)
          .importHoldings(holdings);
      messenger.showSnackBar(
        SnackBar(content: Text('Importate ${holdings.length} posizioni ✅')),
      );
      navigator.pop();
    } catch (_) {
      setState(() {
        _busy = false;
        _error = 'Import non riuscito. Riprova.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    return Scaffold(
      appBar: AppBar(title: const Text('Importa da CSV')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Esporta le posizioni dal tuo broker in formato CSV e caricalo qui. '
            'Wally riconosce da solo le colonne più comuni '
            '(simbolo, quantità, prezzo medio).',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _busy ? null : _pickFile,
            icon: const Icon(Icons.upload_file),
            label: Text(_fileName == null ? 'Scegli file CSV' : 'Cambia file'),
          ),
          if (_fileName != null) ...[
            const SizedBox(height: 8),
            Text(_fileName!, style: Theme.of(context).textTheme.bodySmall),
          ],
          if (_error != null) ...[
            const SizedBox(height: 16),
            _Banner(text: _error!, isError: true),
          ],
          if (result != null) ...[
            const SizedBox(height: 16),
            _MappingSummary(result: result),
            const SizedBox(height: 16),
            if (!result.hasRequiredColumns)
              const _Banner(
                text: 'Mancano colonne obbligatorie. Servono almeno: simbolo, '
                    'quantità e prezzo medio. Controlla le intestazioni del file.',
                isError: true,
              )
            else ...[
              _PreviewTable(rows: result.validRows),
              if (result.errorRows.isNotEmpty) ...[
                const SizedBox(height: 16),
                _ErrorList(rows: result.errorRows),
              ],
            ],
          ],
        ],
      ),
      bottomNavigationBar: (result != null &&
              result.hasRequiredColumns &&
              result.validRows.isNotEmpty)
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton(
                  onPressed: _busy ? null : _confirmImport,
                  child: _busy
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : Text('Importa ${result.validRows.length} posizioni'),
                ),
              ),
            )
          : null,
    );
  }
}

class _MappingSummary extends StatelessWidget {
  const _MappingSummary({required this.result});
  final CsvImportResult result;

  static const _labels = {
    ImportField.symbol: 'Simbolo',
    ImportField.name: 'Nome',
    ImportField.quantity: 'Quantità',
    ImportField.avgPrice: 'Prezzo medio',
    ImportField.assetClass: 'Tipo',
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Colonne riconosciute',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final f in ImportField.values)
                  Chip(
                    avatar: Icon(
                      result.mapping.containsKey(f)
                          ? Icons.check_circle
                          : Icons.remove_circle_outline,
                      size: 18,
                    ),
                    label: Text(
                      result.mapping.containsKey(f)
                          ? '${_labels[f]}: ${result.headers[result.mapping[f]!]}'
                          : '${_labels[f]}: —',
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${result.validRows.length} righe valide · '
              '${result.errorRows.length} scartate',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewTable extends StatelessWidget {
  const _PreviewTable({required this.rows});
  final List<CsvImportRow> rows;

  static const _maxPreview = 20;

  @override
  Widget build(BuildContext context) {
    final shown = rows.take(_maxPreview).toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 20,
                columns: const [
                  DataColumn(label: Text('Simbolo')),
                  DataColumn(label: Text('Tipo')),
                  DataColumn(label: Text('Quantità'), numeric: true),
                  DataColumn(label: Text('Prezzo'), numeric: true),
                ],
                rows: [
                  for (final r in shown)
                    DataRow(cells: [
                      DataCell(Text(r.holding!.symbol)),
                      DataCell(Text(r.holding!.assetClass.label)),
                      DataCell(Text(Fmt.ratio(r.holding!.quantity,
                          decimals: r.holding!.quantity % 1 == 0 ? 0 : 2))),
                      DataCell(Text(Fmt.money(r.holding!.avgPrice))),
                    ]),
                ],
              ),
            ),
            if (rows.length > _maxPreview)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text('… e altre ${rows.length - _maxPreview}',
                    style: Theme.of(context).textTheme.bodySmall),
              ),
          ],
        ),
      ),
    );
  }
}

class _ErrorList extends StatelessWidget {
  const _ErrorList({required this.rows});
  final List<CsvImportRow> rows;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Righe scartate',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final r in rows.take(10))
              Text('Riga ${r.lineNumber}: ${r.error}',
                  style: Theme.of(context).textTheme.bodySmall),
            if (rows.length > 10)
              Text('… e altre ${rows.length - 10}',
                  style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.text, this.isError = false});
  final String text;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: isError ? scheme.errorContainer : scheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(isError ? Icons.error_outline : Icons.info_outline, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(text)),
          ],
        ),
      ),
    );
  }
}
