/// Un utente della piattaforma, come visto dall'amministratore (dai profili).
class AppUser {
  const AppUser({
    required this.id,
    required this.displayName,
    required this.role,
    this.createdAt,
  });

  final String id;
  final String displayName;
  final String role; // retail | advisor | client | admin
  final DateTime? createdAt;

  factory AppUser.fromMap(Map<String, dynamic> m) => AppUser(
        id: m['id'].toString(),
        displayName: (m['display_name'] as String?) ?? '—',
        role: (m['role'] as String?) ?? 'retail',
        createdAt: m['created_at'] == null
            ? null
            : DateTime.tryParse(m['created_at'] as String),
      );
}

const kUserRoles = ['retail', 'advisor', 'client', 'admin'];
