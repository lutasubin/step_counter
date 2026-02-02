import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:step_counter/core/constants/app_colors.dart';
import 'package:step_counter/core/constants/app_strings.dart';
import 'package:step_counter/features/heart_rate/viewmodels/heart_rate_result_controller.dart';

/// Widget nội dung kết quả đo nhịp tim
class HeartRateResultContentWidget extends StatelessWidget {
  final HeartRateResultController controller;

  const HeartRateResultContentWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [const SizedBox(height: 20), _buildResultCard()],
      ),
    );
  }

  /// Xây dựng card kết quả
  Widget _buildResultCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildTimestamp(),
          const SizedBox(height: 16),
          _buildBPMValue(),
          const SizedBox(height: 12),
          _buildYourResultText(),
          const SizedBox(height: 16),
          _buildRangeIndicator(),
          const SizedBox(height: 12),
          _buildStatus(),
          const SizedBox(height: 8),
          _buildNormalRange(),
        ],
      ),
    );
  }

  /// Xây dựng timestamp
  Widget _buildTimestamp() {
    return Obx(() {
      final dateTime = controller.dateTime.value;
      final timeText =
          '${DateFormat('h:mm a').format(dateTime)} - ${DateFormat('MMMM dd, yyyy').format(dateTime)}';
      return Center(
        child: Text(
          timeText,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            color: AppColors.textPrimary,
            fontSize: 14,
          ),
        ),
      );
    });
  }

  /// Xây dựng BPM value
  Widget _buildBPMValue() {
    return Obx(() {
      return Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '${controller.bpm.value}',
              style: const TextStyle(
                fontFamily: 'Montserrat',
                color: AppColors.textPrimary,
                fontSize: 56,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.favorite, color: Colors.red, size: 24),
                const SizedBox(height: 4),
                const Text(
                  'BMP',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    color: AppColors.textPrimary,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  /// Xây dựng "Your result is" text
  Widget _buildYourResultText() {
    return const Center(
      child: Text(
        AppStrings.yourResultIs,
        style: TextStyle(
          fontFamily: 'Montserrat',
          color: AppColors.textPrimary,
          fontSize: 14,
        ),
      ),
    );
  }

  /// Xây dựng range indicator bar
  Widget _buildRangeIndicator() {
    return Obx(() {
      final bpm = controller.bpm.value;
      return LayoutBuilder(
        builder: (context, constraints) {
          final barWidth = constraints.maxWidth;
          const gapWidth = 4.0; // Khoảng cách giữa các segments
          const totalSegments = 5.0; // 5 segments
          const totalGaps = 4.0; // 4 khoảng cách giữa 5 segments
          final availableWidth = barWidth - (totalGaps * gapWidth);

          // Tính width của mỗi segment - chia đều nhau
          final segmentWidth = availableWidth / totalSegments;
          final segmentWidths = List.filled(5, segmentWidth);

          // Tính vị trí bắt đầu của mỗi segment
          double currentLeft = 0.0;
          final segmentStarts = <double>[];
          for (int i = 0; i < segmentWidths.length; i++) {
            segmentStarts.add(currentLeft);
            currentLeft += segmentWidths[i] + gapWidth;
          }

          // Tính vị trí triangle dựa trên BPM
          // Range mapping:
          // Segment 0 (Light blue): 40-60 (Low)
          // Segment 1 (Teal): 60-75 (Below Normal)
          // Segment 2 (Green): 75-89 (Normal)
          // Segment 3 (Orange): 89-100 (Elevated)
          // Segment 4 (Red): 100+ (High)
          final triangleLeft = _calculateTrianglePosition(
            bpm,
            segmentStarts,
            segmentWidths,
            barWidth,
          );

          return Column(
            children: [
              // Range bar với các segments có khoảng cách
              Row(
                children: [
                  // Light blue segment
                  Container(
                    width: segmentWidths[0],
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4A90E2), // Light blue
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(4),
                        bottomLeft: Radius.circular(4),
                      ),
                    ),
                  ),
                  SizedBox(width: gapWidth),
                  // Teal segment
                  Container(
                    width: segmentWidths[1],
                    height: 8,
                    color: const Color(0xFF4DD0E1), // Teal/Cyan
                  ),
                  SizedBox(width: gapWidth),
                  // Green segment
                  Container(
                    width: segmentWidths[2],
                    height: 8,
                    color: const Color(0xFF15D254), // Green
                  ),
                  SizedBox(width: gapWidth),
                  // Orange segment
                  Container(
                    width: segmentWidths[3],
                    height: 8,
                    color: AppColors.buttonOrange, // Orange
                  ),
                  SizedBox(width: gapWidth),
                  // Red segment
                  Container(
                    width: segmentWidths[4],
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(4),
                        bottomRight: Radius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Triangle indicator - màu phù hợp với status
              SizedBox(
                height: 8,
                width: barWidth,
                child: Stack(
                  children: [
                    Positioned(
                      left: triangleLeft.clamp(0.0, barWidth - 12),
                      child: CustomPaint(
                        size: const Size(12, 8),
                        painter: _TriangleIndicatorPainter(
                          color: _getStatusColor(controller.status),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      );
    });
  }

  /// Tính vị trí tam giác dựa trên BPM
  double _calculateTrianglePosition(
    int bpm,
    List<double> segmentStarts,
    List<double> segmentWidths,
    double barWidth,
  ) {
    int segmentIndex;
    double positionInSegment;

    if (bpm < 40) {
      // Dưới 40: ở đầu segment 0
      segmentIndex = 0;
      positionInSegment = 0.0;
    } else if (bpm < 60) {
      // 40-60: segment 0 (Light blue)
      segmentIndex = 0;
      positionInSegment = (bpm - 40) / 20.0; // 0.0 đến 1.0
    } else if (bpm < 75) {
      // 60-75: segment 1 (Teal)
      segmentIndex = 1;
      positionInSegment = (bpm - 60) / 15.0; // 0.0 đến 1.0
    } else if (bpm < 89) {
      // 75-89: segment 2 (Green)
      segmentIndex = 2;
      positionInSegment = (bpm - 75) / 14.0; // 0.0 đến 1.0
    } else if (bpm < 100) {
      // 89-100: segment 3 (Orange)
      segmentIndex = 3;
      positionInSegment = (bpm - 89) / 11.0; // 0.0 đến 1.0
    } else if (bpm < 120) {
      // 100-120: segment 4 (Red) - đầu
      segmentIndex = 4;
      positionInSegment = (bpm - 100) / 20.0; // 0.0 đến 1.0
    } else {
      // Trên 120: ở cuối segment 4
      segmentIndex = 4;
      positionInSegment = 1.0;
    }

    // Clamp position trong segment
    positionInSegment = positionInSegment.clamp(0.0, 1.0);

    // Tính vị trí thực tế
    final segmentStart = segmentStarts[segmentIndex];
    final segmentWidth = segmentWidths[segmentIndex];
    final triangleCenter = segmentStart + (segmentWidth * positionInSegment);

    // Trừ đi một nửa width của tam giác (6px) để căn giữa
    return (triangleCenter - 6).clamp(0.0, barWidth - 12);
  }

  /// Lấy màu dựa trên status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'normal':
        return const Color(0xFF15D254); // Xanh lá cây
      case 'low':
        return Colors.blue; // Xanh dương
      case 'elevated':
        return Colors.orange; // Cam
      case 'high':
        return Colors.red; // Đỏ
      default:
        return const Color(0xFF15D254); // Mặc định xanh lá
    }
  }

  /// Xây dựng status
  Widget _buildStatus() {
    return Obx(() {
      // Truy cập bpm để trigger reactive
      final _ = controller.bpm.value;
      final statusColor = _getStatusColor(controller.status);
      return Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            controller.status,
            style: TextStyle(
              fontFamily: 'Montserrat',
              color: statusColor,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: () {
              // TODO: Show info dialog
            },
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.info_outline,
                size: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      );
    });
  }

  /// Xây dựng normal range
  Widget _buildNormalRange() {
    return Center(
      child: Text(
        AppStrings.normalRange,
        style: const TextStyle(
          fontFamily: 'Montserrat',
          color: AppColors.textSecondary,
          fontSize: 12,
        ),
      ),
    );
  }
}

/// Painter cho triangle indicator
class _TriangleIndicatorPainter extends CustomPainter {
  final Color color;

  const _TriangleIndicatorPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(size.width / 2, 0) // Đỉnh trên
      ..lineTo(0, size.height) // Góc trái dưới
      ..lineTo(size.width, size.height) // Góc phải dưới
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is _TriangleIndicatorPainter) {
      return oldDelegate.color != color;
    }
    return true;
  }
}
