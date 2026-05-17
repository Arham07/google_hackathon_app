import 'package:flutter/material.dart';
import 'package:google_hackathon_app/theme/app_colors.dart';
import 'package:google_hackathon_app/theme/app_liquid_glass.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

/// Full liquid glass (single shape + own layer). Use sparingly — map peek, chips.
class CiroLiquidGlassCard extends StatelessWidget {
  const CiroLiquidGlassCard({
    super.key,
    required this.child,
    this.borderRadius = AppLiquidGlass.peekRadius,
    this.settings,
    this.padding,
    this.onTap,
  });

  final Widget child;
  final double borderRadius;
  final LiquidGlassSettings? settings;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Widget content = padding != null ? Padding(padding: padding!, child: child) : child;

    Widget glass = LiquidGlass.withOwnLayer(
      settings: settings ?? AppLiquidGlass.peek,
      shape: LiquidRoundedSuperellipse(borderRadius: borderRadius),
      child: content,
    );

    if (onTap != null) {
      glass = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: glass,
        ),
      );
    }

    return glass;
  }
}

/// Lightweight fake glass — lists, sections, search bar (many instances).
class CiroFakeGlassCard extends StatelessWidget {
  const CiroFakeGlassCard({
    super.key,
    required this.child,
    this.borderRadius = AppLiquidGlass.cardRadius,
    this.settings,
    this.padding,
    this.margin,
    this.border,
  });

  final Widget child;
  final double borderRadius;
  final LiquidGlassSettings? settings;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    final Widget inner = padding != null ? Padding(padding: padding!, child: child) : child;

    Widget card = FakeGlass(
      shape: LiquidRoundedSuperellipse(borderRadius: borderRadius),
      settings: settings ?? AppLiquidGlass.listTile,
      child: inner,
    );

    if (border != null) {
      card = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          border: border,
        ),
        child: card,
      );
    }

    if (margin != null) {
      return Padding(padding: margin!, child: card);
    }
    return card;
  }
}

/// Palette-only glass when shaders are unavailable or for zero-cost rows.
class CiroGlassDecoration extends BoxDecoration {
  CiroGlassDecoration({
    double borderRadius = AppLiquidGlass.cardRadius,
    bool strong = false,
    Color? borderColor,
  }) : super(
          color: strong ? AppColors.glassFillStrong : AppColors.glassFill,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: borderColor ?? AppColors.glassBorder),
        );
}
