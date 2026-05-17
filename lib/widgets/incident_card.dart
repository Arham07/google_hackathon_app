import 'package:flutter/material.dart';
import 'package:google_hackathon_app/features/incidents/models/mock_incident.dart';
import 'package:google_hackathon_app/theme/app_colors.dart';
import 'package:google_hackathon_app/widgets/priority_chip.dart';
import 'package:intl/intl.dart';

class IncidentCard extends StatelessWidget {
  const IncidentCard({
    super.key,
    required this.incident,
    required this.onTap,
  });

  final MockIncident incident;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color borderColor = incident.isUserSubmitted
        ? AppColors.userSubmitted.withValues(alpha: 0.5)
        : AppColors.border;
    final Color bgColor = incident.isUserSubmitted
        ? AppColors.userSubmittedBg
        : AppColors.secondary.withValues(alpha: 0.5);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppColors.radius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppColors.radius),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppColors.radius),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppColors.radius),
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
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          PriorityChip(priority: incident.priority),
                          const SizedBox(width: 8),
                          if (incident.isUserSubmitted)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.userSubmitted.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: AppColors.userSubmitted.withValues(alpha: 0.5),
                                ),
                              ),
                              child: const Text(
                                'Citizen report',
                                style: TextStyle(
                                  color: AppColors.userSubmitted,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        incident.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.place_outlined,
                            size: 14,
                            color: AppColors.mutedForeground,
                          ),
                          const SizedBox(width: 4),
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
                      const SizedBox(height: 8),
                      Text(
                        incident.authenticity.label,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.chart2,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        DateFormat('dd MMM yyyy, HH:mm').format(incident.scanDatetime),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.mutedForeground,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          OutlinedButton.icon(
                            onPressed: onTap,
                            icon: const Icon(Icons.info_outline, size: 18),
                            label: const Text('Details'),
                          ),
                          const SizedBox(width: 8),
                          FilledButton.tonalIcon(
                            onPressed: onTap,
                            icon: const Icon(Icons.map_outlined, size: 18),
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
      color: AppColors.secondary,
      child: const Center(
        child: Icon(
          Icons.flood_outlined,
          size: 48,
          color: AppColors.mutedForeground,
        ),
      ),
    );
  }
}
