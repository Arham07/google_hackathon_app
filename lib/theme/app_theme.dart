import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_hackathon_app/theme/app_colors.dart';
import 'package:google_hackathon_app/theme/app_dimens.dart';
import 'package:google_hackathon_app/theme/app_text_styles.dart';

abstract final class AppTheme {
  /// Call inside [ScreenUtilInit] builder so `.sp` / `.r` are initialized.
  static ThemeData darkTheme() {
    final TextTheme baseText = GoogleFonts.interTextTheme(
      ThemeData.dark().textTheme,
    ).apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );

    final TextTheme textTheme = _scaleTextTheme(baseText);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.dark(
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        primary: AppColors.textPrimary,
        onPrimary: AppColors.background,
        secondary: AppColors.surfaceElevated,
        onSecondary: AppColors.textPrimary,
        error: AppColors.destructive,
        outline: AppColors.border,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.alertsTitle.copyWith(fontSize: 22.sp),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.glassBorder),
        ),
        margin: EdgeInsets.symmetric(
          horizontal: AppDimens.space16,
          vertical: AppDimens.space8,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceElevated,
        hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          borderSide: BorderSide(color: AppColors.mapAccent, width: 1.5.w),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          borderSide: const BorderSide(color: AppColors.destructive),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppDimens.space16,
          vertical: AppDimens.space14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.surfaceElevated,
          foregroundColor: AppColors.textPrimary,
          padding: EdgeInsets.symmetric(
            horizontal: AppDimens.space24,
            vertical: AppDimens.space14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.background,
        indicatorColor: AppColors.filterSelected,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return textTheme.labelSmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            );
          }
          return textTheme.labelSmall?.copyWith(color: AppColors.textSecondary);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.textPrimary);
          }
          return const IconThemeData(color: AppColors.textSecondary);
        }),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        ),
      ),
    );
  }

  static TextTheme _scaleTextTheme(TextTheme base) {
    TextStyle? s(TextStyle? style, double size) =>
        style?.copyWith(fontSize: size.sp, height: style.height);

    return base.copyWith(
      displayLarge: s(base.displayLarge, 57),
      displayMedium: s(base.displayMedium, 45),
      displaySmall: s(base.displaySmall, 36),
      headlineLarge: s(base.headlineLarge, 32),
      headlineMedium: s(base.headlineMedium, 28),
      headlineSmall: s(base.headlineSmall, 24),
      titleLarge: s(base.titleLarge, 22),
      titleMedium: s(base.titleMedium, 16),
      titleSmall: s(base.titleSmall, 14),
      bodyLarge: s(base.bodyLarge, 16),
      bodyMedium: s(base.bodyMedium, 14),
      bodySmall: s(base.bodySmall, 12),
      labelLarge: s(base.labelLarge, 14),
      labelMedium: s(base.labelMedium, 12),
      labelSmall: s(base.labelSmall, 11),
    );
  }
}
