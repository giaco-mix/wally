import 'package:flutter/material.dart';

import '../../../shared/widgets/disclaimer_banner.dart';
import '../domain/lesson.dart';

class LessonScreen extends StatelessWidget {
  const LessonScreen({super.key, required this.lesson});
  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    final paragraphs = lesson.body.split('\n\n');
    return Scaffold(
      appBar: AppBar(title: Text(lesson.category)),
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
          const DisclaimerBanner(margin: EdgeInsets.only(top: 8)),
        ],
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
        style: i.isOdd
            ? const TextStyle(fontWeight: FontWeight.bold)
            : null,
      ));
    }
    return Text.rich(TextSpan(style: base, children: spans));
  }
}
