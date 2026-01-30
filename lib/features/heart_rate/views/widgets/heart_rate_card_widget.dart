import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:step_counter/core/constants/app_colors.dart';
import 'package:step_counter/features/heart_rate/model/heart_rate_model.dart';

/// Widget card hiển thị heart rate
class HeartRateCardWidget extends StatelessWidget {
  final HeartRateModel heartRate;
  final bool isToday;

  const HeartRateCardWidget({
    super.key,
    required this.heartRate,
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
          if (isToday) ...[
            const SizedBox(height: 16),
            _buildStatusCentered(),
            const SizedBox(height: 16),
            _buildCurrentBPMCentered(),
          ] else ...[
            const SizedBox(height: 16),
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
      timeText = 'Today ${DateFormat('h:mm a').format(heartRate.dateTime)}';
    } else {
      timeText =
          '${DateFormat('h:mm a').format(heartRate.dateTime)} - ${DateFormat('MMMM dd, yyyy').format(heartRate.dateTime)}';
    }

    return Row(
      children: [
        Expanded(
          child: Text(
            timeText,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
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

  /// Xây dựng status (Normal với green square) - căn giữa cho today
  Widget _buildStatusCentered() {
    const greenColor = Color(0xFF15D254);
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: greenColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            heartRate.status,
            style: const TextStyle(
              color: greenColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Xây dựng status (Normal với green square) - cho historical
  Widget _buildStatus() {
    const greenColor = Color(0xFF15D254);
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: greenColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          heartRate.status,
          style: const TextStyle(
            color: greenColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Xây dựng BPM hiện tại (large font cho today) - căn giữa
  Widget _buildCurrentBPMCentered() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            '${heartRate.bpm}',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 56,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.favorite, color: Colors.red, size: 20),
          const SizedBox(width: 4),
          const Text(
            'BMP',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Xây dựng nội dung cho historical card (2 cột với đường phân cách)
  Widget _buildHistoricalContent() {
    return Row(
      children: [
        // Cột trái: BPM value
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${heartRate.bpm}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  height: 1.0,
                ),
              ),
              const Text(
                'BMP',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ),
        // Đường phân cách dọc
        Container(
          width: 1,
          height: 70,
          color: const Color(0xFF3E4C6B),
          margin: const EdgeInsets.symmetric(horizontal: 8),
        ),
        // Cột phải: Status và normal range
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatus(),
              const SizedBox(height: 5),
              _buildNormalRange(),
            ],
          ),
        ),
      ],
    );
  }

  /// Xây dựng normal range
  Widget _buildNormalRange() {
    return Text(
      'Normal range: ${heartRate.normalRange}',
      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
    );
  }
}
