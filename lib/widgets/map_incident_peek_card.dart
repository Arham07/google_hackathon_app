import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_hackathon_app/features/incidents/models/incident.dart';
import 'package:google_hackathon_app/theme/app_colors.dart';
import 'package:google_hackathon_app/theme/app_dimens.dart';
import 'package:google_hackathon_app/widgets/priority_chip.dart';
import 'package:intl/intl.dart';

/// Frosted summary anchored near the bottom of the map when a pin is selected.
class MapIncidentPeekCard extends StatelessWidget {
  const MapIncidentPeekCard({
    super.key,
    required this.incident,
    required this.onSeeDetails,
    required this.onDismiss,
  });

  final Incident incident;
  final VoidCallback onSeeDetails;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Material(
          color: AppColors.glassPanel.withValues(alpha: 0.82),
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          child: InkWell(
            onTap: onSeeDetails,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                AppDimens.space14,
                AppDimens.space10,
                AppDimens.space8,
                AppDimens.space12,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                border: Border.all(color: AppColors.glassBorder.withValues(alpha: 0.85)),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(child: PriorityChip(priority: incident.priority)),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        tooltip: 'Dismiss',
                        onPressed: onDismiss,
                        icon: Icon(Icons.close, size: AppDimens.iconSm, color: AppColors.mutedForeground),
                      ),
                    ],
                  ),
                  Text(
                    incident.title,
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: AppDimens.space6),
                  Text(
                    incident.locationLabel,
                    style: theme.textTheme.bodySmall?.copyWith(color: AppColors.mutedForeground),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: AppDimens.space4),
                  Text(
                    DateFormat('dd MMM yyyy, HH:mm').format(incident.scanDatetime),
                    style: theme.textTheme.labelSmall?.copyWith(color: AppColors.mutedForeground),
                  ),
                  SizedBox(height: AppDimens.space8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: onSeeDetails,
                      style: TextButton.styleFrom(foregroundColor: AppColors.mapAccent),
                      child: const Text('See details'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
