import 'package:flutter/material.dart';

/// BaKhabardark tactical palette — deep charcoal navy (no pure black).
abstract final class AppColors {
  // Surfaces
  static const Color background = Color(0xFF121822);
  static const Color surface = Color(0xFF1E2733);
  static const Color surfaceElevated = Color(0xFF2E3A4D);
  static const Color filterSelected = Color(0xFF1A2430);

  // Text
  static const Color textPrimary = Color(0xFFF0F0F0);
  static const Color textSecondary = Color(0xFFB0BBC6);

  /// Legacy aliases used across the app.
  static const Color foreground = textPrimary;
  static const Color mutedForeground = textSecondary;

  static const Color card = surface;
  static const Color cardForeground = textPrimary;

  static const Color glassPanel = surface;
  static const Color glassFill = Color(0x661E2733);
  static const Color glassFillStrong = surface;
  static const Color glassBorder = Color(0x33B0BBC6);
  static const Color glassBorderHighlight = Color(0x4DF0F0F0);
  static const Color tacticalBorder = glassBorder;

  static const Color authorityAccent = Color(0xFFFFCC00);

  static const Color primary = textPrimary;
  static const Color primaryForeground = background;

  static const Color secondary = surfaceElevated;
  static const Color secondaryForeground = textPrimary;

  static const Color muted = surfaceElevated;
  static const Color accent = filterSelected;
  static const Color accentForeground = textPrimary;

  static const Color destructive = Color(0xFFFF4444);
  static const Color border = glassBorder;
  static const Color input = Color(0x332E3A4D);
  static const Color ring = textSecondary;

  // Charts
  static const Color chart1 = Color(0xFF5B7FD4);
  static const Color chart2 = Color(0xFF44CC44);
  static const Color chart3 = Color(0xFFFFD700);
  static const Color chart4 = Color(0xFFC084FC);
  static const Color chart5 = Color(0xFFFF9933);

  // Severity (primary + border)
  static const Color priorityCritical = Color(0xFFFF4444);
  static const Color priorityCriticalBorder = Color(0xFFA16666);

  static const Color priorityHigh = Color(0xFFFF9933);
  static const Color priorityHighBorder = Color(0xFFA67C55);

  static const Color priorityMedium = Color(0xFFFFD700);
  static const Color priorityMediumBorder = Color(0xFF998B55);

  static const Color priorityLow = Color(0xFF44CC44);
  static const Color priorityLowBorder = Color(0xFF66A166);

  static const Color userSubmitted = Color(0xFFA78BFA);
  static const Color userSubmittedBg = Color(0x402E3A4D);

  static const Color mapAccent = Color(0xFF7EB6FF);

  static const double radius = 10;
}
