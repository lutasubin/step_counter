import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Controller quản lý settings của drink water
class DrinkWaterSettingsController extends GetxController {
  // Keys cho SharedPreferences
  static const String _keyDrinkingGoal = 'drink_water_goal';
  static const String _keyCupCapacity = 'drink_water_cup_capacity';
  static const String _keyRemind = 'drink_water_remind';
  static const String _keyStartTime = 'drink_water_start_time';
  static const String _keyEndTime = 'drink_water_end_time';
  static const String _keyInterval = 'drink_water_interval';

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
  void toggleRemind() {
    _remind.value = !_remind.value;
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

  /// Lưu settings
  Future<void> saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyDrinkingGoal, _drinkingGoal.value);
      await prefs.setInt(_keyCupCapacity, _cupCapacity.value);
      await prefs.setBool(_keyRemind, _remind.value);
      await prefs.setString(_keyStartTime, _startTime.value);
      await prefs.setString(_keyEndTime, _endTime.value);
      await prefs.setInt(_keyInterval, _interval.value);
      Get.back(); // Quay lại màn hình trước
    } catch (e) {
      print('Error saving drink water settings: $e');
    }
  }
}
