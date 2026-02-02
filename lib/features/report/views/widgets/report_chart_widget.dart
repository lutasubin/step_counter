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
      final hasData = controller.activities.any(
        (activity) => activity.steps > 0,
      );

      // Tính maxSteps từ dữ liệu thực tế
      final maxSteps = hasData
          ? controller.activities
                .map((a) => a.steps)
                .reduce((a, b) => a > b ? a : b)
          : 0;

      // Tính toán Y-axis tự động dựa trên maxSteps
      // Nếu maxSteps <= 2500, dùng 2500 làm maxY
      // Nếu maxSteps > 2500, tính maxY = maxSteps * 1.2 (thêm 20% padding)
      double maxY;
      List<int> yIntervals;
      double horizontalInterval;

      if (maxSteps <= 2500) {
        // Trường hợp bình thường: 0, 500, 1k, 1.5k, 2k, 2.5k
        maxY = 2500.0;
        yIntervals = [0, 500, 1000, 1500, 2000, 2500];
        horizontalInterval = 500.0;
      } else {
        // Trường hợp vượt quá 2500: tự động tính intervals
        // Làm tròn maxSteps lên bội số của 500 gần nhất, rồi thêm 20% padding
        final roundedMax = ((maxSteps / 500).ceil() * 500).toDouble();
        maxY = (roundedMax * 1.2).ceil().toDouble();

        // Tính số intervals (tối đa 6 intervals)
        final intervalSize = (maxY / 5).ceil().toDouble();
        // Làm tròn intervalSize lên bội số của 500
        horizontalInterval = ((intervalSize / 500).ceil() * 500).toDouble();

        // Tạo yIntervals: 0, interval, 2*interval, ..., maxY
        yIntervals = [];
        for (int i = 0; i <= 5; i++) {
          final value = (i * horizontalInterval).round();
          if (value <= maxY) {
            yIntervals.add(value);
          }
        }
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
                  if (yIntervals.contains(value.toInt())) {
                    return Text(
                      _formatStepValue(value.toInt()),
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        color: AppColors.textSecondary,
                        fontSize: 12,
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
                reservedSize:
                    50, // Tăng reservedSize để có nhiều không gian hơn
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
                    return GestureDetector(
                      onTap: () {
                        controller.setSelectedIndex(index);
                      },
                      behavior: HitTestBehavior.opaque, // Tăng vùng click
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ), // Tăng padding để dễ click hơn
                        child: Text(
                          labels[index],
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
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
            enabled: true, // Bật touch để có thể drag đường line
            touchTooltipData: LineTouchTooltipData(
              // Ẩn tooltip mặc định, dùng custom tooltip
              getTooltipColor: (touchedSpot) => Colors.transparent,
            ),
            touchCallback:
                (FlTouchEvent event, LineTouchResponse? touchResponse) {
                  // Khi user touch/drag trên biểu đồ, cập nhật selectedIndex
                  if (touchResponse != null &&
                      touchResponse.lineBarSpots != null &&
                      touchResponse.lineBarSpots!.isNotEmpty) {
                    final spot = touchResponse.lineBarSpots!.first;
                    final spotX = spot.x.toInt();
                    if (spotX >= 0 && spotX < controller.activities.length) {
                      controller.setSelectedIndex(spotX);
                    }
                  }
                },
            getTouchedSpotIndicator:
                (LineChartBarData barData, List<int> indicators) {
                  // Ẩn indicator mặc định
                  return indicators.map((index) {
                    return const TouchedSpotIndicatorData(
                      FlLine(color: Colors.transparent),
                      FlDotData(show: false),
                    );
                  }).toList();
                },
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
              style: TextStyle(
                fontFamily: 'Montserrat',
                color: AppColors.textSecondary,
              ),
            ),
          ),
        );
      }

      // Month view: Tạo spots chỉ cho những ngày có step > 0
      // Nhưng vẫn giữ index gốc để đảm bảo tooltip và dot hoạt động đúng
      List<FlSpot> spots;
      if (controller.selectedPeriod == PeriodType.month) {
        // Tạo spots chỉ cho những ngày có step > 0, nhưng giữ index gốc
        spots = controller.activities
            .asMap()
            .entries
            .where((entry) => entry.value.steps > 0)
            .map((entry) {
              // Giữ nguyên index gốc (entry.key) để tooltip và dot hoạt động đúng
              return FlSpot(entry.key.toDouble(), entry.value.steps.toDouble());
            })
            .toList();
      } else {
        // Week view: Tạo spots cho tất cả
        spots = controller.activities.asMap().entries.map((entry) {
          return FlSpot(entry.key.toDouble(), entry.value.steps.toDouble());
        }).toList();
      }

      // Kiểm tra xem có dữ liệu không (ít nhất 1 điểm có steps > 0)
      final hasData = controller.activities.any(
        (activity) => activity.steps > 0,
      );

      // Tính maxSteps chỉ từ những ngày có step > 0
      final maxSteps = hasData
          ? controller.activities
                .where((a) => a.steps > 0)
                .map((a) => a.steps)
                .reduce((a, b) => a > b ? a : b)
          : 0;

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
                        fontFamily: 'Montserrat',
                        color: AppColors.textSecondary,
                        fontSize: 12,
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
                reservedSize:
                    40, // Tăng reservedSize để có nhiều không gian hơn
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < controller.activities.length) {
                    final activity = controller.activities[index];
                    final day = activity.date.day;

                    // Month view: chỉ hiển thị label cho mốc 1, 15, 31 và các ngày có step > 0
                    if (controller.selectedPeriod == PeriodType.month) {
                      final month = activity.date.month;
                      final year = activity.date.year;
                      final daysInMonth = DateTime(year, month + 1, 0).day;
                      final isMilestone =
                          day == 1 || day == 15 || day == daysInMonth;
                      final hasSteps = activity.steps > 0;

                      // Chỉ hiển thị label nếu là mốc hoặc có step
                      if (isMilestone || hasSteps) {
                        return GestureDetector(
                          onTap: () {
                            controller.setSelectedIndex(index);
                          },
                          behavior: HitTestBehavior.opaque, // Tăng vùng click
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ), // Tăng padding để dễ click hơn
                            child: Text(
                              _getXAxisLabel(index),
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        );
                      }
                      return const Text('');
                    }

                    // Week view: hiển thị tất cả
                    return GestureDetector(
                      onTap: () {
                        controller.setSelectedIndex(index);
                      },
                      behavior: HitTestBehavior.opaque, // Tăng vùng click
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ), // Tăng padding để dễ click hơn
                        child: Text(
                          _getXAxisLabel(index),
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
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
                    // Spots đã được filter ở trên (Month view chỉ có ngày có step > 0)
                    spots: spots,
                    isCurved: true,
                    color: AppColors.buttonOrange, // Đường line màu cam
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      // Chỉ hiển thị dot tại điểm được chọn và có step > 0
                      getDotPainter: (spot, percent, barData, index) {
                        // Month view: spot.x là index gốc trong activities
                        if (controller.selectedPeriod == PeriodType.month) {
                          final spotX = spot.x.toInt();
                          if (spotX < controller.activities.length &&
                              controller.activities[spotX].steps > 0 &&
                              controller.selectedIndex == spotX) {
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
                        }

                        // Week view: hiển thị dot khi được chọn
                        // index trong getDotPainter là index trong spots array, cần map lại
                        final spotX = spot.x.toInt();
                        if (spotX < controller.activities.length &&
                            controller.selectedIndex == spotX) {
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
            enabled: true, // Bật touch để có thể drag đường line
            touchTooltipData: LineTouchTooltipData(
              // Ẩn tooltip mặc định, dùng custom tooltip
              getTooltipColor: (touchedSpot) => Colors.transparent,
            ),
            touchCallback:
                (FlTouchEvent event, LineTouchResponse? touchResponse) {
                  // Khi user touch/drag trên biểu đồ, cập nhật selectedIndex
                  if (touchResponse != null &&
                      touchResponse.lineBarSpots != null &&
                      touchResponse.lineBarSpots!.isNotEmpty) {
                    final spot = touchResponse.lineBarSpots!.first;
                    final spotX = spot.x.toInt();
                    if (spotX >= 0 && spotX < controller.activities.length) {
                      controller.setSelectedIndex(spotX);
                    }
                  }
                },
            getTouchedSpotIndicator:
                (LineChartBarData barData, List<int> indicators) {
                  // Ẩn indicator mặc định
                  return indicators.map((index) {
                    return const TouchedSpotIndicatorData(
                      FlLine(color: Colors.transparent),
                      FlDotData(show: false),
                    );
                  }).toList();
                },
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
        // Month view: luôn hiển thị mốc 1, 15, 31
        final day = date.day;
        if (day == 1) {
          // Ngày đầu tháng: hiển thị "1" hoặc "MMM 1"
          return '1';
        } else if (day == 15) {
          // Ngày giữa tháng: hiển thị "15"
          return '15';
        } else if (day >= 28 && day <= 31) {
          // Ngày cuối tháng: hiển thị số ngày (28/29/30/31)
          // Kiểm tra xem có phải là ngày cuối tháng không
          final month = date.month;
          final year = date.year;
          final daysInMonth = DateTime(year, month + 1, 0).day;
          if (day == daysInMonth) {
            return day.toString();
          }
        }
        // Các ngày khác có step: hiển thị số ngày
        return day.toString();
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
      // Tính maxY động cho Day view (giống logic trong _buildDayChart)
      final hasData = controller.activities.any(
        (activity) => activity.steps > 0,
      );
      if (hasData) {
        final maxSteps = controller.activities
            .map((a) => a.steps)
            .reduce((a, b) => a > b ? a : b);
        if (maxSteps <= 2500) {
          maxY = 2500.0;
        } else {
          final roundedMax = ((maxSteps / 500).ceil() * 500).toDouble();
          maxY = (roundedMax * 1.2).ceil().toDouble();
        }
      } else {
        maxY = 2500.0;
      }
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
                    fontFamily: 'Montserrat',
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  AppStrings.step,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    color: Colors.white,
                    fontSize: 12,
                  ),
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
