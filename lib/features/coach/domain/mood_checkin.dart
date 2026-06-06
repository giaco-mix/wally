import 'mood.dart';

/// Un check-in dello stato d'animo registrato dall'utente.
class MoodCheckin {
  const MoodCheckin({required this.mood, required this.createdAt, this.id});

  final String? id;
  final Mood mood;
  final DateTime createdAt;

  factory MoodCheckin.fromMap(Map<String, dynamic> map) {
    return MoodCheckin(
      id: map['id']?.toString(),
      mood: Mood.fromName(map['mood'] as String?),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
