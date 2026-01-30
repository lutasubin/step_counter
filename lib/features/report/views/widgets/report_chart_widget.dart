import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:step_counter/core/constants/app_colors.dart';
import 'package:step_counter/core/constants/app_strings.dart';
import 'package:step_counter/features/report/viewmodels/report_controller.dart';

/// Widget hiển thị biểu đồ
class ReportChartWidget extends StatelessWidget {
  final ReportController controller;

  const ReportChartWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.homeBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Obx(() {
          return SizedBox(
            height: 250,
            child: Stack(
              children: [
                _buildChart(),
                // Custom tooltip khi có selectedIndex
                if (controller.selectedIndex >= 0 &&
                    controller.selectedIndex < controller.activities.length)
                  _buildCustomTooltip(controller.selectedIndex),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildChart() {
    if (controller.selectedPeriod == PeriodType.day) {
      return _buildDayChart();
    }
    return _buildWeekMonthChart();
  }

  Widget _buildDayChart() {
    return Obx(() {
      final spots = controller.activities.asMap().entries.map((entry) {
        return FlSpot(entry.key.toDouble(), entry.value.steps.toDouble());
      }).toList();

      // Kiểm tra xem có dữ liệu không (ít nhất 1 điểm có steps > 0)
      final hasData = controller.activities.any((activity) => activity.steps > 0);

      // Y-axis: 0, 500, 1k, 1.5k, 2k, 2.5k
      const maxY = 2500.0;
      const yIntervals = [0, 500, 1000, 1500, 2000, 2500];

      return LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            drawHorizontalLine: true,
            horizontalInterval: 500,
            verticalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return const FlLine(
                color: AppColors.loadingBarInactive, // #253047
                strokeWidth: 1,
                dashArray: [5, 5],
              );
            },
            getDrawingVerticalLine: (value) {
              return const FlLine(
                color: AppColors.loadingBarInactive, // #253047
                strokeWidth: 1,
                dashArray: [5, 5],
              );
            },
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                getTitlesWidget: (value, meta) {
                  if (yIntervals.contains(value.toInt())) {
                    return Text(
                      _formatStepValue(value.toInt()),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < 6) {
                    final labels = [
                      '00-04',
                      '04-08',
                      '08-12',
                      '12-16',
                      '16-20',
                      '20-24',
                    ];
                    return InkWell(
                      onTap: () {
                        controller.setSelectedIndex(index);
                      },
                      child: Text(
                        labels[index],
                        style: TextStyle(
                          color: controller.selectedIndex == index
                              ? AppColors.buttonOrange
                              : AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: const Border(
              left: BorderSide(color: AppColors.loadingBarInactive, width: 1),
              bottom: BorderSide(color: AppColors.loadingBarInactive, width: 1),
              right: BorderSide(color: AppColors.loadingBarInactive, width: 1),
              top: BorderSide(color: AppColors.loadingBarInactive, width: 1),
            ),
          ),
          lineBarsData: hasData
              ? [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppColors.buttonOrange, // Đường line màu cam
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      // Chỉ hiển thị dot tại điểm được chọn
                      getDotPainter: (spot, percent, barData, index) {
                        if (controller.selectedIndex == index) {
                          return FlDotCirclePainter(
                            radius: 6,
                            color: Colors.white, // Màu trắng bên trong
                            strokeWidth: 2,
                            strokeColor: AppColors.buttonOrange, // Viền cam
                          );
                        }
                        return FlDotCirclePainter(
                          radius: 0,
                          color: Colors.transparent,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(show: false),
                  ),
                ]
              : [], // Không có dữ liệu thì không vẽ line
          lineTouchData: LineTouchData(
            enabled: false, // Tắt touch trên line, chỉ dùng click vào X-axis
          ),
          extraLinesData: ExtraLinesData(
            verticalLines: [
              if (controller.selectedIndex >= 0 &&
                  controller.selectedIndex < controller.activities.length &&
                  hasData)
                VerticalLine(
                  x: controller.selectedIndex.toDouble(),
                  color: AppColors.buttonOrange, // Đường dọc chọn điểm màu cam
                  strokeWidth: 2,
                  label: VerticalLineLabel(show: false),
                ),
            ],
          ),
          minY: 0,
          maxY: maxY,
        ),
      );
    });
  }

  Widget _buildWeekMonthChart() {
    return Obx(() {
      if (controller.activities.isEmpty) {
        return const SizedBox(
          height: 200,
          child: Center(
            child: Text(
              'Không có dữ liệu',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        );
      }

      final spots = controller.activities.asMap().entries.map((entry) {
        return FlSpot(entry.key.toDouble(), entry.value.steps.toDouble());
      }).toList();

      // Kiểm tra xem có dữ liệu không (ít nhất 1 điểm có steps > 0)
      final hasData = controller.activities.any((activity) => activity.steps > 0);

      final maxSteps = controller.activities
          .map((a) => a.steps)
          .reduce((a, b) => a > b ? a : b);

      // Tính toán Y-axis intervals dựa trên maxSteps
      // Cho Week view: 0, 2.5k, 5k, 7.5k, 10k, 15k hoặc tự động
      double maxY;
      List<int> yIntervals;
      double horizontalInterval;

      if (controller.selectedPeriod == PeriodType.week) {
        // Week view: Y-axis từ 0 đến 15k với intervals 2.5k
        maxY = maxSteps > 15000 ? maxSteps * 1.2 : 15000.0;
        yIntervals = [0, 2500, 5000, 7500, 10000, 15000];
        horizontalInterval = 2500.0; // Fixed interval cho Week view
      } else {
        // Month view: Y-axis từ 0 đến 15k với intervals 2.5k (giống Week view)
        maxY = maxSteps > 15000 ? maxSteps * 1.2 : 15000.0;
        yIntervals = [0, 2500, 5000, 7500, 10000, 15000];
        horizontalInterval = 2500.0; // Fixed interval cho Month view
      }

      return LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            drawHorizontalLine: true,
            horizontalInterval: horizontalInterval,
            verticalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return const FlLine(
                color: AppColors.loadingBarInactive, // #253047
                strokeWidth: 1,
                dashArray: [5, 5],
              );
            },
            getDrawingVerticalLine: (value) {
              return const FlLine(
                color: AppColors.loadingBarInactive, // #253047
                strokeWidth: 1,
                dashArray: [5, 5],
              );
            },
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                getTitlesWidget: (value, meta) {
                  // Week và Month view: chỉ hiển thị các giá trị trong yIntervals
                  if (yIntervals.contains(value.toInt())) {
                    return Text(
                      _formatStepValue(value.toInt()),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < controller.activities.length) {
                    return InkWell(
                      onTap: () {
                        controller.setSelectedIndex(index);
                      },
                      child: Text(
                        _getXAxisLabel(index),
                        style: TextStyle(
                          color: controller.selectedIndex == index
                              ? AppColors.buttonOrange
                              : AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: const Border(
              left: BorderSide(color: AppColors.loadingBarInactive, width: 1),
              bottom: BorderSide(color: AppColors.loadingBarInactive, width: 1),
              right: BorderSide(color: AppColors.loadingBarInactive, width: 1),
              top: BorderSide(color: AppColors.loadingBarInactive, width: 1),
            ),
          ),
          lineBarsData: hasData
              ? [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppColors.buttonOrange, // Đường line màu cam
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      // Chỉ hiển thị dot tại điểm được chọn
                      getDotPainter: (spot, percent, barData, index) {
                        if (controller.selectedIndex == index) {
                          return FlDotCirclePainter(
                            radius: 6,
                            color: Colors.white, // Màu trắng bên trong
                            strokeWidth: 2,
                            strokeColor: AppColors.buttonOrange, // Viền cam
                          );
                        }
                        return FlDotCirclePainter(
                          radius: 0,
                          color: Colors.transparent,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(show: false),
                  ),
                ]
              : [], // Không có dữ liệu thì không vẽ line
          lineTouchData: LineTouchData(
            enabled: false, // Tắt touch trên line, chỉ dùng click vào X-axis
          ),
          extraLinesData: ExtraLinesData(
            verticalLines: [
              if (controller.selectedIndex >= 0 &&
                  controller.selectedIndex < controller.activities.length &&
                  hasData)
                VerticalLine(
                  x: controller.selectedIndex.toDouble(),
                  color: AppColors.buttonOrange, // Đường dọc chọn điểm màu cam
                  strokeWidth: 2,
                  label: VerticalLineLabel(show: false),
                ),
            ],
          ),
          minY: 0,
          maxY: maxY,
        ),
      );
    });
  }

  String _formatStepValue(int steps) {
    if (steps >= 1000) {
      return '${(steps / 1000).toStringAsFixed(1)}k';
    }
    return steps.toString();
  }

  String _getXAxisLabel(int index) {
    if (index >= controller.activities.length) return '';
    final date = controller.activities[index].date;
    switch (controller.selectedPeriod) {
      case PeriodType.day:
        return DateFormat('HH').format(date);
      case PeriodType.week:
        return DateFormat('E', 'en_US').format(date).substring(0, 1);
      case PeriodType.month:
        // Month view: hiển thị "Jan 20", "Jan 21", etc.
        // Nếu là ngày đầu tiên của tháng, hiển thị "Jan" (tháng)
        if (index == 0) {
          return DateFormat('MMM', 'en_US').format(date);
        }
        // Các ngày khác hiển thị "MMM dd"
        return DateFormat('MMM dd', 'en_US').format(date);
    }
  }

  /// Xây dựng custom tooltip widget
  Widget _buildCustomTooltip(int index) {
    final steps = controller.activities[index].steps;
    final totalItems = controller.activities.length;

    // Tính toán vị trí tooltip dựa trên index
    // Giả sử chart width là ~250px, chia đều cho số items
    final chartWidth = 250.0;
    final itemWidth = chartWidth / totalItems;
    final leftPosition = (index * itemWidth) + (itemWidth / 2) - 40;

    // Tính toán vị trí Y dựa trên giá trị steps
    double maxY;
    if (controller.selectedPeriod == PeriodType.day) {
      maxY = 2500.0;
    } else {
      final maxSteps = controller.activities
          .map((a) => a.steps)
          .reduce((a, b) => a > b ? a : b);
      maxY = maxSteps > 15000 ? maxSteps * 1.2 : 15000.0;
    }

    final chartHeight = 200.0; // Approximate chart height
    final topPosition = chartHeight - (steps / maxY) * chartHeight - 60;

    return Positioned(
      left: leftPosition.clamp(0.0, chartWidth - 80),
      top: topPosition.clamp(0.0, chartHeight - 70),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.buttonOrange,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$steps',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  AppStrings.step,
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 0),
          CustomPaint(
            size: const Size(20, 8),
            painter: _TrianglePointerPainter(color: AppColors.buttonOrange),
          ),
        ],
      ),
    );
  }
}

/// Vẽ tam giác nhỏ bên dưới tooltip
class _TrianglePointerPainter extends CustomPainter {
  final Color color;

  const _TrianglePointerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(size.width / 2, size.height) // đỉnh dưới
      ..lineTo(0, 0) // góc trái trên
      ..lineTo(size.width, 0) // góc phải trên
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
