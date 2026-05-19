import 'package:flutter/material.dart';
import 'package:google_hackathon_app/features/incidents/incidents_controller.dart';
import 'package:google_hackathon_app/theme/app_colors.dart';
import 'package:google_hackathon_app/theme/app_dimens.dart';
import 'package:google_hackathon_app/theme/app_text_styles.dart';

/// Fluid Nearby / Priority / All switcher for BaKhabarAlerts.
class AlertsModeSelector extends StatelessWidget {
  const AlertsModeSelector({
    super.key,
    required this.mode,
    required this.onModeChanged,
  });

  final IncidentListMode mode;
  final ValueChanged<IncidentListMode> onModeChanged;

  static const List<({IncidentListMode value, String label, IconData icon})> _options =
      <({IncidentListMode value, String label, IconData icon})>[
    (value: IncidentListMode.nearby, label: 'Nearby', icon: Icons.near_me_outlined),
    (value: IncidentListMode.priority, label: 'Priority', icon: Icons.priority_high),
    (value: IncidentListMode.all, label: 'All', icon: Icons.list),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppDimens.space4),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      ),
      child: Row(
        children: _options.map((({IncidentListMode value, String label, IconData icon}) option) {
          final bool selected = mode == option.value;
          return Expanded(
            child: _ModeSegment(
              label: option.label,
              icon: option.icon,
              selected: selected,
              onTap: () => onModeChanged(option.value),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ModeSegment extends StatelessWidget {
  const _ModeSegment({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.filterSelected : Colors.transparent,
      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: AppDimens.space10,
            horizontal: AppDimens.space6,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (selected) ...<Widget>[
                Icon(Icons.check_rounded, size: AppDimens.iconSm, color: AppColors.mapAccent),
                SizedBox(width: AppDimens.space4),
              ],
              Icon(
                icon,
                size: AppDimens.iconSm,
                color: selected ? AppColors.textPrimary : AppColors.textSecondary,
              ),
              SizedBox(width: AppDimens.space4),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.segmentLabel.copyWith(
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    color: selected ? AppColors.textPrimary : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
