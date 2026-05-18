import 'package:flutter/material.dart';
import 'package:google_hackathon_app/theme/app_colors.dart';

enum IncidentPriority { critical, high, medium, low, unknown }

extension IncidentPriorityX on IncidentPriority {
  String get label {
    switch (this) {
      case IncidentPriority.critical:
        return 'CRITICAL';
      case IncidentPriority.high:
        return 'HIGH';
      case IncidentPriority.medium:
        return 'MEDIUM';
      case IncidentPriority.low:
        return 'LOW';
      case IncidentPriority.unknown:
        return 'UNKNOWN';
    }
  }

  /// Pill label on incident cards (e.g. "High Priority").
  String get badgeLabel {
    switch (this) {
      case IncidentPriority.critical:
        return 'Critical';
      case IncidentPriority.high:
        return 'High Priority';
      case IncidentPriority.medium:
        return 'Medium';
      case IncidentPriority.low:
        return 'Low';
      case IncidentPriority.unknown:
        return 'Unknown';
    }
  }

  Color get color {
    switch (this) {
      case IncidentPriority.critical:
        return AppColors.priorityCritical;
      case IncidentPriority.high:
        return AppColors.priorityHigh;
      case IncidentPriority.medium:
        return AppColors.priorityMedium;
      case IncidentPriority.low:
        return AppColors.priorityLow;
      case IncidentPriority.unknown:
        return AppColors.mutedForeground;
    }
  }

  Color get borderColor {
    switch (this) {
      case IncidentPriority.critical:
        return AppColors.priorityCriticalBorder;
      case IncidentPriority.high:
        return AppColors.priorityHighBorder;
      case IncidentPriority.medium:
        return AppColors.priorityMediumBorder;
      case IncidentPriority.low:
        return AppColors.priorityLowBorder;
      case IncidentPriority.unknown:
        return AppColors.glassBorder;
    }
  }

  Color get backgroundColor => color.withValues(alpha: 0.12);

  static IncidentPriority fromString(String? value) {
    switch (value?.toUpperCase()) {
      case 'CRITICAL':
        return IncidentPriority.critical;
      case 'HIGH':
        return IncidentPriority.high;
      case 'MEDIUM':
        return IncidentPriority.medium;
      case 'LOW':
        return IncidentPriority.low;
      default:
        return IncidentPriority.unknown;
    }
  }
}
