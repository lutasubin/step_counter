import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:step_counter/core/constants/app_assets.dart';

/// Widget hiển thị tên ứng dụng
class SplashAppNameWidget extends StatelessWidget {
  const SplashAppNameWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      AppAssets.appNameLogo,
      width: 252,
      height: 20,
    );
  }
}
