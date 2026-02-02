import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:step_counter/core/di/di_setup.dart';
import 'package:step_counter/features/drink_water/service/drink_water_notification_service.dart';

/// Controller quản lý settings của drink water
class DrinkWaterSettingsController extends GetxController {
  // Keys cho SharedPreferences
  static const String _keyDrinkingGoal = 'drink_water_goal';
  static const String _keyCupCapacity = 'drink_water_cup_capacity';
  static const String _keyRemind = 'drink_water_remind';
  static const String _keyStartTime = 'drink_water_start_time';
  static const String _keyEndTime = 'drink_water_end_time';
  static const String _keyInterval = 'drink_water_interval';
  static const String _keyIntervalType =
      'drink_water_interval_type'; // 'hours' hoặc 'minutes'

  // Giá trị mặc định
  static const int _defaultGoal = 2000; // ml
  static const int _defaultCupCapacity = 250; // ml
  static const bool _defaultRemind = false;
  static const String _defaultStartTime = '09:00 AM';
  static const String _defaultEndTime = '09:00 PM';
  static const int _defaultInterval = 2; // hours

  // Danh sách options cho bottom sheet
  final List<int> _goalOptions = [1000, 1500, 2000, 2500, 3000, 3500];

  final List<int> _cupCapacityOptions = [200, 250, 300, 350, 400, 500];

  // Observable values
  final _drinkingGoal = _defaultGoal.obs;
  final _cupCapacity = _defaultCupCapacity.obs;
  final _remind = _defaultRemind.obs;
  final _startTime = _defaultStartTime.obs;
  final _endTime = _defaultEndTime.obs;
  final _interval = _defaultInterval.obs;

  // Getters
  int get drinkingGoal => _drinkingGoal.value;
  int get cupCapacity => _cupCapacity.value;
  bool get remind => _remind.value;
  String get startTime => _startTime.value;
  String get endTime => _endTime.value;
  int get interval => _interval.value;
  List<int> get goalOptions => _goalOptions;
  List<int> get cupCapacityOptions => _cupCapacityOptions;

  // Interval options (hours)
  final List<int> intervalOptions = [1, 2, 3, 4, 6, 8];

  // Interval options (minutes)
  final List<int> _intervalMinutesOptions = [1, 2, 5, 10, 15, 30];
  List<int> get intervalMinutesOptions => _intervalMinutesOptions;

  // Interval type: 'hours' hoặc 'minutes'
  final _intervalType = 'hours'.obs;
  String get intervalType => _intervalType.value;

  // Loading state khi đang save
  final _isSaving = false.obs;
  bool get isSaving => _isSaving.value;

  // Notification service (lazy load từ DI)
  DrinkWaterNotificationService get _notificationService =>
      getIt<DrinkWaterNotificationService>();

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  /// Load settings từ SharedPreferences
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _drinkingGoal.value = prefs.getInt(_keyDrinkingGoal) ?? _defaultGoal;
      _cupCapacity.value = prefs.getInt(_keyCupCapacity) ?? _defaultCupCapacity;
      _remind.value = prefs.getBool(_keyRemind) ?? _defaultRemind;
      _startTime.value = prefs.getString(_keyStartTime) ?? _defaultStartTime;
      _endTime.value = prefs.getString(_keyEndTime) ?? _defaultEndTime;
      _interval.value = prefs.getInt(_keyInterval) ?? _defaultInterval;
      _intervalType.value = prefs.getString(_keyIntervalType) ?? 'hours';

      // Nếu remind đã bật, schedule lại notifications
      if (_remind.value) {
        await _scheduleNotifications();
      }
    } catch (e) {
      print('Error loading drink water settings: $e');
    }
  }

  /// Cập nhật drinking goal
  void updateDrinkingGoal(int value) {
    _drinkingGoal.value = value;
  }

  /// Cập nhật cup capacity
  void updateCupCapacity(int value) {
    _cupCapacity.value = value;
  }

  /// Toggle remind
  Future<void> toggleRemind() async {
    _remind.value = !_remind.value;
    try {
      // Nếu tắt remind, hủy tất cả notifications
      if (!_remind.value) {
        await _notificationService.cancelAllReminders();
      } else {
        // Nếu bật remind, schedule notifications
        await _scheduleNotifications();
      }
    } catch (e) {
      print('Error in toggleRemind: $e');
    }
  }

  /// Cập nhật start time
  void updateStartTime(String value) {
    _startTime.value = value;
  }

  /// Cập nhật end time
  void updateEndTime(String value) {
    _endTime.value = value;
  }

  /// Cập nhật interval
  void updateInterval(int value) {
    _interval.value = value;
  }

  /// Cập nhật interval type
  void updateIntervalType(String type) {
    _intervalType.value = type;
  }

  /// Lưu settings
  Future<void> saveSettings() async {
    if (_isSaving.value) return; // Tránh double click

    try {
      _isSaving.value = true;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyDrinkingGoal, _drinkingGoal.value);
      await prefs.setInt(_keyCupCapacity, _cupCapacity.value);
      await prefs.setBool(_keyRemind, _remind.value);
      await prefs.setString(_keyStartTime, _startTime.value);
      await prefs.setString(_keyEndTime, _endTime.value);
      await prefs.setInt(_keyInterval, _interval.value);
      await prefs.setString(_keyIntervalType, _intervalType.value);

      try {
        // Nếu remind đã bật, schedule lại notifications với settings mới
        if (_remind.value) {
          await _scheduleNotifications();
        } else {
          // Nếu tắt remind, hủy tất cả notifications
          await _notificationService.cancelAllReminders();
        }
      } catch (e) {
        print('Error in saveSettings notifications: $e');
      }

      _isSaving.value = false;
      Get.back(); // Quay lại màn hình trước
    } catch (e) {
      _isSaving.value = false;
      print('Error saving drink water settings: $e');
    }
  }

  /// Schedule notifications dựa trên settings hiện tại
  Future<void> _scheduleNotifications() async {
    try {
      if (_intervalType.value == 'minutes') {
        // Nếu interval là phút, chuyển đổi sang giờ (chia 60)
        await _notificationService.scheduleReminders(
          startTime: _startTime.value,
          endTime: _endTime.value,
          intervalHours: _interval.value / 60.0, // Chuyển phút sang giờ
        );
      } else {
        // Interval là giờ
        await _notificationService.scheduleReminders(
          startTime: _startTime.value,
          endTime: _endTime.value,
          intervalHours: _interval.value.toDouble(),
        );
      }
    } catch (e) {
      print('Error scheduling notifications: $e');
    }
  }
}
