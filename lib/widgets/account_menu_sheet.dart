import 'package:flutter/material.dart';
import 'package:google_hackathon_app/core/auth_service.dart';
import 'package:google_hackathon_app/theme/app_colors.dart';
import 'package:google_hackathon_app/theme/app_dimens.dart';
import 'package:google_hackathon_app/theme/app_text_styles.dart';

/// Account bottom sheet — sign out lives here instead of the app bar.
Future<void> showAccountMenuSheet(
  BuildContext context, {
  required VoidCallback onLogout,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.radiusXl)),
    ),
    builder: (BuildContext context) {
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppDimens.space20,
            AppDimens.space12,
            AppDimens.space20,
            AppDimens.space20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.glassBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: AppDimens.space20),
              CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.surfaceElevated,
                child: Icon(
                  Icons.person_outline,
                  size: AppDimens.iconXl,
                  color: AppColors.mapAccent,
                ),
              ),
              SizedBox(height: AppDimens.space12),
              Text('CIRO Alerts', style: AppTextStyles.sectionTitle),
              SizedBox(height: AppDimens.space4),
              Text(
                'Signed in — demo session',
                style: AppTextStyles.bodyMuted,
              ),
              SizedBox(height: AppDimens.space24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await AuthService().logout();
                    onLogout();
                  },
                  icon: const Icon(Icons.logout, size: 20),
                  label: const Text('Sign out'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.destructive,
                    side: BorderSide(color: AppColors.destructive.withValues(alpha: 0.5)),
                    padding: EdgeInsets.symmetric(vertical: AppDimens.space14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
