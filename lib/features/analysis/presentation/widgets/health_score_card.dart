import 'package:flutter/material.dart';

import '../../../market/domain/fundamentals.dart';
import '../../../market/domain/health_score.dart';

class HealthScoreCard extends StatelessWidget {
  const HealthScoreCard({super.key, required this.fundamentals});
  final Fundamentals fundamentals;

  static Color colorFor(int score) {
    if (score >= 75) return const Color(0xFF2E7D32);
    if (score >= 60) return const Color(0xFF7CB342);
    if (score >= 45) return const Color(0xFFF9A825);
    if (score >= 30) return const Color(0xFFEF6C00);
    return const Color(0xFFC62828);
  }

  @override
  Widget build(BuildContext context) {
    final score = HealthScore.from(fundamentals);
    if (!score.hasData) return const SizedBox.shrink();
    final color = colorFor(score.overall);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Health score fondamentale',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Row(
              children: [
                _ScoreRing(score: score.overall, color: color),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(score.rating,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(color: color, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                        'Sintesi pesata di valutazione, redditività, solidità '
                        'e crescita.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...score.factors.map((f) => _FactorBar(factor: f)),
          ],
        ),
      ),
    );
  }
}

class _ScoreRing extends StatelessWidget {
  const _ScoreRing({required this.score, required this.color});
  final int score;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 84,
      width: 84,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: 84,
            width: 84,
            child: CircularProgressIndicator(
              value: score / 100,
              strokeWidth: 8,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          Text('$score',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

class _FactorBar extends StatelessWidget {
  const _FactorBar({required this.factor});
  final HealthFactor factor;

  @override
  Widget build(BuildContext context) {
    final color = HealthScoreCard.colorFor(factor.score);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(factor.label,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
              Text('${factor.score}',
                  style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: factor.score / 100,
              minHeight: 6,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: 2),
          Text(factor.detail,
              style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
