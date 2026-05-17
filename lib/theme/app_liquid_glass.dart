import 'package:flutter/material.dart';
import 'package:google_hackathon_app/theme/app_colors.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

/// Shared [LiquidGlassSettings] tuned to the #040814 palette.
abstract final class AppLiquidGlass {
  static const double peekRadius = 12;
  static const double cardRadius = 10;
  static const double chipRadius = 8;

  /// Map peek / hero overlays — moderate refraction over busy map.
  static const LiquidGlassSettings peek = LiquidGlassSettings(
    thickness: 14,
    blur: 12,
    glassColor: Color(0xB3040814),
    lightIntensity: 1.25,
    ambientStrength: 0.35,
    saturation: 1.08,
    refractiveIndex: 1.35,
  );

  /// List tiles, search chrome, nav — lightweight fake glass.
  static const LiquidGlassSettings listTile = LiquidGlassSettings(
    blur: 10,
    glassColor: AppColors.glassFill,
    lightIntensity: 1.0,
    ambientStrength: 0.3,
    thickness: 0,
  );

  static const LiquidGlassSettings navBar = LiquidGlassSettings(
    blur: 14,
    glassColor: Color(0xCC040814),
    lightIntensity: 0.9,
    thickness: 0,
  );

  static const LiquidGlassSettings section = LiquidGlassSettings(
    blur: 8,
    glassColor: AppColors.glassFillStrong,
    lightIntensity: 0.95,
    thickness: 0,
  );
}
