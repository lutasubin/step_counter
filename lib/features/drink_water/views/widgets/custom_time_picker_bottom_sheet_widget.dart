import 'package:flutter/material.dart';
import 'package:step_counter/core/constants/app_colors.dart';
import 'package:step_counter/core/constants/app_strings.dart';
import 'package:step_counter/features/drink_water/viewmodels/drink_water_settings_controller.dart';

/// Widget bottom sheet cho time picker
class CustomTimePickerBottomSheetWidget extends StatefulWidget {
  final DrinkWaterSettingsController controller;
  final bool isStartTime;

  const CustomTimePickerBottomSheetWidget({
    super.key,
    required this.controller,
    required this.isStartTime,
  });

  @override
  State<CustomTimePickerBottomSheetWidget> createState() =>
      _CustomTimePickerBottomSheetWidgetState();
}

class _CustomTimePickerBottomSheetWidgetState
    extends State<CustomTimePickerBottomSheetWidget> {
  late int _selectedHour;
  late int _selectedMinute;
  late bool _isPM;

  @override
  void initState() {
    super.initState();
    _parseCurrentTime();
  }

  /// Parse time hiện tại từ controller
  void _parseCurrentTime() {
    final currentTimeStr = widget.isStartTime
        ? widget.controller.startTime
        : widget.controller.endTime;

    try {
      final parts = currentTimeStr.split(' ');
      final timeParts = parts[0].split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      final isPM = parts[1] == 'PM';

      // Chuyển đổi hour từ 1-12 format
      _selectedHour = hour == 12 ? 12 : hour;
      _selectedMinute = minute;
      _isPM = isPM;
    } catch (e) {
      _selectedHour = widget.isStartTime ? 9 : 9;
      _selectedMinute = 0;
      _isPM = widget.isStartTime ? false : true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(),
          _buildTimePicker(),
          _buildDoneButton(context, mediaQuery),
        ],
      ),
    );
  }

  /// Xây dựng title
  Widget _buildTitle() {
    final title = widget.isStartTime
        ? '${AppStrings.startTime} setting'
        : '${AppStrings.endTime} setting';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Montserrat',
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  /// Xây dựng time picker với 3 cột
  Widget _buildTimePicker() {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.metricsBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Hour column
          Expanded(
            child: _buildPickerColumn(
              items: List.generate(12, (index) => index + 1),
              selectedIndex: _selectedHour == 0 ? 11 : _selectedHour - 1,
              onSelectedItemChanged: (index) {
                setState(() {
                  _selectedHour = index + 1;
                });
              },
            ),
          ),
          // Minute column
          Expanded(
            child: _buildPickerColumn(
              items: List.generate(60, (index) => index),
              selectedIndex: _selectedMinute,
              onSelectedItemChanged: (index) {
                setState(() {
                  _selectedMinute = index;
                });
              },
            ),
          ),
          // AM/PM column
          Expanded(
            child: _buildPickerColumn(
              items: const ['AM', 'PM'],
              selectedIndex: _isPM ? 1 : 0,
              onSelectedItemChanged: (index) {
                setState(() {
                  _isPM = index == 1;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Xây dựng một cột picker
  Widget _buildPickerColumn<T>({
    required List<T> items,
    required int selectedIndex,
    required ValueChanged<int> onSelectedItemChanged,
  }) {
    return ListWheelScrollView.useDelegate(
      itemExtent: 50,
      diameterRatio: 1.5,
      physics: const FixedExtentScrollPhysics(),
      controller: FixedExtentScrollController(initialItem: selectedIndex),
      onSelectedItemChanged: onSelectedItemChanged,
      childDelegate: ListWheelChildBuilderDelegate(
        builder: (context, index) {
          if (index < 0 || index >= items.length) {
            return null;
          }
          final item = items[index];
          final isSelected = index == selectedIndex;

          return Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.cardBackground : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              item.toString().padLeft(2, '0'),
              style: TextStyle(
                fontFamily: 'Montserrat',
                color: isSelected
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
                fontSize: 18,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
              ),
            ),
          );
        },
        childCount: items.length,
      ),
    );
  }

  /// Xây dựng button DONE
  Widget _buildDoneButton(BuildContext context, MediaQueryData mediaQuery) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, mediaQuery.padding.bottom + 20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            // Format time thành "HH:MM AM/PM"
            final timeString =
                '${_selectedHour.toString().padLeft(2, '0')}:${_selectedMinute.toString().padLeft(2, '0')} ${_isPM ? 'PM' : 'AM'}';

            if (widget.isStartTime) {
              widget.controller.updateStartTime(timeString);
            } else {
              widget.controller.updateEndTime(timeString);
            }

            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.buttonOrange,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            AppStrings.done,
            style: TextStyle(
              fontFamily: 'Montserrat',
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
