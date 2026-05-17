import 'package:flutter/material.dart';

/// Tactical dark theme aligned with [ciro-main/src/app/globals.css].
/// Zinc-950 surfaces, brand accent (#000035), glass panels.
abstract final class AppColors {
  // Core surfaces — oklch(0.145 0 0) ≈ zinc-950 (#09090b)
  static final Color background = const Color(0xFF212121);
  static const Color foreground = Color(0xFFFAFAFA);
  static const Color card = Color(0xFF09090B);
  static const Color cardForeground = Color(0xFFFAFAFA);

  /// Elevated panels (zinc-900, tactical scrollbar track).
  static const Color surfaceElevated = Color(0xFF18181B);

  /// glass-panel utility — rgba(9, 9, 11, 0.6)
  static const Color glassPanel = Color(0x9909090B);

  static const Color primary = Color(0xFFE4E4E7);
  static const Color primaryForeground = Color(0xFF18181B);

  static const Color secondary = Color(0xFF27272A);
  static const Color secondaryForeground = Color(0xFFFAFAFA);

  static const Color muted = Color(0xFF27272A);
  static const Color mutedForeground = Color(0xFFA1A1AA);

  static const Color accent = Color(0xFF27272A);
  static const Color accentForeground = Color(0xFFFAFAFA);

  static const Color destructive = Color(0xFFF87171);
  static const Color border = Color(0x1AFFFFFF);
  static const Color input = Color(0x26FFFFFF);
  static const Color ring = Color(0xFF71717A);

  /// glass-panel border — white/8%
  static const Color tacticalBorder = Color(0x14FFFFFF);

  // Charts (oklch chart-* from globals.css)
  static const Color chart1 = Color(0xFF6366F1);
  static const Color chart2 = Color(0xFF34D399);
  static const Color chart3 = Color(0xFFFBBF24);
  static const Color chart4 = Color(0xFFC084FC);
  static const Color chart5 = Color(0xFFFB923C);

  // Priority (SignalFeed)
  static const Color priorityCritical = Color(0xFFEF4444);
  static const Color priorityHigh = Color(0xFFF97316);
  static const Color priorityMedium = Color(0xFFEAB308);
  static const Color priorityLow = Color(0xFF10B981);

  static const Color userSubmitted = Color(0xFFA78BFA);
  static const Color userSubmittedBg = Color(0x402C1D4D);

  /// Map / links / focus — brand navy (replaces prior blue accent).
  static const Color mapAccent = Color(0xFF000035);

  /// Use [AppDimens.radiusMd] in widgets; kept for const chart borders etc.
  static const double radius = 10;
}
