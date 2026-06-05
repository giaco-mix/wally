enum NotificationSeverity { info, warning }

/// Una notifica/avviso in-app generato da Wally a partire dallo stato attuale.
class WallyNotification {
  const WallyNotification({
    required this.id,
    required this.title,
    required this.body,
    this.severity = NotificationSeverity.info,
    this.route,
    this.actionLabel,
  });

  final String id;
  final String title;
  final String body;
  final NotificationSeverity severity;
  final String? route;
  final String? actionLabel;
}
