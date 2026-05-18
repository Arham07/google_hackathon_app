import 'package:flutter/material.dart';
import 'package:google_hackathon_app/theme/app_colors.dart';
import 'package:google_hackathon_app/theme/app_dimens.dart';

/// Bottom navigation with navy pill highlight for the active tab.
class CiroBottomNav extends StatelessWidget {
  const CiroBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
    required this.destinations,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final List<({IconData icon, IconData selectedIcon, String label})> destinations;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.glassBorder)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimens.space8,
            vertical: AppDimens.space8,
          ),
          child: Row(
            children: List<Widget>.generate(destinations.length, (int index) {
              final bool selected = index == selectedIndex;
              final ({IconData icon, IconData selectedIcon, String label}) dest =
                  destinations[index];
              return Expanded(
                child: _NavItem(
                  icon: selected ? dest.selectedIcon : dest.icon,
                  label: dest.label,
                  selected: selected,
                  onTap: () => onSelected(index),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(
            vertical: AppDimens.space8,
            horizontal: AppDimens.space4,
          ),
          decoration: BoxDecoration(
            color: selected ? AppColors.filterSelected : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                icon,
                size: AppDimens.iconMd,
                color: selected ? AppColors.textPrimary : AppColors.textSecondary,
              ),
              SizedBox(height: AppDimens.space4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: AppDimens.font10,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected ? AppColors.textPrimary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
