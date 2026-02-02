import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:step_counter/core/constants/app_colors.dart';
import 'package:step_counter/features/report/viewmodels/report_controller.dart';
import 'package:step_counter/features/report/views/widgets/report_header_widget.dart';
import 'package:step_counter/features/report/views/widgets/report_period_selector_widget.dart';
import 'package:step_counter/features/report/views/widgets/report_step_display_widget.dart';
import 'package:step_counter/features/report/views/widgets/report_chart_widget.dart';
import 'package:step_counter/features/report/views/widgets/report_summary_metrics_widget.dart';

/// Màn hình report thống kê
class ReportView extends StatelessWidget {
  const ReportView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReportController>();

    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ReportHeaderWidget(),
              const SizedBox(height: 16),
              ReportPeriodSelectorWidget(controller: controller),
              const SizedBox(height: 16),
              _buildDateAndStepCard(controller),
              const SizedBox(height: 20),
              ReportChartWidget(controller: controller),
              const SizedBox(height: 20),
              ReportSummaryMetricsWidget(controller: controller),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// Xây dựng card kết hợp date navigator và step display
  Widget _buildDateAndStepCard(ReportController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            _buildDateNavigator(controller),
            const SizedBox(height: 20),
            ReportStepDisplayWidget(controller: controller),
          ],
        ),
      ),
    );
  }

  /// Xây dựng date navigator
  Widget _buildDateNavigator(ReportController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: () => controller.previousPeriod(),
          borderRadius: BorderRadius.circular(8),
          child: const Padding(
            padding: EdgeInsets.all(8),
            child: Icon(
              Icons.chevron_left,
              color: AppColors.textPrimary,
              size: 24,
            ),
          ),
        ),
        Obx(
          () => Text(
            controller.getDateDisplay(),
            style: const TextStyle(
              fontFamily: 'Montserrat',
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        InkWell(
          onTap: () => controller.nextPeriod(),
          borderRadius: BorderRadius.circular(8),
          child: const Padding(
            padding: EdgeInsets.all(8),
            child: Icon(
              Icons.chevron_right,
              color: AppColors.textPrimary,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }
}
