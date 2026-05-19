import 'package:flutter/material.dart';
import 'package:google_hackathon_app/theme/app_colors.dart';

/// BaKhabarAlerts typography — single scale for the whole app.
///
/// Hierarchy (px): screen title 20 → detail title 17 → body 14 → secondary 12.5 → caption 11.
abstract final class AppTextStyles {
  // — App chrome —
  static const TextStyle alertsTitle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.25,
  );

  static const TextStyle navLabel = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );

  static const TextStyle navLabelSelected = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  // — Auth / onboarding —
  static const TextStyle screenTitle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    height: 1.3,
  );

  static const TextStyle screenSubtitle = TextStyle(
    color: AppColors.mutedForeground,
    fontSize: 13,
    height: 1.45,
  );

  // — General content —
  static const TextStyle body = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 14,
    height: 1.45,
  );

  static const TextStyle bodySecondary = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 12.5,
    height: 1.35,
  );

  static const TextStyle bodyMuted = TextStyle(
    color: AppColors.mutedForeground,
    fontSize: 12.5,
    height: 1.35,
  );

  static const TextStyle emptyState = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 13,
    height: 1.4,
  );

  static const TextStyle caption = TextStyle(
    color: AppColors.mutedForeground,
    fontSize: 11,
    height: 1.3,
  );

  static const TextStyle captionSmall = TextStyle(
    color: AppColors.mutedForeground,
    fontSize: 11.5,
    height: 1.3,
  );

  // — Detail & sections —
  static const TextStyle detailTitle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 17,
    fontWeight: FontWeight.bold,
    height: 1.3,
  );

  static const TextStyle sectionTitle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 13.5,
    fontWeight: FontWeight.w600,
    height: 1.25,
  );

  static const TextStyle sectionBody = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 13,
    height: 1.4,
  );

  static const TextStyle sectionBodyMuted = TextStyle(
    color: AppColors.mutedForeground,
    fontSize: 13,
    height: 1.4,
    fontStyle: FontStyle.italic,
  );

  static const TextStyle accentMeta = TextStyle(
    color: AppColors.mapAccent,
    fontSize: 11.5,
    height: 1.3,
    fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
  );

  static const TextStyle authenticity = TextStyle(
    color: AppColors.chart2,
    fontSize: 11,
    fontStyle: FontStyle.italic,
    height: 1.25,
  );

  static const TextStyle tag = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );

  static const TextStyle newsHeadline = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 13.5,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  static const TextStyle newsHeadlineLink = TextStyle(
    color: AppColors.mapAccent,
    fontSize: 13.5,
    fontWeight: FontWeight.w600,
    height: 1.35,
    decoration: TextDecoration.underline,
    decorationColor: AppColors.mapAccent,
  );

  static const TextStyle newsDate = TextStyle(
    color: AppColors.mutedForeground,
    fontSize: 11,
    height: 1.25,
  );

  static const TextStyle mono = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 12.5,
    height: 1.3,
    fontFamily: 'monospace',
  );

  // — Stats & metrics —
  static const TextStyle statValue = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 22,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );

  static const TextStyle statLabel = TextStyle(
    color: AppColors.mutedForeground,
    fontSize: 12,
    height: 1.3,
  );

  static const TextStyle chartAxis = TextStyle(
    color: AppColors.mutedForeground,
    fontSize: 10,
    height: 1.2,
  );

  // — List cards & chips —
  static const TextStyle incidentTitle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 14,
    fontWeight: FontWeight.bold,
    height: 1.25,
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

  static const TextStyle segmentLabel = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const TextStyle authorityLabel = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );

  static const TextStyle mapLink = TextStyle(
    color: AppColors.mapAccent,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const TextStyle activeBadge = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.6,
    height: 1.2,
  );

  static const TextStyle peekTitle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  static const TextStyle riskHighlight = TextStyle(
    color: Color(0xFFFCA5A5),
    fontSize: 10,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );
}

/// Compact incident list card typography.
abstract final class CompactCardTextStyles {
  static const TextStyle incidentTitle = AppTextStyles.incidentTitle;
  static const TextStyle bodySecondary = AppTextStyles.bodySecondary;
  static const TextStyle mapLink = AppTextStyles.mapLink;
}

/// Incident detail screen — aliases to the shared scale.
abstract final class DetailTextStyles {
  static const TextStyle title = AppTextStyles.detailTitle;
  static const TextStyle summary = AppTextStyles.body;
  static const TextStyle meta = AppTextStyles.bodyMuted;
  static const TextStyle metaSmall = AppTextStyles.captionSmall;
  static const TextStyle accentMeta = AppTextStyles.accentMeta;
  static const TextStyle authenticity = AppTextStyles.authenticity;
  static const TextStyle sectionTitle = AppTextStyles.sectionTitle;
  static const TextStyle sectionBody = AppTextStyles.sectionBody;
  static const TextStyle sectionBodyMuted = AppTextStyles.sectionBodyMuted;
  static const TextStyle tag = AppTextStyles.tag;
  static const TextStyle newsHeadline = AppTextStyles.newsHeadline;
  static const TextStyle newsHeadlineLink = AppTextStyles.newsHeadlineLink;
  static const TextStyle newsDate = AppTextStyles.newsDate;
}
