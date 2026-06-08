import 'package:finance_companion/features/portfolio/domain/holding.dart';
import 'package:finance_companion/features/portfolio/import/csv_importer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CsvImporter.parse', () {
    test('CSV con virgola, header EN, prezzi US', () {
      const csv = 'symbol,name,quantity,price,asset_class\n'
          'AAPL,Apple Inc.,10,150.25,stock\n'
          'VWCE,Vanguard All-World,20,100,etf\n';
      final result = CsvImporter.parse(csv);

      expect(result.delimiter, ',');
      expect(result.hasRequiredColumns, isTrue);
      expect(result.validRows.length, 2);
      expect(result.errorRows, isEmpty);

      final aapl = result.validRows.first.holding!;
      expect(aapl.symbol, 'AAPL');
      expect(aapl.quantity, 10);
      expect(aapl.avgPrice, 150.25);
      expect(aapl.assetClass, AssetClass.stock);

      final vwce = result.validRows[1].holding!;
      expect(vwce.assetClass, AssetClass.etf);
    });

    test('CSV con punto e virgola, header IT, decimali con virgola', () {
      const csv = 'Simbolo;Nome;Quantità;Prezzo medio;Tipo\n'
          'ENI.MI;Eni;100;14,50;Azioni\n'
          'BTP;Btp Italia;5;1.012,34;Obbligazioni\n';
      final result = CsvImporter.parse(csv);

      expect(result.delimiter, ';');
      expect(result.hasRequiredColumns, isTrue);
      expect(result.validRows.length, 2);

      final eni = result.validRows.first.holding!;
      expect(eni.symbol, 'ENI.MI');
      expect(eni.avgPrice, 14.50);
      expect(eni.assetClass, AssetClass.stock);

      final btp = result.validRows[1].holding!;
      expect(btp.avgPrice, 1012.34); // 1.012,34 -> 1012.34
      expect(btp.assetClass, AssetClass.bond);
    });

    test('righe non valide finiscono in errorRows con il numero di riga', () {
      const csv = 'symbol,quantity,price\n'
          'AAPL,10,150\n'
          ',5,100\n' // simbolo mancante
          'MSFT,abc,300\n'; // quantità non valida
      final result = CsvImporter.parse(csv);

      expect(result.validRows.length, 1);
      expect(result.errorRows.length, 2);
      expect(result.errorRows.first.lineNumber, 2);
      expect(result.errorRows.first.error, contains('Simbolo'));
      expect(result.errorRows[1].error, contains('Quantità'));
    });

    test('senza colonne obbligatorie hasRequiredColumns è false', () {
      const csv = 'nome,note\nApple,bella azienda\n';
      final result = CsvImporter.parse(csv);
      expect(result.hasRequiredColumns, isFalse);
    });

    test('file vuoto lancia CsvImportException', () {
      expect(() => CsvImporter.parse('   \n  '),
          throwsA(isA<CsvImportException>()));
    });

    test('il nome ricade sul simbolo se assente', () {
      const csv = 'symbol,quantity,price\nAAPL,10,150\n';
      final result = CsvImporter.parse(csv);
      expect(result.validRows.first.holding!.name, 'AAPL');
    });

    test('classifica le obbligazioni per durata', () {
      const csv = 'symbol,quantity,price,tipo\n'
          'IB01,1,5,Obbligazione a breve termine\n'
          'BND5,1,5,Bond medio termine\n'
          'IBGL,1,5,Obbligazionario lungo termine\n'
          'GEN,1,5,Obbligazioni\n'
          'AAA,1,5,Azioni globali\n';
      final rows = CsvImporter.parse(csv).validRows;
      expect(rows[0].holding!.assetClass, AssetClass.bondShort);
      expect(rows[1].holding!.assetClass, AssetClass.bondMid);
      expect(rows[2].holding!.assetClass, AssetClass.bondLong);
      expect(rows[3].holding!.assetClass, AssetClass.bond);
      expect(rows[4].holding!.assetClass, AssetClass.stock);
    });
  });
}
