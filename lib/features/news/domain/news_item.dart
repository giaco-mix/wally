/// Una notizia potenzialmente rilevante per il portafoglio.
class NewsItem {
  const NewsItem({
    required this.title,
    required this.publisher,
    required this.link,
    this.relatedSymbol,
    this.providerPublishTime,
  });

  final String title;
  final String publisher;
  final String link;
  final String? relatedSymbol;
  final DateTime? providerPublishTime;

  factory NewsItem.fromYahoo(Map<String, dynamic> m, {String? symbol}) {
    final ts = m['providerPublishTime'];
    return NewsItem(
      title: (m['title'] as String?) ?? '—',
      publisher: (m['publisher'] as String?) ?? '',
      link: (m['link'] as String?) ?? '',
      relatedSymbol: symbol,
      providerPublishTime: ts is num
          ? DateTime.fromMillisecondsSinceEpoch(ts.toInt() * 1000)
          : null,
    );
  }
}
