import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_hackathon_app/config/app_assets.dart';
import 'package:google_hackathon_app/features/incidents/models/incident.dart';
import 'package:google_hackathon_app/theme/app_colors.dart';
import 'package:google_hackathon_app/theme/app_dimens.dart';
import 'package:google_hackathon_app/utils/incident_time_format.dart';
import 'package:google_hackathon_app/widgets/incident_live_beacon.dart';
import 'package:google_hackathon_app/widgets/priority_chip.dart';
import 'package:intl/intl.dart';

class IncidentCard extends StatelessWidget {
  const IncidentCard({super.key, required this.incident, required this.onTap, this.onOpenOnMap});

  final Incident incident;
  final VoidCallback onTap;
  final VoidCallback? onOpenOnMap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final DateTime now = DateTime.now();
    final bool isRecent = IncidentTimeFormat.isWithinLast24Hours(incident.scanDatetime, now);
    final Color borderColor = incident.isUserSubmitted ? AppColors.userSubmitted.withValues(alpha: 0.5) : AppColors.glassBorder;
    final Color bgColor = incident.isUserSubmitted ? AppColors.userSubmittedBg : AppColors.glassPanel;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppDimens.space16, vertical: AppDimens.space6),
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            border: Border.all(color: borderColor, width: isRecent ? 1.5 : 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.radiusMd)),
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.radiusMd)),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        Positioned.fill(
                          child: incident.thumbnailUrl != null
                              ? Image.network(
                                  incident.thumbnailUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) => _fallbackThumbnail(),
                                )
                              : _fallbackThumbnail(),
                        ),
                        if (isRecent)
                          Positioned(
                            top: AppDimens.space10,
                            right: AppDimens.space10,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: AppDimens.space8, vertical: AppDimens.space4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.52),
                                borderRadius: BorderRadius.circular(AppDimens.radiusSm + 4),
                                border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.45)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  const IncidentLiveBeacon(),
                                  SizedBox(width: AppDimens.space6),
                                  Text(
                                    'ACTIVE',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: const Color(0xFFFECACA),
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.6,
                                      fontSize: AppDimens.font10,
                                    ),
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
              InkWell(
                onTap: onTap,
                child: Padding(
                  padding: EdgeInsets.all(AppDimens.space14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          PriorityChip(priority: incident.priority),
                          SizedBox(width: AppDimens.space8),
                          if (incident.isUserSubmitted)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: AppDimens.space8, vertical: AppDimens.space4),
                              decoration: BoxDecoration(
                                color: AppColors.userSubmitted.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                                border: Border.all(color: AppColors.userSubmitted.withValues(alpha: 0.5)),
                              ),
                              child: Text(
                                'Citizen report',
                                style: TextStyle(color: AppColors.userSubmitted, fontSize: AppDimens.font10, fontWeight: FontWeight.w600),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: AppDimens.space10),
                      Text(
                        incident.title,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: AppDimens.space6),
                      Row(
                        children: [
                          Icon(Icons.place_outlined, size: AppDimens.iconXs, color: AppColors.mutedForeground),
                          SizedBox(width: AppDimens.space4),
                          Expanded(
                            child: Text(incident.locationLabel, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.mutedForeground)),
                          ),
                        ],
                      ),
                      SizedBox(height: AppDimens.space8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // LEFT SIDE
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(top: 0),
                                          child: Icon(
                                            Icons.schedule_outlined,
                                            size: AppDimens.iconXs,
                                            color: isRecent ? const Color(0xFFFCA5A5) : AppColors.mutedForeground,
                                          ),
                                        ),
                                        SizedBox(width: AppDimens.space4),
                                        Text(
                                          IncidentTimeFormat.relativeAge(incident.scanDatetime, now),
                                          style: theme.textTheme.labelSmall?.copyWith(
                                            color: isRecent ? const Color(0xFFFCA5A5) : AppColors.mutedForeground,
                                            fontWeight: isRecent ? FontWeight.w600 : FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(width: AppDimens.space4),
                                        SizedBox(width: AppDimens.space4),
                                        SizedBox(width: AppDimens.space4),
                                        SizedBox(width: AppDimens.space4),
                                        SizedBox(width: AppDimens.space4),
                                        Text(
                                          DateFormat('dd MMM yyyy, hh:mm a').format(incident.scanDatetime),
                                          style: theme.textTheme.labelSmall?.copyWith(
                                            color: AppColors.mutedForeground.withValues(alpha: 0.85),
                                            fontSize: AppDimens.font10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // RIGHT SIDE
                          if (onOpenOnMap != null && incident.hasMapCoordinates)
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: onOpenOnMap,
                                icon: Icon(Icons.map_outlined, size: AppDimens.iconSm, color: AppColors.mapAccent),
                                label: Text('Show on map', style: TextStyle(fontSize: 12.sp)),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.mapAccent,
                                  padding: EdgeInsets.zero,
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),
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
    );
  }

  Widget _fallbackThumbnail() {
    return Image.asset(
      AppAssets.incidentThumbnailPlaceholder,
      fit: BoxFit.cover,
      errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) => _iconPlaceholder(),
    );
  }

  Widget _iconPlaceholder() {
    return Container(
      color: AppColors.surfaceElevated,
      child: Center(
        child: Icon(Icons.flood_outlined, size: AppDimens.iconXl, color: AppColors.mutedForeground),
      ),
    );
  }
}
