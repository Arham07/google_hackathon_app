import 'package:flutter/material.dart';
import 'package:google_hackathon_app/features/notifications/models/alert_notification.dart';
import 'package:google_hackathon_app/theme/app_colors.dart';
import 'package:google_hackathon_app/theme/app_dimens.dart';
import 'package:google_hackathon_app/theme/app_text_styles.dart';
import 'package:google_hackathon_app/theme/priority_styles.dart';
import 'package:google_hackathon_app/widgets/priority_chip.dart';
import 'package:intl/intl.dart';

class NotificationListTile extends StatefulWidget {
  const NotificationListTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  final AlertNotification notification;
  final VoidCallback onTap;

  @override
  State<NotificationListTile> createState() => _NotificationListTileState();
}

class _NotificationListTileState extends State<NotificationListTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _scale = Tween<double>(begin: 1, end: 0.985).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AlertNotification n = widget.notification;
    final IncidentPriority priority = n.priority;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      builder: (BuildContext context, double value, Widget? child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 14),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimens.space16,
          vertical: AppDimens.space6,
        ),
        child: ScaleTransition(
          scale: _scale,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              onHighlightChanged: (bool down) {
                if (down) {
                  _pressController.forward();
                } else {
                  _pressController.reverse();
                }
              },
              borderRadius: BorderRadius.circular(AppDimens.radiusLg),
              child: Ink(
                decoration: BoxDecoration(
                  color: n.isRead
                      ? AppColors.surface
                      : AppColors.surfaceElevated.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                  border: Border.all(
                    color: n.isRead
                        ? AppColors.glassBorder
                        : priority.borderColor.withValues(alpha: 0.45),
                  ),
                ),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Container(
                        width: 4,
                        decoration: BoxDecoration(
                          color: priority.color,
                          borderRadius: BorderRadius.horizontal(
                            left: Radius.circular(AppDimens.radiusLg),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(AppDimens.space12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  _CategoryIcon(
                                    icon: n.categoryIcon,
                                    color: priority.color,
                                  ),
                                  SizedBox(width: AppDimens.space10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: Text(
                                                n.title,
                                                style: AppTextStyles.incidentTitle.copyWith(
                                                  fontWeight: n.isRead
                                                      ? FontWeight.w600
                                                      : FontWeight.bold,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (!n.isRead) ...<Widget>[
                                              SizedBox(width: AppDimens.space8),
                                              Container(
                                                width: 8,
                                                height: 8,
                                                decoration: BoxDecoration(
                                                  color: AppColors.mapAccent,
                                                  shape: BoxShape.circle,
                                                  boxShadow: <BoxShadow>[
                                                    BoxShadow(
                                                      color: AppColors.mapAccent
                                                          .withValues(alpha: 0.5),
                                                      blurRadius: 6,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        SizedBox(height: AppDimens.space8),
                                        Wrap(
                                          spacing: AppDimens.space8,
                                          runSpacing: AppDimens.space6,
                                          crossAxisAlignment: WrapCrossAlignment.center,
                                          children: <Widget>[
                                            PriorityChip(priority: priority),
                                            if (n.isCitizenReport)
                                              const _CitizenReportTag(),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: AppDimens.space10),
                              Text(
                                DateFormat('dd MMM yyyy, hh:mm a').format(n.timestamp),
                                style: AppTextStyles.captionSmall,
                              ),
                              SizedBox(height: AppDimens.space8),
                              Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: AppDimens.iconSm,
                                    color: AppColors.textSecondary,
                                  ),
                                  SizedBox(width: AppDimens.space4),
                                  Expanded(
                                    child: Text(
                                      n.location,
                                      style: AppTextStyles.bodySecondary,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Icon(
                                    Icons.schedule_outlined,
                                    size: AppDimens.iconSm,
                                    color: const Color(0xFFFCA5A5),
                                  ),
                                  SizedBox(width: AppDimens.space4),
                                  Text(
                                    n.relativeTime,
                                    style: AppTextStyles.riskHighlight,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  const _CategoryIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppDimens.space8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Icon(icon, size: AppDimens.iconMd, color: color),
    );
  }
}

class _CitizenReportTag extends StatelessWidget {
  const _CitizenReportTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimens.space8,
        vertical: AppDimens.space4,
      ),
      decoration: BoxDecoration(
        color: AppColors.userSubmitted.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
        border: Border.all(
          color: AppColors.userSubmitted.withValues(alpha: 0.45),
        ),
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
