import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/disclaimer_banner.dart';
import '../domain/lesson.dart';
import '../domain/lesson_quiz.dart';
import '../providers/academy_progress.dart';

class LessonScreen extends ConsumerStatefulWidget {
  const LessonScreen({super.key, required this.lesson});
  final Lesson lesson;

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  int? _selected;

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;
    final paragraphs = lesson.body.split('\n\n');
    final quiz = academyQuizzes[lesson.id];
    final completed =
        ref.watch(academyProgressProvider).asData?.value.contains(lesson.id) ??
            false;

    return Scaffold(
      appBar: AppBar(
        title: Text(lesson.category),
        actions: [
          if (completed)
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.check_circle, color: AppTheme.positive),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(lesson.title,
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text('${lesson.minutes} min di lettura',
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 16),
          for (final p in paragraphs) ...[
            _Paragraph(text: p),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 8),
          if (quiz != null)
            _QuizCard(
              quiz: quiz,
              selected: _selected,
              completed: completed,
              onSelect: (i) {
                setState(() => _selected = i);
                if (i == quiz.answer) {
                  ref
                      .read(academyProgressProvider.notifier)
                      .markCompleted(lesson.id);
                }
              },
            )
          else if (!completed)
            FilledButton.tonalIcon(
              onPressed: () => ref
                  .read(academyProgressProvider.notifier)
                  .markCompleted(lesson.id),
              icon: const Icon(Icons.check),
              label: const Text('Segna come completata'),
            ),
          const DisclaimerBanner(margin: EdgeInsets.only(top: 12)),
        ],
      ),
    );
  }
}

class _QuizCard extends StatelessWidget {
  const _QuizCard({
    required this.quiz,
    required this.selected,
    required this.completed,
    required this.onSelect,
  });

  final LessonQuiz quiz;
  final int? selected;
  final bool completed;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final answered = selected != null;
    final correct = selected == quiz.answer;
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quiz', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(quiz.question,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            for (var i = 0; i < quiz.options.length; i++)
              _Option(
                text: quiz.options[i],
                state: !answered
                    ? _OptState.idle
                    : i == quiz.answer
                        ? _OptState.correct
                        : (i == selected ? _OptState.wrong : _OptState.idle),
                onTap: answered ? null : () => onSelect(i),
              ),
            if (answered) ...[
              const SizedBox(height: 8),
              Text(
                correct ? 'Esatto! ✓' : 'Non proprio — riprova a ragionarci.',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: correct ? AppTheme.positive : AppTheme.negative,
                ),
              ),
              if (quiz.explanation != null) ...[
                const SizedBox(height: 4),
                Text(quiz.explanation!,
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

enum _OptState { idle, correct, wrong }

class _Option extends StatelessWidget {
  const _Option({required this.text, required this.state, this.onTap});
  final String text;
  final _OptState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Color? bg;
    IconData? icon;
    switch (state) {
      case _OptState.correct:
        bg = AppTheme.positive.withValues(alpha: 0.15);
        icon = Icons.check_circle;
      case _OptState.wrong:
        bg = AppTheme.negative.withValues(alpha: 0.15);
        icon = Icons.cancel;
      case _OptState.idle:
        bg = null;
        icon = null;
    }
    return Card(
      elevation: 0,
      color: bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: ListTile(
        dense: true,
        title: Text(text),
        trailing: icon == null
            ? null
            : Icon(icon,
                color: state == _OptState.correct
                    ? AppTheme.positive
                    : AppTheme.negative),
        onTap: onTap,
      ),
    );
  }
}

/// Rende un paragrafo con un minimo di **grassetto** tra doppi asterischi.
class _Paragraph extends StatelessWidget {
  const _Paragraph({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).textTheme.bodyMedium;
    final spans = <TextSpan>[];
    final parts = text.split('**');
    for (var i = 0; i < parts.length; i++) {
      spans.add(TextSpan(
        text: parts[i],
        style: i.isOdd ? const TextStyle(fontWeight: FontWeight.bold) : null,
      ));
    }
    return Text.rich(TextSpan(style: base, children: spans));
  }
}
