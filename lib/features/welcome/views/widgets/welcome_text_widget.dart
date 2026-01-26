import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:step_counter/core/constants/app_assets.dart';

/// Widget hiển thị text welcome
class WelcomeTextWidget extends StatelessWidget {
  const WelcomeTextWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final horizontalPadding = screenSize.width * 0.1;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: SvgPicture.asset(
        AppAssets.welcomeText,
        width: screenSize.width * 0.85,
        fit: BoxFit.contain,
      ),
    );
  }
}
