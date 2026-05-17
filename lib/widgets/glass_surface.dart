import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_hackathon_app/theme/app_colors.dart';
import 'package:google_hackathon_app/theme/app_dimens.dart';

/// Default blur strengths for glass surfaces.
abstract final class GlassDefaults {
  static const double sigmaHero = 16;
  static const double sigmaChrome = 12;
  static const double sigmaButton = 10;
}

/// Static decoration for faux-glass (no [BackdropFilter]).
class GlassDecoration extends BoxDecoration {
  GlassDecoration({
    double borderRadius = AppColors.radius,
    Color? color,
    Color? borderColor,
    bool strong = false,
  }) : super(
          color: color ?? (strong ? AppColors.glassFillStrong : AppColors.glassFill),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: borderColor ?? AppColors.glassBorder),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              AppColors.glassBorderHighlight.withValues(alpha: 0.08),
              Colors.transparent,
            ],
          ),
        );
}

/// Frosted or faux-glass panel. Use [blur: false] inside scrollable lists.
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.blur = true,
    this.sigma = GlassDefaults.sigmaChrome,
    this.color,
    this.borderRadius = AppColors.radius,
    this.padding,
    this.margin,
    this.border,
    this.onTap,
    this.width,
    this.height,
  });

  final Widget child;
  final bool blur;
  final double sigma;
  final Color? color;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BoxBorder? border;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final Color fill = color ?? AppColors.glassPanel.withValues(alpha: blur ? 0.82 : 1.0);
    final BorderRadius radius = BorderRadius.circular(borderRadius);

    Widget content = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: radius,
        border: border ?? Border.all(color: AppColors.glassBorder.withValues(alpha: 0.85)),
        gradient: blur
            ? null
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  AppColors.glassBorderHighlight.withValues(alpha: 0.06),
                  Colors.transparent,
                ],
              ),
      ),
      child: child,
    );

    Widget surface = Material(
      color: fill,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: content,
    );

    if (blur) {
      surface = ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
          child: surface,
        ),
      );
    } else {
      surface = ClipRRect(borderRadius: radius, child: surface);
    }

    if (onTap != null) {
      surface = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: surface,
        ),
      );
    }

    if (margin != null) {
      return Padding(padding: margin!, child: surface);
    }
    return surface;
  }
}

/// Card preset — panels and list rows.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.blur = false,
    this.sigma = GlassDefaults.sigmaChrome,
    this.color,
    this.borderRadius = AppColors.radius,
    this.padding,
    this.margin,
    this.border,
    this.onTap,
  });

  final Widget child;
  final bool blur;
  final double sigma;
  final Color? color;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BoxBorder? border;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      blur: blur,
      sigma: sigma,
      color: color,
      borderRadius: borderRadius,
      padding: padding,
      margin: margin,
      border: border,
      onTap: onTap,
      child: child,
    );
  }
}

/// Tappable glass chip / secondary CTA.
class GlassButton extends StatelessWidget {
  const GlassButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.blur = true,
    this.sigma = GlassDefaults.sigmaButton,
    this.padding,
    this.borderRadius = AppColors.radius,
    this.foregroundColor,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final bool blur;
  final double sigma;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final Color fg = foregroundColor ?? AppColors.foreground;
    return GlassSurface(
      blur: blur,
      sigma: sigma,
      color: AppColors.glassFill.withValues(alpha: 0.75),
      borderRadius: borderRadius,
      border: Border.all(color: AppColors.glassBorderHighlight.withValues(alpha: 0.5)),
      onTap: onPressed,
      padding: padding ??
          EdgeInsets.symmetric(
            horizontal: AppDimens.space20,
            vertical: AppDimens.space12,
          ),
      child: DefaultTextStyle(
        style: Theme.of(context).textTheme.labelLarge!.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
        child: IconTheme(
          data: IconThemeData(color: fg, size: AppDimens.iconSm),
          child: child,
        ),
      ),
    );
  }
}

/// Circular glass shell for FAB-style controls.
class GlassFab extends StatelessWidget {
  const GlassFab({
    super.key,
    required this.onPressed,
    required this.child,
    this.tooltip,
    this.extended = false,
    this.label,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final String? tooltip;
  final bool extended;
  final String? label;

  @override
  Widget build(BuildContext context) {
    if (extended && label != null) {
      return GlassSurface(
        blur: true,
        sigma: GlassDefaults.sigmaButton,
        color: AppColors.glassFillStrong.withValues(alpha: 0.88),
        borderRadius: AppDimens.radiusPill,
        onTap: onPressed,
        padding: EdgeInsets.symmetric(
          horizontal: AppDimens.space16,
          vertical: AppDimens.space12,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            child,
            SizedBox(width: AppDimens.space8),
            Text(label!, style: Theme.of(context).textTheme.labelLarge),
          ],
        ),
      );
    }

    return GlassSurface(
      blur: true,
      sigma: GlassDefaults.sigmaButton,
      color: AppColors.glassFillStrong.withValues(alpha: 0.88),
      borderRadius: AppDimens.radiusPill,
      onTap: onPressed,
      width: 56,
      height: 56,
      child: Center(child: child),
    );
  }
}
