import 'package:flutter/material.dart';

/// Banner riutilizzabile col disclaimer educativo.
///
/// Va mostrato ovunque si presentino dati di mercato, proiezioni o "mosse"
/// (dashboard, piano, ribilanciamento, coach, analisi). Tiene Wally nel
/// perimetro **educational / portafogli-modello**, non consulenza
/// personalizzata (MiFID II / CONSOB).
class DisclaimerBanner extends StatelessWidget {
  const DisclaimerBanner({super.key, this.margin});

  /// Margine esterno opzionale (utile nelle liste per spaziare dalla card sopra).
  final EdgeInsetsGeometry? margin;

  /// Testo unico, riusato anche dalla versione compatta, così resta una sola
  /// fonte di verità del wording legale.
  static const String message =
      'Informazioni a scopo educativo, non costituiscono consulenza '
      'finanziaria.';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Card(
        color: scheme.surfaceContainerHighest,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                size: 18,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Variante compatta (solo testo) per footer in coda alle liste già dense.
class DisclaimerText extends StatelessWidget {
  const DisclaimerText({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Text(
      DisclaimerBanner.message,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
    );
  }
}
