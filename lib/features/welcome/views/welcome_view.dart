import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:step_counter/core/constants/app_assets.dart';
import 'package:step_counter/features/welcome/viewmodels/welcome_controller.dart';
import 'package:step_counter/features/welcome/views/widgets/welcome_start_button_widget.dart';
import 'package:step_counter/features/welcome/views/widgets/welcome_text_widget.dart';

/// Màn hình welcome
class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WelcomeController>();
    final screenSize = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildBackground(),
          _buildOverlay(),
          _buildContent(context, screenSize, padding, controller),
        ],
      ),
    );
  }

  /// Xây dựng background image
  Widget _buildBackground() {
    return Image.asset(AppAssets.welcomeBackground, fit: BoxFit.cover);
  }

  /// Xây dựng lớp phủ tối
  Widget _buildOverlay() {
    // ignore: deprecated_member_use
    return Container(color: Colors.black.withOpacity(0.5));
  }

  /// Xây dựng nội dung màn hình
  Widget _buildContent(
    BuildContext context,
    Size screenSize,
    EdgeInsets padding,
    WelcomeController controller,
  ) {
    return SafeArea(
      child: Column(
        children: [
          SizedBox(height: screenSize.height * 0.1),
          _buildTextSection(),
          const Spacer(),
          _buildButtonSection(controller, padding),
        ],
      ),
    );
  }

  /// Xây dựng phần text
  Widget _buildTextSection() {
    return const WelcomeTextWidget();
  }

  /// Xây dựng phần nút
  Widget _buildButtonSection(WelcomeController controller, EdgeInsets padding) {
    return Padding(
      padding: EdgeInsets.only(bottom: padding.bottom + 40),
      child: WelcomeStartButtonWidget(
        onPressed: () => controller.navigateToHome(),
      ),
    );
  }
}
