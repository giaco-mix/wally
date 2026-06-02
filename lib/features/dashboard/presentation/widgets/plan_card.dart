import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/format.dart';
import '../../../plan/providers/plan_providers.dart';

class PlanCard extends ConsumerWidget {
  const PlanCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planAsync = ref.watch(planControllerProvider);
    final scheme = Theme.of(context).colorScheme;

    return planAsync.maybeWhen(
      orElse: () => const SizedBox.shrink(),
      data: (plan) {
        if (plan == null) {
          // CTA: nessun piano ancora.
          return Card(
            color: scheme.primaryContainer,
            child: InkWell(
              onTap: () => context.go('/onboarding'),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.flag_outlined, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Crea il tuo piano',
                              style: Theme.of(context).textTheme.titleMedium),
                          const Text(
                              'Obiettivo + piano di accumulo in due minuti.'),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
          );
        }
        // Sintesi del piano esistente.
        return Card(
          child: InkWell(
            onTap: () => context.go('/plan'),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(plan.goalType.icon, size: 32, color: scheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(plan.goalLabel ?? plan.goalType.label,
                            style: Theme.of(context).textTheme.titleMedium),
                        Text(
                          '${Fmt.money(plan.monthlyContribution)}/mese · '
                          'obiettivo ~${Fmt.compactMoney(plan.projectedValue).replaceAll('\$', '')} '
                          'in ${plan.horizonYears} anni',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
