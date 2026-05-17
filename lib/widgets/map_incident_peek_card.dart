import 'package:flutter/material.dart';
import 'package:google_hackathon_app/features/incidents/models/incident.dart';
import 'package:google_hackathon_app/theme/app_colors.dart';
import 'package:google_hackathon_app/theme/app_dimens.dart';
import 'package:google_hackathon_app/theme/app_liquid_glass.dart';
import 'package:google_hackathon_app/widgets/ciro_liquid_glass.dart';
import 'package:google_hackathon_app/widgets/priority_chip.dart';
import 'package:intl/intl.dart';

/// Glass summary anchored near the bottom of the map when a pin is selected.
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
    return CiroLiquidGlassCard(
      borderRadius: AppDimens.radiusMd,
      settings: AppLiquidGlass.peek,
      onTap: onSeeDetails,
      padding: EdgeInsets.fromLTRB(
        AppDimens.space14,
        AppDimens.space10,
        AppDimens.space8,
        AppDimens.space12,
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
    );
  }
}
