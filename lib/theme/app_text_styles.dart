import 'package:flutter/material.dart';
import 'package:google_hackathon_app/theme/app_colors.dart';

/// CIRO Alerts typography tokens (Material 3–aligned).
abstract final class AppTextStyles {
  static const TextStyle alertsTitle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
  );

  static const TextStyle incidentTitle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    height: 1.35,
  );

  static const TextStyle bodySecondary = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 14,
    height: 1.4,
  );

  static const TextStyle metricLabel = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 12,
    height: 1.3,
  );

  static const TextStyle metricValue = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle authorityLabel = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );

  static const TextStyle mapLink = TextStyle(
    color: AppColors.mapAccent,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle activeBadge = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.6,
  );
}
