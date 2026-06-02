import 'package:flutter/material.dart';

/// Obiettivo di vita che motiva il piano d'investimento.
enum GoalType {
  house('Comprare casa', Icons.home_outlined),
  independence('Indipendenza finanziaria', Icons.self_improvement),
  income('Creare una rendita', Icons.savings_outlined),
  wealth('Far crescere il patrimonio', Icons.trending_up),
  education('Studi / figli', Icons.school_outlined),
  other('Un altro obiettivo', Icons.flag_outlined);

  const GoalType(this.label, this.icon);
  final String label;
  final IconData icon;

  static GoalType fromName(String? name) => GoalType.values.firstWhere(
        (g) => g.name == name,
        orElse: () => GoalType.other,
      );
}
