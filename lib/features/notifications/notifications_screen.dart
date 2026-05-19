import 'package:flutter/material.dart';
import 'package:google_hackathon_app/features/notifications/models/alert_notification.dart';
import 'package:google_hackathon_app/features/notifications/notification_detail_screen.dart';
import 'package:google_hackathon_app/features/notifications/notification_routes.dart';
import 'package:google_hackathon_app/features/notifications/notifications_store.dart';
import 'package:google_hackathon_app/features/notifications/widgets/notification_list_tile.dart';
import 'package:google_hackathon_app/theme/app_colors.dart';
import 'package:google_hackathon_app/theme/app_dimens.dart';
import 'package:google_hackathon_app/theme/app_text_styles.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationsStore _store = NotificationsStore.instance;

  Future<void> _openDetail(AlertNotification notification) async {
    await Navigator.of(context).push<void>(
      notificationFadeSlideRoute<void>(
        NotificationDetailScreen(notification: notification),
      ),
    );
    if (mounted) setState(() {});
  }

  void _markAllRead() {
    setState(_store.markAllRead);
  }

  @override
  Widget build(BuildContext context) {
    final List<AlertNotification> items = _store.items;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: <Widget>[
          if (_store.unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: Text(
                'Mark all read',
                style: AppTextStyles.mapLink.copyWith(fontSize: 12),
              ),
            ),
        ],
      ),
      body: items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.notifications_none_outlined,
                    size: AppDimens.iconXl,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(height: AppDimens.space16),
                  Text(
                    'No notifications yet',
                    style: AppTextStyles.emptyState,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.only(
                top: AppDimens.space8,
                bottom: AppDimens.space24,
              ),
              itemCount: items.length,
              itemBuilder: (BuildContext context, int index) {
                final AlertNotification notification = items[index];
                return NotificationListTile(
                  notification: notification,
                  onTap: () => _openDetail(notification),
                );
              },
            ),
    );
  }
}
