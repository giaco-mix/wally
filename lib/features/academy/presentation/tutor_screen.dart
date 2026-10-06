import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../domain/tutor_faq.dart';

class _Msg {
  const _Msg({required this.text, required this.fromUser, this.answer});
  final String text;
  final bool fromUser;
  final TutorAnswer? answer; // per il link correlato (lato tutor)
}

/// Tutor "Fammi una domanda" — **anteprima**: risposte pre-impostate.
class TutorScreen extends StatefulWidget {
  const TutorScreen({super.key});

  @override
  State<TutorScreen> createState() => _TutorScreenState();
}

class _TutorScreenState extends State<TutorScreen> {
  final _input = TextEditingController();
  final List<_Msg> _messages = [];

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _ask(String question) {
    final q = question.trim();
    if (q.isEmpty) return;
    final a = TutorDemo.answer(q);
    setState(() {
      _messages.add(_Msg(text: q, fromUser: true));
      _messages.add(_Msg(
        fromUser: false,
        answer: a,
        text: a?.answer ??
            'Nell\'anteprima rispondo solo ad alcuni temi. Prova a chiedere di: '
                'PAC, ETF, rischio, ribilanciamento, tasse, valore intrinseco o '
                'cosa fare quando il mercato scende.',
      ));
      _input.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Fammi una domanda')),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: scheme.tertiaryContainer,
            padding: const EdgeInsets.all(10),
            child: Text(
              'Anteprima: risposte pre-impostate. In futuro qui ci sarà un vero '
              'tutor AI. Sempre a scopo educativo, non consulenza.',
              style:
                  TextStyle(color: scheme.onTertiaryContainer, fontSize: 12),
            ),
          ),
          Expanded(
            child: _messages.isEmpty
                ? _Suggestions(onTap: _ask)
                : ListView(
                    padding: const EdgeInsets.all(12),
                    children: [
                      for (final m in _messages) _Bubble(msg: m),
                    ],
                  ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      decoration: const InputDecoration(
                        hintText: 'Scrivi una domanda…',
                      ),
                      onSubmitted: _ask,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: () => _ask(_input.text),
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Suggestions extends StatelessWidget {
  const _Suggestions({required this.onTap});
  final void Function(String) onTap;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Prova a chiedere',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final s in TutorDemo.suggestions)
          Card(
            child: ListTile(
              leading: const Icon(Icons.help_outline),
              title: Text(s),
              onTap: () => onTap(s),
            ),
          ),
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.msg});
  final _Msg msg;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final align = msg.fromUser ? Alignment.centerRight : Alignment.centerLeft;
    final color =
        msg.fromUser ? scheme.primaryContainer : scheme.surfaceContainerHighest;
    return Align(
      alignment: align,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(msg.text),
            if (msg.answer?.route != null) ...[
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => context.go(msg.answer!.route!),
                  child: Text(msg.answer!.routeLabel ?? 'Approfondisci'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
