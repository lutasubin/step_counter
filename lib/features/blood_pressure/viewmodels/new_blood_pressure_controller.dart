import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:step_counter/core/di/di_setup.dart';
import 'package:step_counter/features/blood_pressure/model/blood_pressure_model.dart';
import 'package:step_counter/features/blood_pressure/repositories/blood_pressure_repository.dart';
import 'package:step_counter/features/blood_pressure/viewmodels/blood_pressure_controller.dart';
import 'package:step_counter/features/blood_pressure/views/widgets/blood_pressure_info_bottom_sheet.dart';

/// Controller quản lý logic của new blood pressure screen
class NewBloodPressureController extends GetxController {
  final BloodPressureRepository _repository = getIt<BloodPressureRepository>();
  final _dateTime = DateTime.now().obs;
  final _systolic = 100.0.obs;
  final _diastolic = 75.0.obs;
  final _pulse = 70.0.obs;
  final _isSaving = false.obs;

  /// DateTime được chọn
  DateTime get dateTime => _dateTime.value;
  set dateTime(DateTime value) => _dateTime.value = value;

  /// Systolic value
  int get systolic => _systolic.value.toInt();
  set systolic(int value) => _systolic.value = value.toDouble();

  /// Diastolic value
  int get diastolic => _diastolic.value.toInt();
  set diastolic(int value) => _diastolic.value = value.toDouble();

  /// Pulse value
  int get pulse => _pulse.value.toInt();
  set pulse(int value) => _pulse.value = value.toDouble();

  /// Đang lưu
  bool get isSaving => _isSaving.value;

  /// Status dựa trên systolic và diastolic (6 categories)
  String get status {
    if (systolic < 90 || diastolic < 60) {
      return 'Hypotension';
    } else if (systolic >= 90 && systolic <= 119 && diastolic >= 60 && diastolic <= 79) {
      return 'Normal';
    } else if (systolic >= 120 && systolic <= 129 && diastolic >= 60 && diastolic <= 79) {
      return 'Elevated';
    } else if (systolic >= 130 && systolic <= 139 && diastolic >= 80 && diastolic <= 89) {
      return 'Stage 1';
    } else if ((systolic >= 140 && systolic <= 180) || (diastolic >= 90 && diastolic <= 120)) {
      return 'Stage 2';
    } else {
      return 'Hypertensive';
    }
  }

  /// Normal range text
  String get normalRange => 'SYS 90-119 and DIA 60-79';

  /// Format date time để hiển thị
  String get formattedDateTime {
    final dateFormat = DateFormat('h:mm a - MMM d, yyyy', 'en_US');
    return dateFormat.format(_dateTime.value);
  }

  /// Lưu blood pressure
  Future<void> saveBloodPressure() async {
    try {
      _isSaving.value = true;

      final bloodPressure = BloodPressureModel(
        dateTime: _dateTime.value,
        systolic: systolic,
        diastolic: diastolic,
        pulse: pulse,
        status: status,
        normalRange: normalRange,
      );

      await _repository.saveBloodPressure(bloodPressure);

      // Refresh danh sách
      final bloodPressureController = Get.find<BloodPressureController>();
      await bloodPressureController.refreshBloodPressures();

      // Hiển thị bottom sheet Information
      Get.bottomSheet(
        const BloodPressureInfoBottomSheet(),
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        isDismissible: false,
        enableDrag: false,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Không thể lưu huyết áp. Vui lòng thử lại.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isSaving.value = false;
    }
  }
}
