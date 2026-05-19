import 'package:google_hackathon_app/features/notifications/data/mock_notifications.dart';
import 'package:google_hackathon_app/features/notifications/models/alert_notification.dart';

/// In-memory store for demo notification read state.
class NotificationsStore {
  NotificationsStore._();

  static final NotificationsStore instance = NotificationsStore._();

  final List<AlertNotification> items = createMockNotifications();

  int get unreadCount => items.where((AlertNotification n) => !n.isRead).length;

  void markRead(String id) {
    for (final AlertNotification n in items) {
      if (n.id == id) {
        n.isRead = true;
        return;
      }
    }
  }

  void markAllRead() {
    for (final AlertNotification n in items) {
      n.isRead = true;
    }
  }
}
