import 'package:flutter/material.dart';

/// Dark tactical theme anchored on **#040814** with glass-friendly tokens.
abstract final class AppColors {
  // Core surfaces (#040814 family)
  static const Color background = Color(0xFF040814);
  static const Color surface = Color(0xFF0A1224);
  static const Color surfaceElevated = Color(0xFF101C32);
  static const Color surfaceOverlay = Color(0xFF162240);

  static const Color foreground = Color(0xFFF4F4F5);
  static const Color card = surfaceElevated;
  static const Color cardForeground = foreground;

  /// Glass fills — use with [LiquidGlassSettings.glassColor] (ARGB alpha = strength).
  static const Color glassFill = Color(0x66040814);
  static const Color glassFillStrong = Color(0x99040814);

  /// Legacy alias for panels that predate liquid_glass_renderer wrappers.
  static const Color glassPanel = glassFillStrong;

  static const Color glassBorder = Color(0x1AFFFFFF);
  static const Color glassBorderHighlight = Color(0x33FFFFFF);

  /// Legacy alias.
  static const Color tacticalBorder = glassBorder;

  static const Color primary = Color(0xFFE4E4E7);
  static const Color primaryForeground = Color(0xFF101C32);

  static const Color secondary = Color(0xFF1A2844);
  static const Color secondaryForeground = foreground;

  static const Color muted = Color(0xFF1A2844);
  static const Color mutedForeground = Color(0xFF94A3B8);

  static const Color accent = Color(0xFF1E3054);
  static const Color accentForeground = foreground;

  static const Color destructive = Color(0xFFF87171);
  static const Color border = glassBorder;
  static const Color input = Color(0x26FFFFFF);
  static const Color ring = Color(0xFF64748B);

  // Charts
  static const Color chart1 = Color(0xFF5B7FD4);
  static const Color chart2 = Color(0xFF34D399);
  static const Color chart3 = Color(0xFFFBBF24);
  static const Color chart4 = Color(0xFFC084FC);
  static const Color chart5 = Color(0xFFFB923C);

  // Priority
  static const Color priorityCritical = Color(0xFFEF4444);
  static const Color priorityHigh = Color(0xFFF97316);
  static const Color priorityMedium = Color(0xFFEAB308);
  static const Color priorityLow = Color(0xFF10B981);

  static const Color userSubmitted = Color(0xFFA78BFA);
  static const Color userSubmittedBg = Color(0x402C1D4D);

  /// Links, map actions, focus rings — readable on #040814 surfaces.
  static const Color mapAccent = Color(0xFF60A5FA);

  static const double radius = 10;
}
