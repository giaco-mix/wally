import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../news/providers/news_providers.dart';

/// Anteprima delle ultime novità sul portafoglio (link alla sezione completa).
class NewsCard extends ConsumerWidget {
  const NewsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final news = ref.watch(portfolioNewsProvider);
    return news.maybeWhen(
      orElse: () => const SizedBox.shrink(),
      data: (list) {
        if (list.isEmpty) return const SizedBox.shrink();
        final top = list.take(3).toList();
        return Card(
          child: InkWell(
            onTap: () => context.go('/news'),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.article_outlined),
                      const SizedBox(width: 8),
                      Text('Novità sul portafoglio',
                          style: Theme.of(context).textTheme.titleMedium),
                      const Spacer(),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...top.map((n) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          '• ${n.title}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      )),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
