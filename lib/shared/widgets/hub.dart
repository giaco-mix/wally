import 'package:flutter/material.dart';

/// Intestazione di sezione riutilizzabile per gli hub (Account, Impara,
/// Portafoglio): titolo + breve "cosa trovi qui". Una sola fonte di stile, così
/// le schermate-hub si assomigliano tutte.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.blurb});

  final String title;
  final String? blurb;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8, left: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          if (blurb != null) ...[
            const SizedBox(height: 2),
            Text(
              blurb!,
              style: t.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }
}

/// Card-riga di navigazione uniforme (icona + titolo + sottotitolo + chevron).
/// Sostituisce le ListTile ripetute a mano nei vari hub.
class HubNavCard extends StatelessWidget {
  const HubNavCard({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: subtitle == null ? null : Text(subtitle!),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
