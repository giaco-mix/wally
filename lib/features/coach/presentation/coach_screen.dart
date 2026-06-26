import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/format.dart';
import '../../../shared/widgets/disclaimer_banner.dart';
import '../../plan/domain/risk_profile.dart';
import '../../plan/providers/plan_providers.dart';
import '../domain/behavior_tips.dart';
import '../domain/mood.dart';
import '../providers/coach_providers.dart';

class CoachScreen extends ConsumerWidget {
  const CoachScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wally Coach')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (ref.watch(showPanicInterventionProvider)) ...[
            const _PanicCard(),
            const SizedBox(height: 16),
          ],
          const _MoodCheckinCard(),
          const SizedBox(height: 16),
          const _AdaptiveCard(),
          const _NotQuitterCard(),
          const SizedBox(height: 16),
          const _TipCard(),
          const DisclaimerBanner(margin: EdgeInsets.only(top: 16)),
        ],
      ),
    );
  }
}

/// Intervento anti panic-sell: empatia + contesto storico + costo del mollare.
class _PanicCard extends ConsumerWidget {
  const _PanicCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final dc = ref.watch(portfolioDayChangeProvider);
    final plan = ref.watch(planControllerProvider).asData?.value;

    return Card(
      color: scheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.self_improvement, color: scheme.onErrorContainer),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Respira. Sei nel posto giusto.',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: scheme.onErrorContainer,
                            fontWeight: FontWeight.bold,
                          )),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              dc != null && dc.pct < 0
                  ? 'Oggi il portafoglio è ${Fmt.signedPct(dc.pct)}. È normale '
                      'sentire un nodo allo stomaco — ma una giornata rossa non '
                      'cambia il tuo piano di lungo periodo.'
                  : 'Capita di sentirsi tentati di vendere. È proprio lì che si '
                      'fanno gli errori più costosi.',
              style: TextStyle(color: scheme.onErrorContainer),
            ),
            const SizedBox(height: 8),
            Text(
              'Ricorda: dopo ogni grande crisi il mercato ha sempre recuperato. '
              'Vendere ora cristallizzerebbe la perdita e rischieresti di perderti '
              'il rimbalzo. Non agire d\'impulso: il momento di decidere non è '
              'quando sei in tensione.',
              style: TextStyle(color: scheme.onErrorContainer),
            ),
            if (plan != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scheme.surface.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Il tuo piano punta a ${Fmt.money(plan.projectedValue)} in '
                  '${plan.horizonYears} anni. Mollare adesso vuol dire rinunciare '
                  'alla crescita attesa di ${Fmt.money(plan.projectedValue - plan.totalContributed)}. '
                  'Sei un not-quitter: resta sulla rotta. 💪',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MoodCheckinCard extends ConsumerWidget {
  const _MoodCheckinCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final last = ref.watch(lastMoodProvider);
    final isToday =
        last != null && DateTime.now().difference(last.createdAt).inHours < 24;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Come ti senti oggi?',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text('Un check-in veloce: capire come stai aiuta a non farti guidare '
                'dall\'emotività.',
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final m in Mood.values)
                  ChoiceChip(
                    label: Text('${m.emoji} ${m.label}'),
                    selected: isToday && last.mood == m,
                    onSelected: (_) =>
                        ref.read(moodCheckinsControllerProvider.notifier).record(m),
                  ),
              ],
            ),
            if (isToday) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(last.mood.coachResponse),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NotQuitterCard extends ConsumerWidget {
  const _NotQuitterCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resisted = ref.watch(resistedCountProvider);
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Text('💪', style: TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Il tuo lato not-quitter',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    resisted == 0
                        ? 'Ogni volta che resti nel piano nei momenti difficili, '
                            'lo segnerò qui. Costruiamo insieme la tua costanza.'
                        : 'Hai attraversato $resisted ${resisted == 1 ? 'momento difficile' : 'momenti difficili'} '
                            'senza mollare. Questa è la qualità che fa la differenza nel lungo periodo.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.lightbulb_outline,
                color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pillola del giorno',
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 4),
                  Text(BehaviorTips.ofToday()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Coaching adattivo: il messaggio si adatta al profilo di rischio del piano.
class _AdaptiveCard extends ConsumerWidget {
  const _AdaptiveCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(planControllerProvider).asData?.value;
    if (plan == null) return const SizedBox.shrink();
    final msg = switch (plan.riskProfile) {
      RiskProfile.prudent =>
        'Hai scelto un profilo prudente: oscillazioni piccole, crescita più '
            'lenta. Se vedi un calo, ricorda che è proprio ciò che hai accettato '
            'di rischiare poco — niente panico.',
      RiskProfile.balanced =>
        'Profilo equilibrato: un buon compromesso. In un anno storto puoi vedere '
            '-15/-20%: è normale, fa parte del patto. Resta sul piano.',
      RiskProfile.aggressive =>
        'Profilo aggressivo: punti in alto e accetti forti oscillazioni. Nei cali '
            'profondi ti servirà sangue freddo — sono qui per ricordartelo: chi '
            'resta investito, storicamente, viene premiato.',
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        color: Theme.of(context).colorScheme.secondaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.tips_and_updates_outlined),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Su misura per te (${plan.riskProfile.label})',
                        style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 4),
                    Text(msg),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
