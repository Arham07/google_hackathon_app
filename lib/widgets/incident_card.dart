import 'package:flutter/material.dart';
import 'package:google_hackathon_app/features/incidents/models/incident.dart';
import 'package:google_hackathon_app/theme/app_colors.dart';
import 'package:google_hackathon_app/theme/app_dimens.dart';
import 'package:google_hackathon_app/widgets/priority_chip.dart';
import 'package:intl/intl.dart';

class IncidentCard extends StatelessWidget {
  const IncidentCard({
    super.key,
    required this.incident,
    required this.onTap,
  });

  final Incident incident;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color borderColor = incident.isUserSubmitted
        ? AppColors.userSubmitted.withValues(alpha: 0.5)
        : AppColors.tacticalBorder;
    final Color bgColor = incident.isUserSubmitted
        ? AppColors.userSubmittedBg
        : AppColors.glassPanel;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimens.space16,
        vertical: AppDimens.space6,
      ),
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppDimens.radiusMd),
                  ),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: incident.thumbnailUrl != null
                        ? Image.network(
                            incident.thumbnailUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _placeholderImage(),
                          )
                        : _placeholderImage(),
                  ),
                ),
                Padding(
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
                              padding: EdgeInsets.symmetric(
                                horizontal: AppDimens.space8,
                                vertical: AppDimens.space4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.userSubmitted.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                                border: Border.all(
                                  color: AppColors.userSubmitted.withValues(alpha: 0.5),
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
                            ),
                        ],
                      ),
                      SizedBox(height: AppDimens.space10),
                      Text(
                        incident.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: AppDimens.space6),
                      Row(
                        children: [
                          Icon(
                            Icons.place_outlined,
                            size: AppDimens.iconXs,
                            color: AppColors.mutedForeground,
                          ),
                          SizedBox(width: AppDimens.space4),
                          Expanded(
                            child: Text(
                              incident.locationLabel,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.mutedForeground,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppDimens.space8),
                      Text(
                        incident.authenticity.label,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.chart2,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      SizedBox(height: AppDimens.space8),
                      Text(
                        DateFormat('dd MMM yyyy, HH:mm').format(incident.scanDatetime),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.mutedForeground,
                        ),
                      ),
                      SizedBox(height: AppDimens.space12),
                      Row(
                        children: [
                          OutlinedButton.icon(
                            onPressed: onTap,
                            icon: Icon(Icons.info_outline, size: AppDimens.iconMd),
                            label: const Text('Details'),
                          ),
                          SizedBox(width: AppDimens.space8),
                          FilledButton.tonalIcon(
                            onPressed: onTap,
                            icon: Icon(Icons.map_outlined, size: AppDimens.iconMd),
                            label: const Text('Map'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      color: AppColors.surfaceElevated,
      child: Center(
        child: Icon(
          Icons.flood_outlined,
          size: AppDimens.iconXl,
          color: AppColors.mutedForeground,
        ),
      ),
    );
  }
}
