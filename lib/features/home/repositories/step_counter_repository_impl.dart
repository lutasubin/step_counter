import 'dart:io';

import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:step_counter/features/home/repositories/step_counter_repository.dart';

/// Implementation của StepCounterRepository
class StepCounterRepositoryImpl implements StepCounterRepository {
  int _initialSteps = 0;
  bool _isInitialized = false;
  static const String _todayStepsKey = 'today_initial_steps';
  static const String _todayDateKey = 'today_date';

  @override
  Future<bool> checkPermission() async {
    if (!Platform.isAndroid) {
      return true;
    }
    final status = await Permission.activityRecognition.status;
    return status.isGranted;
  }

  @override
  Future<bool> requestPermission() async {
    if (!Platform.isAndroid) {
      return true;
    }
    final status = await Permission.activityRecognition.request();
    return status.isGranted;
  }

  @override
  Future<int> getCurrentSteps() async {
    if (!_isInitialized) {
      await _initializePedometer();
    }
    return _initialSteps;
  }

  @override
  Stream<int> getStepStream() async* {
    await for (final stepCount in Pedometer.stepCountStream) {
      // Khởi tạo _initialSteps ngay tại lần event đầu tiên để không bỏ lỡ bước
      if (!_isInitialized) {
        _initialSteps = stepCount.steps;
        _isInitialized = true;
      }

      final currentSteps = stepCount.steps;
      final steps = currentSteps - _initialSteps;
      yield steps > 0 ? steps : 0;
    }
  }

  /// Khởi tạo pedometer và lấy số bước ban đầu
  Future<void> _initializePedometer() async {
    try {
      final initialStepCount = await Pedometer.stepCountStream.first;
      _initialSteps = initialStepCount.steps;
      _isInitialized = true;
    } catch (e) {
      _initialSteps = 0;
      _isInitialized = true;
    }
  }

  /// Reset số bước ban đầu (reinitialize để lấy số bước mới)
  @override
  void resetInitialSteps() {
    _isInitialized = false;
    _initialSteps = 0;
  }

  /// Lấy số bước hiện tại của ngày (từ pedometer, không reset)
  @override
  Future<int> getTodaySteps() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now();
      final todayDateStr = '${today.year}-${today.month}-${today.day}';

      // Kiểm tra xem đã có số bước ban đầu của ngày chưa
      final savedDate = prefs.getString(_todayDateKey);
      int todayInitialSteps = 0;

      if (savedDate != todayDateStr) {
        // Ngày mới, lấy số bước hiện tại làm số bước ban đầu
        if (!_isInitialized) {
          await _initializePedometer();
        }
        final currentStepCount = await Pedometer.stepCountStream.first;
        todayInitialSteps = currentStepCount.steps;

        // Lưu số bước ban đầu của ngày
        await prefs.setInt(_todayStepsKey, todayInitialSteps);
        await prefs.setString(_todayDateKey, todayDateStr);
      } else {
        // Đã có số bước ban đầu của ngày
        todayInitialSteps = prefs.getInt(_todayStepsKey) ?? 0;
      }

      // Lấy số bước hiện tại từ pedometer
      if (!_isInitialized) {
        await _initializePedometer();
      }
      final currentStepCount = await Pedometer.stepCountStream.first;
      final currentSteps = currentStepCount.steps;

      // Tính số bước của ngày = số bước hiện tại - số bước ban đầu của ngày
      final todaySteps = currentSteps - todayInitialSteps;
      return todaySteps > 0 ? todaySteps : 0;
    } catch (e) {
      print('Error getting today steps: $e');
      return 0;
    }
  }
}
