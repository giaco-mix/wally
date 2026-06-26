/// Una notizia potenzialmente rilevante per il portafoglio.
class NewsItem {
  const NewsItem({
    required this.title,
    required this.publisher,
    required this.link,
    this.relatedSymbol,
    this.providerPublishTime,
    this.thumbnail,
  });

  final String title;
  final String publisher;
  final String link;
  final String? relatedSymbol;
  final DateTime? providerPublishTime;
  final String? thumbnail;

  /// Tempo trascorso in forma compatta (es. "2h fa", "3g fa").
  String? get relativeTime {
    final t = providerPublishTime;
    if (t == null) return null;
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 60) return '${d.inMinutes}m fa';
    if (d.inHours < 24) return '${d.inHours}h fa';
    return '${d.inDays}g fa';
  }

  factory NewsItem.fromYahoo(Map<String, dynamic> m, {String? symbol}) {
    final ts = m['providerPublishTime'];
    String? thumb;
    final res = m['thumbnail']?['resolutions'];
    if (res is List && res.isNotEmpty && res.first is Map) {
      thumb = (res.first as Map)['url'] as String?;
    }
    return NewsItem(
      title: (m['title'] as String?) ?? '—',
      publisher: (m['publisher'] as String?) ?? '',
      link: (m['link'] as String?) ?? '',
      relatedSymbol: symbol,
      providerPublishTime: ts is num
          ? DateTime.fromMillisecondsSinceEpoch(ts.toInt() * 1000)
          : null,
      thumbnail: thumb,
    );
  }
}
