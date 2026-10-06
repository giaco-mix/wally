import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../domain/achievements.dart';
import '../providers/achievements_provider.dart';

/// "Traguardi": gamifica il comportamento virtuoso (streak PAC, badge).
class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(achievementsProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Traguardi')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: scheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.local_fire_department, size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${s.streak} mesi di fila',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        Text(
                          s.streak == 0
                              ? 'Registra i tuoi versamenti PAC per far partire la serie.'
                              : 'Serie di versamenti PAC consecutivi. Non mollare! 💪',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text('${s.unlocked} / ${s.list.length} traguardi sbloccati',
                style: Theme.of(context).textTheme.bodyMedium),
          ),
          for (final a in s.list) _Badge(a: a),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.a});
  final Achievement a;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: a.unlocked
              ? AppTheme.positive.withValues(alpha: 0.15)
              : scheme.surfaceContainerHighest,
          child: Icon(
            a.unlocked ? Icons.emoji_events : Icons.lock_outline,
            color: a.unlocked ? AppTheme.positive : scheme.outline,
          ),
        ),
        title: Text(a.title,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: a.unlocked ? null : scheme.onSurfaceVariant)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(a.description),
            if (!a.unlocked && a.progress != null && a.progress! > 0) ...[
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                    value: a.progress, minHeight: 5),
              ),
            ],
          ],
        ),
        isThreeLine: !a.unlocked && (a.progress ?? 0) > 0,
      ),
    );
  }
}
