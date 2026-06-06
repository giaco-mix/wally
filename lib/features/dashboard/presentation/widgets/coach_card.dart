import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../coach/domain/mood.dart';
import '../../../coach/providers/coach_providers.dart';

/// Card del coach in dashboard: in giornate difficili diventa un invito alla
/// calma; altrimenti un check-in veloce dell'umore.
class CoachCard extends ConsumerWidget {
  const CoachCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final panic = ref.watch(showPanicInterventionProvider);
    final scheme = Theme.of(context).colorScheme;

    if (panic) {
      return Card(
        color: scheme.errorContainer,
        child: InkWell(
          onTap: () => context.go('/coach'),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.self_improvement, color: scheme.onErrorContainer),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Giornata difficile? Respira.',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: scheme.onErrorContainer,
                                fontWeight: FontWeight.bold,
                              )),
                      Text('Apri Wally Coach prima di prendere decisioni d\'impulso.',
                          style: TextStyle(color: scheme.onErrorContainer)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: scheme.onErrorContainer),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Come ti senti oggi?',
                    style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                TextButton(
                  onPressed: () => context.go('/coach'),
                  child: const Text('Wally Coach'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final m in Mood.values)
                  ActionChip(
                    label: Text('${m.emoji} ${m.label}'),
                    onPressed: () {
                      ref
                          .read(moodCheckinsControllerProvider.notifier)
                          .record(m);
                      context.go('/coach');
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
