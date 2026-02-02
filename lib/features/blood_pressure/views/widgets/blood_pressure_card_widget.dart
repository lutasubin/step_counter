import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:step_counter/core/constants/app_colors.dart';
import 'package:step_counter/core/constants/app_strings.dart';
import 'package:step_counter/features/blood_pressure/model/blood_pressure_model.dart';

/// Widget card hiển thị blood pressure
class BloodPressureCardWidget extends StatelessWidget {
  final BloodPressureModel bloodPressure;
  final bool isToday;

  const BloodPressureCardWidget({
    super.key,
    required this.bloodPressure,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          if (isToday) ...[
            _buildTodayContent(),
          ] else ...[
            _buildHistoricalContent(),
          ],
        ],
      ),
    );
  }

  /// Xây dựng header với thời gian và arrow
  Widget _buildHeader() {
    String timeText;
    if (isToday) {
      timeText = 'Today ${DateFormat('h:mm a').format(bloodPressure.dateTime)}';
    } else {
      timeText =
          '${DateFormat('h:mm a').format(bloodPressure.dateTime)} - ${DateFormat('MMMM dd, yyyy').format(bloodPressure.dateTime)}';
    }

    return Row(
      children: [
        Expanded(
          child: Text(
            timeText,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const Icon(
          Icons.arrow_forward_ios,
          color: AppColors.textSecondary,
          size: 16,
        ),
      ],
    );
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
      // Backward compatibility với dữ liệu cũ
      case 'low':
        return Colors.blue; // Xanh dương
      case 'high':
        return Colors.red; // Đỏ
      default:
        return const Color(0xFF15D254);
    }
  }

  /// Xây dựng content cho card "Today"
  Widget _buildTodayContent() {
    final statusColor = _getStatusColor(bloodPressure.status);
    return Column(
      children: [
        // Status với square và info icon
        Row(
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
              bloodPressure.status,
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
        ),
        const SizedBox(height: 16),
        // 3 cột: Systolic, Diastolic, Pulse với đường phân cách
        Row(
          children: [
            Expanded(
              child: _buildTodayValueColumn(
                'Systolic',
                'mmHg',
                bloodPressure.systolic,
              ),
            ),
            Container(
              width: 1,
              height: 60,
              color: AppColors.textSecondary.withOpacity(0.3),
            ),
            Expanded(
              child: _buildTodayValueColumn(
                'Diastolic',
                'mmHg',
                bloodPressure.diastolic,
              ),
            ),
            Container(
              width: 1,
              height: 60,
              color: AppColors.textSecondary.withOpacity(0.3),
            ),
            Expanded(
              child: _buildTodayValueColumn(
                'Pulse',
                'BMP',
                bloodPressure.pulse,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Xây dựng cột giá trị cho Today card (label + unit + value)
  Widget _buildTodayValueColumn(String label, String unit, int value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          unit,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: const TextStyle(
            fontFamily: 'Montserrat',
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  /// Xây dựng content cho card historical
  Widget _buildHistoricalContent() {
    final statusColor = _getStatusColor(bloodPressure.status);
    return Row(
      children: [
        // Bên trái: Systolic và Diastolic
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                bloodPressure.systolic.toString(),
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                bloodPressure.diastolic.toString(),
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        // Đường phân cách dọc
        Container(
          width: 1,
          height: 60,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          color: AppColors.textSecondary.withOpacity(0.3),
        ),
        // Bên phải: Status và range
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                    bloodPressure.status,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      color: statusColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${bloodPressure.pulse} ${AppStrings.pulseBMP} ${bloodPressure.normalRange}',
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
