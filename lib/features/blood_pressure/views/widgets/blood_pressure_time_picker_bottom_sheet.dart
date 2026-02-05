import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:step_counter/core/constants/app_colors.dart';
import 'package:step_counter/core/constants/app_strings.dart';
import 'package:step_counter/features/blood_pressure/viewmodels/new_blood_pressure_controller.dart';

/// Bottom sheet để chọn date và time
class BloodPressureTimePickerBottomSheet extends StatefulWidget {
  const BloodPressureTimePickerBottomSheet({super.key});

  @override
  State<BloodPressureTimePickerBottomSheet> createState() =>
      _BloodPressureTimePickerBottomSheetState();
}

class _BloodPressureTimePickerBottomSheetState
    extends State<BloodPressureTimePickerBottomSheet> {
  late DateTime _selectedDateTime;
  late FixedExtentScrollController _yearController;
  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _dayController;
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;
  late FixedExtentScrollController _ampmController;

  @override
  void initState() {
    super.initState();
    final controller = Get.find<NewBloodPressureController>();
    _selectedDateTime = controller.dateTime;

    // Khởi tạo controllers với giá trị hiện tại
    _yearController = FixedExtentScrollController(
      initialItem: _selectedDateTime.year - 2020,
    );
    _monthController = FixedExtentScrollController(
      initialItem: _selectedDateTime.month - 1,
    );
    _dayController = FixedExtentScrollController(
      initialItem: _selectedDateTime.day - 1,
    );
    _hourController = FixedExtentScrollController(
      initialItem: _selectedDateTime.hour % 12 == 0
          ? 11
          : (_selectedDateTime.hour % 12) - 1,
    );
    _minuteController = FixedExtentScrollController(
      initialItem: _selectedDateTime.minute,
    );
    _ampmController = FixedExtentScrollController(
      initialItem: _selectedDateTime.hour >= 12 ? 1 : 0,
    );
  }

  @override
  void dispose() {
    _yearController.dispose();
    _monthController.dispose();
    _dayController.dispose();
    _hourController.dispose();
    _minuteController.dispose();
    _ampmController.dispose();
    super.dispose();
  }

  void _updateDateTime() {
    final year = 2020 + _yearController.selectedItem;
    final month = _monthController.selectedItem + 1;
    final day = _dayController.selectedItem + 1;
    final hour12 = _hourController.selectedItem + 1;
    final minute = _minuteController.selectedItem;
    final isPM = _ampmController.selectedItem == 1;
    final hour = isPM
        ? (hour12 == 12 ? 12 : hour12 + 12)
        : (hour12 == 12 ? 0 : hour12);

    // Kiểm tra ngày hợp lệ
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final validDay = day > daysInMonth ? daysInMonth : day;

    setState(() {
      _selectedDateTime = DateTime(year, month, validDay, hour, minute);
    });

    // Cập nhật day controller nếu cần
    if (day > daysInMonth) {
      _dayController.jumpToItem(daysInMonth - 1);
    }
  }

  void _onDone() {
    final controller = Get.find<NewBloodPressureController>();
    controller.dateTime = _selectedDateTime;

    // Chỉ đóng bottom sheet chọn thời gian, không show Information ở đây nữa
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.homeBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(
              children: [
                const Text(
                  AppStrings.timeSetting,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          // Date Picker
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPickerColumn(
                  label: 'Year',
                  controller: _yearController,
                  itemCount: 7, // 2020-2026
                  itemBuilder: (index) => (2020 + index).toString(),
                  onChanged: () => _updateDateTime(),
                ),
                _buildPickerColumn(
                  label: 'Month',
                  controller: _monthController,
                  itemCount: 12,
                  itemBuilder: (index) =>
                      (index + 1).toString().padLeft(2, '0'),
                  onChanged: () {
                    _updateDateTime();
                    // Cập nhật số ngày khi tháng thay đổi
                    final daysInMonth = DateTime(
                      _selectedDateTime.year,
                      _selectedDateTime.month + 1,
                      0,
                    ).day;
                    if (_dayController.selectedItem >= daysInMonth) {
                      _dayController.jumpToItem(daysInMonth - 1);
                    }
                  },
                ),
                _buildPickerColumn(
                  label: 'Day',
                  controller: _dayController,
                  itemCount: DateTime(
                    _selectedDateTime.year,
                    _selectedDateTime.month + 1,
                    0,
                  ).day,
                  itemBuilder: (index) =>
                      (index + 1).toString().padLeft(2, '0'),
                  onChanged: () => _updateDateTime(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Time Picker
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPickerColumn(
                  label: 'Hour',
                  controller: _hourController,
                  itemCount: 12,
                  itemBuilder: (index) =>
                      (index + 1).toString().padLeft(2, '0'),
                  onChanged: () => _updateDateTime(),
                ),
                _buildPickerColumn(
                  label: 'Minute',
                  controller: _minuteController,
                  itemCount: 60,
                  itemBuilder: (index) => index.toString().padLeft(2, '0'),
                  onChanged: () => _updateDateTime(),
                ),
                _buildPickerColumn(
                  label: '',
                  controller: _ampmController,
                  itemCount: 2,
                  itemBuilder: (index) => index == 0 ? 'AM' : 'PM',
                  onChanged: () => _updateDateTime(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // DONE Button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _onDone,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
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
          ),
        ],
      ),
    );
  }

  Widget _buildPickerColumn({
    required String label,
    required FixedExtentScrollController controller,
    required int itemCount,
    required String Function(int) itemBuilder,
    required VoidCallback onChanged,
  }) {
    return Expanded(
      child: Column(
        children: [
          if (label.isNotEmpty)
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          if (label.isNotEmpty) const SizedBox(height: 8),
          SizedBox(
            height: 150,
            child: ListWheelScrollView.useDelegate(
              itemExtent: 40,
              physics: const FixedExtentScrollPhysics(),
              controller: controller,
              onSelectedItemChanged: (index) => onChanged(),
              childDelegate: ListWheelChildBuilderDelegate(
                builder: (context, index) {
                  final itemValue = itemBuilder(index);
                  final isSelected = index == controller.selectedItem;

                  return Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.buttonOrange.withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        itemValue,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          color: isSelected
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          fontSize: 20,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
                childCount: itemCount,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
