import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:step_counter/core/constants/app_colors.dart';
import 'package:step_counter/core/constants/app_strings.dart';
import 'package:step_counter/features/blood_pressure/viewmodels/new_blood_pressure_controller.dart';

/// Widget hiển thị kết quả blood pressure với range indicator
class BloodPressureResultCardWidget extends StatelessWidget {
  const BloodPressureResultCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NewBloodPressureController>();

    return Obx(() {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // "Your result is"
            Text(
              AppStrings.yourResultIs,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            // Range indicator bar
            _buildRangeIndicator(controller),
            const SizedBox(height: 16),
            // Status với green square và info icon (căn trái)
            Align(
              alignment: Alignment.centerLeft,
              child: _buildStatus(controller),
            ),
            const SizedBox(height: 8),
            // Normal range text (căn trái)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Normal range: ${controller.normalRange}',
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  /// Lấy màu dựa trên status (6 categories)
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'hypotension':
        return Colors.blue; // Xanh dương
      case 'normal':
        return const Color(0xFF15D254); // Xanh lá
      case 'elevated':
        return Colors.yellow; // Vàng
      case 'stage 1':
        return const Color(0xFFFFA500); // Cam (Orange 1)
      case 'stage 2':
        return const Color(0xFFFF6B35); // Cam đậm (Orange 2)
      case 'hypertensive':
        return Colors.red; // Đỏ
      default:
        return const Color(0xFF15D254);
    }
  }

  /// Xây dựng range indicator bar
  Widget _buildRangeIndicator(NewBloodPressureController controller) {
    const greenColor = Color(0xFF15D254);
    const barWidth = 300.0;
    const segmentCount = 6;
    const gapWidth = 2.0;
    final segmentWidth =
        (barWidth - (gapWidth * (segmentCount - 1))) / segmentCount;

    return Obx(() {
      // Truy cập systolic và diastolic để trigger reactive update
      final systolic = controller.systolic;
      final diastolic = controller.diastolic;
      final status = controller.status;

      // Tính vị trí tam giác dựa trên cả systolic và diastolic
      final triangleLeft = _calculateTrianglePosition(
        systolic,
        diastolic,
        segmentWidth,
        gapWidth,
        barWidth,
      );

      return LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              // Range bar với 6 segments bằng nhau
              SizedBox(
                height: 24,
                width: barWidth,
                child: Row(
                  children: [
                    // Segment 1: Blue
                    SizedBox(
                      width: segmentWidth,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(4),
                            bottomLeft: Radius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: gapWidth),
                    // Segment 2: Green (Normal)
                    SizedBox(
                      width: segmentWidth,
                      child: Container(color: greenColor),
                    ),
                    SizedBox(width: gapWidth),
                    // Segment 3: Yellow
                    SizedBox(
                      width: segmentWidth,
                      child: Container(color: Colors.yellow),
                    ),
                    SizedBox(width: gapWidth),
                    // Segment 4: Orange 1
                    SizedBox(
                      width: segmentWidth,
                      child: Container(color: const Color(0xFFFFA500)),
                    ),
                    SizedBox(width: gapWidth),
                    // Segment 5: Orange 2
                    SizedBox(
                      width: segmentWidth,
                      child: Container(color: const Color(0xFFFFA500)),
                    ),
                    SizedBox(width: gapWidth),
                    // Segment 6: Red (High)
                    SizedBox(
                      width: segmentWidth,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(4),
                            bottomRight: Radius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Triangle indicator (màu động dựa trên status, vị trí dựa trên systolic)
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
                          _getStatusColor(status),
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

  /// Tính vị trí tam giác dựa trên cả systolic và diastolic
  /// Map to 6 segments theo categories:
  /// Segment 0 (Blue): Hypotension - SYS < 90 or DIA < 60
  /// Segment 1 (Green): Normal - SYS 90-119 and DIA 60-79
  /// Segment 2 (Yellow): Elevated - SYS 120-129 and DIA 60-79
  /// Segment 3 (Orange 1): Stage 1 - SYS 130-139 and DIA 80-89
  /// Segment 4 (Orange 2): Stage 2 - SYS 140-180 or DIA 90-120
  /// Segment 5 (Red): Hypertensive - SYS > 180 or DIA > 120
  double _calculateTrianglePosition(
    int systolic,
    int diastolic,
    double segmentWidth,
    double gapWidth,
    double barWidth,
  ) {
    int segmentIndex;
    double positionInSegment;

    // Xác định segment dựa trên cả systolic và diastolic theo đúng 6 categories
    if (systolic < 90 || diastolic < 60) {
      // Segment 0 (Blue): Hypotension
      segmentIndex = 0;
      if (diastolic < 60 && systolic >= 90) {
        // Diastolic thấp nhưng systolic bình thường -> đẩy về đầu segment
        positionInSegment = 0.0;
      } else {
        positionInSegment = systolic < 50 ? 0.0 : (systolic - 50) / 40.0;
      }
    } else if (systolic >= 90 &&
        systolic <= 119 &&
        diastolic >= 60 &&
        diastolic <= 79) {
      // Segment 1 (Green): Normal
      segmentIndex = 1;
      positionInSegment = (systolic - 90) / 30.0; // 90-119 range
    } else if (systolic >= 120 &&
        systolic <= 129 &&
        diastolic >= 60 &&
        diastolic <= 79) {
      // Segment 2 (Yellow): Elevated
      segmentIndex = 2;
      positionInSegment = (systolic - 120) / 10.0; // 120-129 range
    } else if (systolic >= 130 &&
        systolic <= 139 &&
        diastolic >= 80 &&
        diastolic <= 89) {
      // Segment 3 (Orange 1): Stage 1
      segmentIndex = 3;
      positionInSegment = (systolic - 130) / 10.0; // 130-139 range
    } else if ((systolic >= 140 && systolic <= 180) ||
        (diastolic >= 90 && diastolic <= 120)) {
      // Segment 4 (Orange 2): Stage 2
      segmentIndex = 4;
      if (diastolic >= 90 && diastolic <= 120 && systolic < 140) {
        // Diastolic cao nhưng systolic chưa cao -> đẩy về đầu segment
        positionInSegment = 0.0;
      } else {
        positionInSegment = systolic < 140
            ? 0.0
            : (systolic - 140) / 40.0; // 140-180 range
      }
    } else {
      // Segment 5 (Red): Hypertensive
      segmentIndex = 5;
      if (diastolic > 120 && systolic <= 180) {
        // Diastolic rất cao nhưng systolic chưa quá cao -> đẩy về đầu segment
        positionInSegment = 0.0;
      } else {
        positionInSegment = systolic > 180
            ? ((systolic - 180) / 20.0).clamp(0.0, 1.0)
            : 0.0;
      }
    }

    positionInSegment = positionInSegment.clamp(0.0, 1.0);

    // Tính vị trí thực tế (tất cả segments có cùng width)
    final segmentStart = segmentIndex * (segmentWidth + gapWidth);
    final triangleCenter = segmentStart + (segmentWidth * positionInSegment);

    return (triangleCenter - 6).clamp(0.0, barWidth - 12);
  }

  /// Xây dựng status
  Widget _buildStatus(NewBloodPressureController controller) {
    final statusColor = _getStatusColor(controller.status);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
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
        const SizedBox(width: 8),
        const Icon(
          Icons.info_outline,
          color: AppColors.textSecondary,
          size: 18,
        ),
      ],
    );
  }
}

/// Painter để vẽ tam giác chỉ thị (màu động dựa trên status)
class _TriangleIndicatorPainter extends CustomPainter {
  final Color color;

  _TriangleIndicatorPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    // Vẽ tam giác chỉ lên trên
    path.moveTo(size.width / 2, 0);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
