import 'package:finance_companion/features/market/domain/fundamentals.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _summary(Map<String, dynamic> result) => {
      'quoteSummary': {
        'result': [result],
      },
    };

void main() {
  group('Fundamentals.fromYahooSummary', () {
    test('riconosce un ETF e ne legge TER, categoria, yield e holdings', () {
      final json = _summary({
        'price': {'quoteType': 'ETF', 'longName': 'iShares Core S&P 500'},
        'summaryDetail': {
          'yield': {'raw': 0.013},
        },
        'defaultKeyStatistics': {
          'ytdReturn': {'raw': 0.11},
        },
        'fundProfile': {
          'categoryName': 'Large Blend',
          'feesExpensesInvestment': {
            'annualReportExpenseRatio': {'raw': 0.0007},
          },
        },
        'topHoldings': {
          'holdings': [
            {
              'symbol': 'AAPL',
              'holdingName': 'Apple Inc',
              'holdingPercent': {'raw': 0.07},
            },
            {
              'symbol': 'MSFT',
              'holdingName': 'Microsoft Corp',
              'holdingPercent': {'raw': 0.065},
            },
          ],
        },
      });

      final f = Fundamentals.fromYahooSummary('CSPX.MI', json);

      expect(f.isFund, isTrue);
      expect(f.quoteType, 'ETF');
      expect(f.category, 'Large Blend');
      expect(f.expenseRatio, 0.0007);
      expect(f.fundYield, 0.013);
      expect(f.ytdReturn, 0.11);
      expect(f.topHoldings.length, 2);
      expect(f.topHoldings.first.name, 'Apple Inc');
      expect(f.topHoldings.first.weight, 0.07);
    });

    test('un\'azione non è un fondo e mantiene le metriche equity', () {
      final json = _summary({
        'price': {'quoteType': 'EQUITY', 'longName': 'Apple Inc.'},
        'summaryDetail': {
          'trailingPE': {'raw': 28.5},
        },
        'financialData': {
          'returnOnEquity': {'raw': 0.45},
        },
      });

      final f = Fundamentals.fromYahooSummary('AAPL', json);

      expect(f.isFund, isFalse);
      expect(f.trailingPe, 28.5);
      expect(f.returnOnEquity, 0.45);
      expect(f.topHoldings, isEmpty);
    });
  });
}
