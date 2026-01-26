import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:step_counter/core/constants/app_assets.dart';

/// Widget hiển thị icon splash
class SplashIconWidget extends StatelessWidget {
  const SplashIconWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      AppAssets.iconSplash,
      width: 112,
      height: 112,
    );
  }
}
