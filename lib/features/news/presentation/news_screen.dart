import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/news_providers.dart';

class NewsScreen extends ConsumerWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final news = ref.watch(portfolioNewsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Novità sul portafoglio')),
      body: news.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Errore: $e')),
        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Nessuna notizia al momento per i tuoi titoli. Aggiungi '
                  'posizioni per vedere qui le novità che potrebbero riguardarle.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: list.length + 1,
            itemBuilder: (_, i) {
              if (i == list.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Le notizie sono solo a scopo informativo e non costituiscono '
                    'un invito a comprare o vendere. Evita decisioni impulsive '
                    'basate sui titoli di giornata.',
                    style: TextStyle(fontSize: 12),
                  ),
                );
              }
              final n = list[i];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.article_outlined),
                  title: Text(n.title),
                  subtitle: Text([
                    if (n.relatedSymbol != null) n.relatedSymbol,
                    if (n.publisher.isNotEmpty) n.publisher,
                  ].whereType<String>().join(' · ')),
                  trailing: n.link.isEmpty
                      ? null
                      : const Icon(Icons.open_in_new, size: 18),
                  onTap: n.link.isEmpty
                      ? null
                      : () => launchUrl(Uri.parse(n.link),
                          mode: LaunchMode.externalApplication),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
