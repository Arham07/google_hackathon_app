import 'package:flutter/material.dart';
import 'package:google_hackathon_app/config/app_assets.dart';
import 'package:google_hackathon_app/theme/app_dimens.dart';

/// In-app BaKhabar logo (not the launcher icon).
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.height});

  final double? height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppAssets.logo,
      height: height ?? AppDimens.logoHeight,
      fit: BoxFit.contain,
      semanticLabel: 'BaKhabar logo',
    );
  }
}
