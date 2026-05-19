import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_hackathon_app/features/notifications/models/alert_notification.dart';
import 'package:google_hackathon_app/features/notifications/notifications_store.dart';
import 'package:google_hackathon_app/theme/app_colors.dart';
import 'package:google_hackathon_app/theme/app_dimens.dart';
import 'package:google_hackathon_app/theme/app_text_styles.dart';
import 'package:google_hackathon_app/theme/priority_styles.dart';
import 'package:google_hackathon_app/widgets/priority_chip.dart';
import 'package:intl/intl.dart';

class NotificationDetailScreen extends StatefulWidget {
  const NotificationDetailScreen({super.key, required this.notification});

  final AlertNotification notification;

  @override
  State<NotificationDetailScreen> createState() => _NotificationDetailScreenState();
}

class _NotificationDetailScreenState extends State<NotificationDetailScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    NotificationsStore.instance.markRead(widget.notification.id);

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.15, 1, curve: Curves.easeOut),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    ));
    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AlertNotification n = widget.notification;
    final IncidentPriority priority = n.priority;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            stretch: true,
            backgroundColor: AppColors.background,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const <StretchMode>[
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
              background: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: n.headerGradient,
                      ),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          Colors.transparent,
                          AppColors.background.withValues(alpha: 0.92),
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: Icon(
                      n.categoryIcon,
                      size: 64,
                      color: priority.color.withValues(alpha: 0.85),
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.paddingOf(context).top + AppDimens.space8,
                    right: AppDimens.space8,
                    child: Container(
                      padding: EdgeInsets.all(AppDimens.space10),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withValues(alpha: 0.75),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      child: Icon(n.categoryIcon, color: priority.color, size: 22),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppDimens.space16,
                    AppDimens.space8,
                    AppDimens.space16,
                    AppDimens.space32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Hero(
                        tag: 'notification-title-${n.id}',
                        child: Material(
                          color: Colors.transparent,
                          child: Text(
                            n.title,
                            style: AppTextStyles.detailTitle.copyWith(fontSize: 18),
                          ),
                        ),
                      ),
                      SizedBox(height: AppDimens.space12),
                      Wrap(
                        spacing: AppDimens.space8,
                        runSpacing: AppDimens.space8,
                        children: <Widget>[
                          PriorityChip(priority: priority),
                          if (n.isCitizenReport) _CitizenTag(),
                        ],
                      ),
                      SizedBox(height: AppDimens.space16),
                      _MetaRow(
                        icon: Icons.calendar_today_outlined,
                        label: DateFormat('dd MMM yyyy, hh:mm a').format(n.timestamp),
                      ),
                      SizedBox(height: AppDimens.space8),
                      _MetaRow(
                        icon: Icons.schedule_outlined,
                        label: n.relativeTime,
                        valueStyle: AppTextStyles.riskHighlight,
                      ),
                      SizedBox(height: AppDimens.space8),
                      _MetaRow(
                        icon: Icons.location_on_outlined,
                        label: n.location,
                      ),
                      SizedBox(height: AppDimens.space24),
                      Text('Summary', style: AppTextStyles.sectionTitle),
                      SizedBox(height: AppDimens.space8),
                      Text(n.body, style: AppTextStyles.sectionBody),
                      SizedBox(height: AppDimens.space24),
                      _ActionPanel(
                        onViewOnMap: () {
                          HapticFeedback.lightImpact();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: AppColors.surfaceElevated,
                              content: Text(
                                'Map focus coming soon — demo notification.',
                                style: AppTextStyles.bodySecondary,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.icon,
    required this.label,
    this.valueStyle,
  });

  final IconData icon;
  final String label;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, size: AppDimens.iconSm, color: AppColors.textSecondary),
        SizedBox(width: AppDimens.space8),
        Expanded(
          child: Text(
            label,
            style: valueStyle ?? AppTextStyles.bodySecondary,
          ),
        ),
      ],
    );
  }
}

class _CitizenTag extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimens.space10,
        vertical: AppDimens.space6,
      ),
      decoration: BoxDecoration(
        color: AppColors.userSubmitted.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
        border: Border.all(color: AppColors.userSubmitted.withValues(alpha: 0.45)),
      ),
      child: Text(
        'Citizen report',
        style: TextStyle(
          color: AppColors.userSubmitted,
          fontSize: AppDimens.font10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ActionPanel extends StatelessWidget {
  const _ActionPanel({required this.onViewOnMap});

  final VoidCallback onViewOnMap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppDimens.space16),
      decoration: BoxDecoration(
        color: AppColors.glassPanel,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          FilledButton.icon(
            onPressed: onViewOnMap,
            icon: const Icon(Icons.map_outlined, size: 20),
            label: const Text('Show on map'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.mapAccent.withValues(alpha: 0.22),
              foregroundColor: AppColors.mapAccent,
              padding: EdgeInsets.symmetric(vertical: AppDimens.space14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              ),
            ),
          ),
          SizedBox(height: AppDimens.space10),
          OutlinedButton.icon(
            onPressed: () {
              HapticFeedback.selectionClick();
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back, size: 18),
            label: const Text('Back to alerts'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: const BorderSide(color: AppColors.glassBorder),
              padding: EdgeInsets.symmetric(vertical: AppDimens.space12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
