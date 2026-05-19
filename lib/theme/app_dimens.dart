import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Responsive spacing, radii, and icon sizes (design: 393×852).
abstract final class AppDimens {
  static double get space4 => 4.r;
  static double get space6 => 6.r;
  static double get space8 => 8.r;
  static double get space10 => 10.r;
  static double get space12 => 12.r;
  static double get space14 => 14.r;
  static double get space16 => 16.r;
  static double get space20 => 20.r;
  static double get space24 => 24.r;
  static double get space28 => 28.r;
  static double get space32 => 32.r;
  static double get space40 => 40.r;

  /// Matches ciro `--radius: 0.625rem` (~10 logical px).
  static double get radiusSm => 6.r;
  static double get radiusMd => 10.r;
  static double get radiusLg => 12.r;
  static double get radiusXl => 16.r;
  static double get radiusPill => 20.r;

  static double get iconXs => 14.sp;
  static double get iconSm => 16.sp;
  static double get iconMd => 18.sp;
  static double get iconLg => 20.sp;
  static double get iconXl => 48.sp;
  static double get iconHero => 56.sp;
  static double get iconOnboarding => 72.sp;

  static double get font10 => 10.sp;
  static double get font11 => 11.sp;
  static double get chartHeight => 200.h;
  static double get chipRowHeight => 40.h;
  static double get searchListMaxHeight => 220.h;
  static double get photoPreviewHeight => 160.h;
  static double get mapPreviewHeight => 180.h;
  static double get newsThumbHeight => 120.h;
}
