import 'package:flutter/material.dart';
import 'package:google_hackathon_app/theme/app_dimens.dart';
import 'package:google_hackathon_app/theme/priority_styles.dart';

/// Bordered severity filter chip (CRITICAL / HIGH / MEDIUM / LOW).
class SeverityFilterChip extends StatelessWidget {
  const SeverityFilterChip({
    super.key,
    required this.priority,
    required this.selected,
    required this.onSelected,
  });

  final IncidentPriority priority;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(
        priority.label,
        style: TextStyle(
          color: priority.color,
          fontWeight: FontWeight.w700,
          fontSize: AppDimens.font11,
          letterSpacing: 0.4,
        ),
      ),
      selected: selected,
      onSelected: onSelected,
      showCheckmark: false,
      backgroundColor: Colors.transparent,
      selectedColor: priority.color.withValues(alpha: 0.14),
      side: BorderSide(
        color: priority.borderColor,
        width: 1.5,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
      ),
      padding: EdgeInsets.symmetric(horizontal: AppDimens.space4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}
