import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../domain/lesson.dart';
import 'lesson_screen.dart';

/// Area educativa: lezioni descrittive (non prescrittive) raggruppate per tema.
class AcademyScreen extends StatelessWidget {
  const AcademyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Impara')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Educazione all\'investimento',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            'Non esiste una via giusta o sbagliata: ci sono approcci diversi. '
            'Qui capisci come funzionano, poi decidi tu.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          for (final category in academyCategories) ...[
            Text(category, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final l in academyLessons.where((x) => x.category == category))
              _LessonCard(lesson: l),
            const SizedBox(height: 16),
          ],
          Card(
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.school_outlined),
                  title: const Text('Vedi le strategie pronte'),
                  subtitle: const Text('Portafogli-modello da cui partire'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/strategie'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.search),
                  title: const Text('Trova lo strumento'),
                  subtitle:
                      const Text('Dall\'allocazione all\'ETF giusto'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/strumenti'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.menu_book),
                  title: const Text('Glossario'),
                  subtitle: const Text('I termini spiegati semplici'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/glossario'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.forum_outlined),
                  title: const Text('Fammi una domanda'),
                  subtitle: const Text('Tutor (anteprima)'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/tutor'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  const _LessonCard({required this.lesson});
  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(lesson.title,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(lesson.summary),
        trailing: const Icon(Icons.chevron_right),
        isThreeLine: true,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => LessonScreen(lesson: lesson)),
        ),
      ),
    );
  }
}
