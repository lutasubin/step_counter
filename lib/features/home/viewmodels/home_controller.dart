import 'dart:async';
import 'package:get/get.dart';
import 'package:step_counter/core/di/di_setup.dart';
import 'package:step_counter/features/home/model/activity_data_model.dart';
import 'package:step_counter/features/home/service/step_counter_service.dart';
import 'package:step_counter/features/report/model/daily_activity_model.dart';
import 'package:step_counter/features/report/service/report_service.dart';

/// Controller quản lý logic của home screen
class HomeController extends GetxController {
  final StepCounterService _stepCounterService;
  final ReportService _reportService;
  final _activityData = ActivityDataModel.empty().obs;
  final _isCounting = false.obs;
  final _elapsedSeconds = 0.obs;

  StreamSubscription<int>? _stepSubscription;
  Timer? _timer;

  HomeController(this._stepCounterService)
    : _reportService = getIt<ReportService>();

  /// Dữ liệu hoạt động
  ActivityDataModel get activityData => _activityData.value;

  /// Đang đếm bước
  bool get isCounting => _isCounting.value;

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  @override
  void onClose() {
    _stepSubscription?.cancel();
    _timer?.cancel();
    super.onClose();
  }

  /// Load dữ liệu ban đầu
  void _loadData() {
    // Load data từ local storage nếu có
  }

  /// Bắt đầu đếm bước
  Future<void> startCounting() async {
    if (_isCounting.value) return;

    final hasPermission = await _stepCounterService.checkAndRequestPermission();
    if (!hasPermission) {
      Get.snackbar('Lỗi', 'Cần quyền đếm bước chân');
      return;
    }

    _isCounting.value = true;
    _elapsedSeconds.value = 0;

    // Reset số bước ban đầu và dữ liệu về 0
    _stepCounterService.resetInitialSteps();
    _activityData.value = ActivityDataModel.empty();

    // Bắt đầu timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedSeconds.value++;
      _updateDuration();
    });

    // Lắng nghe step stream
    _stepSubscription = _stepCounterService.getStepStream().listen((steps) {
      _updateActivityData(steps);
    });
  }

  /// Dừng đếm bước
  void stopCounting() async {
    if (!_isCounting.value) return;

    _isCounting.value = false;
    _stepSubscription?.cancel();
    _timer?.cancel();

    // Lưu dữ liệu vào report
    await _saveActivityData();
  }

  /// Lưu dữ liệu hoạt động
  Future<void> _saveActivityData() async {
    final today = DateTime.now();
    final date = DateTime(today.year, today.month, today.day);

    // Lấy số bước thật từ pedometer để đảm bảo chính xác
    final realSteps = await _stepCounterService.getTodaySteps();
    final stepsToSave = realSteps > 0
        ? realSteps
        : _activityData.value.stepCount;

    final activity = DailyActivityModel(
      date: date,
      steps: stepsToSave,
      calories: _stepCounterService.calculateCalories(stepsToSave),
      distance: _stepCounterService.calculateDistance(stepsToSave),
      durationSeconds: _elapsedSeconds.value,
    );

    // Debug: In ra để kiểm tra
    print('HomeController: Saving activity data');
    print('Steps: ${activity.steps}');
    print('Calories: ${activity.calories}');
    print('Distance: ${activity.distance}');
    print('Duration: ${activity.durationSeconds}s');
    print('Date: ${activity.date}');

    await _reportService.saveActivity(activity);

    print('HomeController: Activity data saved successfully');
  }

  /// Cập nhật dữ liệu hoạt động
  void _updateActivityData(int steps) {
    final calories = _stepCounterService.calculateCalories(steps);
    final distance = _stepCounterService.calculateDistance(steps);
    final duration = _stepCounterService.formatDuration(_elapsedSeconds.value);

    _activityData.value = ActivityDataModel(
      stepCount: steps,
      calories: calories,
      distance: distance,
      duration: duration,
    );
  }

  /// Cập nhật thời gian
  void _updateDuration() {
    final duration = _stepCounterService.formatDuration(_elapsedSeconds.value);
    _activityData.value = _activityData.value.copyWith(duration: duration);
  }

  /// Toggle đếm bước (play/pause)
  Future<void> toggleCounting() async {
    if (_isCounting.value) {
      stopCounting();
    } else {
      await startCounting();
    }
  }
}
