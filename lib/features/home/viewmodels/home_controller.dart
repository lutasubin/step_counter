import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:step_counter/core/di/di_setup.dart';
import 'package:step_counter/core/services/notification_service.dart';
import 'package:step_counter/features/home/model/activity_data_model.dart';
import 'package:step_counter/features/home/service/step_counter_service.dart';
import 'package:step_counter/features/report/model/daily_activity_model.dart';
import 'package:step_counter/features/report/service/report_service.dart';

/// Controller quản lý logic của home screen
class HomeController extends GetxController with WidgetsBindingObserver {
  final StepCounterService _stepCounterService;
  final ReportService _reportService;
  final NotificationService _notificationService;
  final _activityData = ActivityDataModel.empty().obs;
  final _isCounting = false.obs;
  final _elapsedSeconds = 0.obs;

  StreamSubscription<int>? _stepSubscription;
  Timer? _timer;
  Timer? _stepPollingTimer;
  int _lastPolledSteps = 0;
  DateTime? _startTime; // Thời điểm bắt đầu đếm
  int _accumulatedDurationSeconds =
      0; // Thời gian đã tích lũy từ các lần đếm trước
  static const String _isCountingKey = 'home_is_counting';
  static const String _savedElapsedSecondsKey = 'home_saved_elapsed_seconds';
  static const String _savedStepsKey = 'home_saved_steps';
  static const String _startTimeKey =
      'home_start_time'; // Lưu timestamp bắt đầu

  HomeController(this._stepCounterService)
    : _reportService = getIt<ReportService>(),
      _notificationService = getIt<NotificationService>();

  /// Dữ liệu hoạt động
  ActivityDataModel get activityData => _activityData.value;

  /// Đang đếm bước
  bool get isCounting => _isCounting.value;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _stepSubscription?.cancel();
    _timer?.cancel();
    _stepPollingTimer?.cancel();
    super.onClose();
  }

  /// Xử lý khi app lifecycle thay đổi (foreground/background)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (!_isCounting.value) return;

    if (state == AppLifecycleState.resumed) {
      // App quay lại foreground - tính lại thời gian dựa trên startTime
      _recalculateElapsedTime();
    }
    // Không cần xử lý khi app vào background vì thời gian vẫn được tính dựa trên timestamp
  }

  /// Tính lại thời gian đã trôi qua dựa trên startTime
  void _recalculateElapsedTime() {
    if (_startTime == null) return;

    final now = DateTime.now();
    final elapsedSinceStart = now.difference(_startTime!).inSeconds;
    _elapsedSeconds.value = _accumulatedDurationSeconds + elapsedSinceStart;
    _updateDuration();
  }

  /// Load dữ liệu ban đầu
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final isCountingSaved = prefs.getBool(_isCountingKey) ?? false;

    // Nếu trước khi tắt app đang đếm thì tự động đếm lại
    if (isCountingSaved && !_isCounting.value) {
      await startCounting();
    }
  }

  /// Bắt đầu đếm bước
  Future<void> startCounting() async {
    if (_isCounting.value) return;

    final hasPermission = await _stepCounterService.checkAndRequestPermission();
    if (!hasPermission) {
      Get.snackbar('Lỗi', 'Cần quyền đếm bước chân');
      return;
    }

    // Lấy số bước hiện tại từ DB để tiếp tục
    final today = DateTime.now();
    final date = DateTime(today.year, today.month, today.day);
    final existingActivity = await _reportService.getActivityByDate(date);

    // Số bước đã tích lũy từ DB (nếu có)
    final accumulatedSteps = existingActivity?.steps ?? 0;
    final accumulatedCalories = existingActivity?.calories ?? 0.0;
    final accumulatedDuration = existingActivity?.durationSeconds ?? 0;

    _isCounting.value = true;

    // Lưu thời gian đã tích lũy từ các lần đếm trước
    _accumulatedDurationSeconds = accumulatedDuration;

    // Kiểm tra xem có startTime đã lưu từ lần trước không
    final prefs = await SharedPreferences.getInstance();
    final savedStartTimeMillis = prefs.getInt(_startTimeKey);

    if (savedStartTimeMillis != null) {
      // Có startTime đã lưu - tiếp tục từ đó
      _startTime = DateTime.fromMillisecondsSinceEpoch(savedStartTimeMillis);
      // Tính lại thời gian đã trôi qua từ startTime đến bây giờ
      final now = DateTime.now();
      final elapsedSinceStart = now.difference(_startTime!).inSeconds;
      _elapsedSeconds.value = _accumulatedDurationSeconds + elapsedSinceStart;
    } else {
      // Không có startTime - bắt đầu mới
      _startTime = DateTime.now();
      _elapsedSeconds.value = _accumulatedDurationSeconds;
      // Lưu startTime
      await prefs.setInt(_startTimeKey, _startTime!.millisecondsSinceEpoch);
    }

    // Luôn reset số bước ban đầu để stream tính từ 0
    // Sau đó cộng dồn với số bước đã tích lũy
    _stepCounterService.resetInitialSteps();

    // Khởi tạo activityData với dữ liệu đã tích lũy
    _activityData.value = ActivityDataModel(
      stepCount: accumulatedSteps,
      calories: accumulatedCalories,
      distance: existingActivity?.distance ?? 0.0,
      duration: _stepCounterService.formatDuration(accumulatedDuration),
    );

    // Bắt đầu timer để cập nhật UI mỗi giây
    // Thời gian thực tế được tính dựa trên timestamp, không phải đếm giây
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isCounting.value) {
        timer.cancel();
        return;
      }
      // Tính lại thời gian dựa trên startTime để đảm bảo chính xác
      _recalculateElapsedTime();
    });

    // Lắng nghe step stream và cộng dồn với số bước đã tích lũy
    _stepSubscription = _stepCounterService.getStepStream().listen((newSteps) {
      // newSteps là số bước mới từ stream (tính từ 0 sau khi reset)
      // Cộng dồn với số bước đã tích lũy từ DB
      final totalSteps = accumulatedSteps + newSteps;
      _lastPolledSteps = newSteps; // Lưu lại để polling so sánh
      _updateActivityData(totalSteps);
    });

    // Thêm polling timer để cập nhật nhanh hơn (mỗi 1 giây)
    // Đảm bảo cập nhật ngay cả khi stream chậm hoặc bỏ lỡ event
    // Polling sẽ đọc trực tiếp từ pedometer và so sánh với stream
    _stepPollingTimer = Timer.periodic(const Duration(seconds: 1), (
      timer,
    ) async {
      if (!_isCounting.value) {
        timer.cancel();
        return;
      }

      try {
        // Lấy số bước hiện tại từ pedometer (tổng số bước của ngày)
        final currentPedometerSteps = await _stepCounterService.getTodaySteps();

        // Tính số bước mới từ lúc play
        // currentPedometerSteps là tổng số bước của ngày
        // accumulatedSteps là số bước đã tích lũy từ DB (từ các lần play trước)
        // Số bước mới trong session này = currentPedometerSteps - accumulatedSteps
        final newStepsFromPolling = currentPedometerSteps - accumulatedSteps;

        // Chỉ cập nhật nếu polling phát hiện số bước mới hơn stream
        // (để tránh conflict với stream, chỉ update khi polling > stream)
        if (newStepsFromPolling > _lastPolledSteps &&
            newStepsFromPolling >= 0) {
          final totalSteps = accumulatedSteps + newStepsFromPolling;
          _lastPolledSteps = newStepsFromPolling;
          _updateActivityData(totalSteps);
        }
      } catch (e) {
        // Bỏ qua lỗi khi polling (stream vẫn hoạt động)
        print('Error polling steps: $e');
      }
    });

    // Lưu trạng thái đang đếm để lần sau mở app tự resume
    await prefs.setBool(_isCountingKey, true);

    // Hiển thị notification với dữ liệu đã tích lũy
    await _notificationService.showCountingNotification(
      steps: accumulatedSteps,
      calories: accumulatedCalories,
    );
  }

  /// Dừng đếm bước
  void stopCounting() async {
    if (!_isCounting.value) return;

    _isCounting.value = false;
    _stepSubscription?.cancel();
    _timer?.cancel();
    _stepPollingTimer?.cancel();

    // Tính lại thời gian cuối cùng trước khi lưu
    _recalculateElapsedTime();

    // Lưu dữ liệu vào report trước
    await _saveActivityData();

    // Lưu lại trạng thái đã dừng và dữ liệu hiện tại để lần sau play lại tiếp tục
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isCountingKey, false);

    // Xóa startTime vì đã dừng đếm
    await prefs.remove(_startTimeKey);

    // Lưu số bước và thời gian hiện tại để lần sau play lại tiếp tục
    await prefs.setInt(_savedElapsedSecondsKey, _elapsedSeconds.value);
    await prefs.setInt(_savedStepsKey, _activityData.value.stepCount);

    // Reset startTime
    _startTime = null;
    _accumulatedDurationSeconds = 0;

    // Ẩn notification khi dừng đếm
    await _notificationService.hideCountingNotification();
  }

  /// Lưu dữ liệu hoạt động
  Future<void> _saveActivityData() async {
    final today = DateTime.now();
    final date = DateTime(today.year, today.month, today.day);

    // Sử dụng số bước hiện tại từ activityData (đã được cộng dồn)
    final stepsToSave = _activityData.value.stepCount;

    // Tính lại thời gian trước khi lưu để đảm bảo chính xác
    _recalculateElapsedTime();
    final totalDuration = _elapsedSeconds.value;

    final activity = DailyActivityModel(
      date: date,
      steps: stepsToSave,
      calories: _activityData.value.calories,
      distance: _activityData.value.distance,
      durationSeconds: totalDuration,
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
  void _updateActivityData(int totalSteps) {
    // Tính calories và distance từ tổng số bước
    final calories = _stepCounterService.calculateCalories(totalSteps);
    final distance = _stepCounterService.calculateDistance(totalSteps);
    final duration = _stepCounterService.formatDuration(_elapsedSeconds.value);

    _activityData.value = ActivityDataModel(
      stepCount: totalSteps,
      calories: calories,
      distance: distance,
      duration: duration,
    );

    // Cập nhật notification với dữ liệu mới
    if (_isCounting.value) {
      _notificationService.updateCountingNotification(
        steps: totalSteps,
        calories: calories,
      );
    }
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
