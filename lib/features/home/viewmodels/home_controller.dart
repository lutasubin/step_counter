import 'dart:async';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:step_counter/core/di/di_setup.dart';
import 'package:step_counter/core/services/notification_service.dart';
import 'package:step_counter/features/blood_pressure/model/blood_pressure_model.dart';
import 'package:step_counter/features/blood_pressure/repositories/blood_pressure_repository.dart';
import 'package:step_counter/features/drink_water/repositories/drink_water_repository.dart';
import 'package:step_counter/features/heart_rate/model/heart_rate_model.dart';
import 'package:step_counter/features/heart_rate/repositories/heart_rate_repository.dart';
import 'package:step_counter/features/home/model/activity_data_model.dart';
import 'package:step_counter/features/home/service/step_counter_service.dart';
import 'package:step_counter/features/report/model/daily_activity_model.dart';
import 'package:step_counter/features/report/service/report_service.dart';

/// Enum định nghĩa các loại home cards
enum HomeCardType {
  heartRate('heart_rate'),
  bloodPressure('blood_pressure'),
  drinkWater('drink_water');

  final String value;
  const HomeCardType(this.value);

  static HomeCardType? fromString(String value) {
    return HomeCardType.values.firstWhereOrNull((e) => e.value == value);
  }
}

/// Controller quản lý logic của home screen
class HomeController extends GetxController with WidgetsBindingObserver {
  final StepCounterService _stepCounterService;
  final ReportService _reportService;
  final NotificationService _notificationService;
  final HeartRateRepository _heartRateRepository;
  final BloodPressureRepository _bloodPressureRepository;
  final DrinkWaterRepository _drinkWaterRepository;
  final _activityData = ActivityDataModel.empty().obs;
  final _isCounting = false.obs;
  final _elapsedSeconds = 0.obs;

  // Dữ liệu cho các home cards
  final _latestHeartRate = Rxn<HeartRateModel>();
  final _latestBloodPressure = Rxn<BloodPressureModel>();
  final _hasHeartRateData = false.obs;
  final _hasBloodPressureData = false.obs;
  final _hasDrinkWaterData = false.obs;
  final _drinkWaterCurrentAmount = 0.obs;
  final _drinkWaterGoal = 2000.obs;
  final _drinkWaterCupCapacity = 250.obs;

  // Quản lý thứ tự và visibility của cards
  final _cardOrder = <HomeCardType>[].obs;
  final _cardVisibility = <HomeCardType, bool>{
    HomeCardType.heartRate: true,
    HomeCardType.bloodPressure: true,
    HomeCardType.drinkWater: true,
  }.obs;
  static const String _cardOrderKey = 'home_card_order';
  static const String _cardVisibilityKey = 'home_card_visibility';

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
      _notificationService = getIt<NotificationService>(),
      _heartRateRepository = getIt<HeartRateRepository>(),
      _bloodPressureRepository = getIt<BloodPressureRepository>(),
      _drinkWaterRepository = getIt<DrinkWaterRepository>();

  /// Dữ liệu hoạt động
  ActivityDataModel get activityData => _activityData.value;

  /// Đang đếm bước
  bool get isCounting => _isCounting.value;

  /// Heart rate mới nhất
  HeartRateModel? get latestHeartRate => _latestHeartRate.value;

  /// Blood pressure mới nhất
  BloodPressureModel? get latestBloodPressure => _latestBloodPressure.value;

  /// Có dữ liệu heart rate
  bool get hasHeartRateData => _hasHeartRateData.value;

  /// Có dữ liệu blood pressure
  bool get hasBloodPressureData => _hasBloodPressureData.value;

  /// Có dữ liệu drink water
  bool get hasDrinkWaterData => _hasDrinkWaterData.value;

  /// Drink water current amount
  int get drinkWaterCurrentAmount => _drinkWaterCurrentAmount.value;

  /// Drink water goal
  int get drinkWaterGoal => _drinkWaterGoal.value;

  /// Drink water cup capacity
  int get drinkWaterCupCapacity => _drinkWaterCupCapacity.value;

  /// Thứ tự các cards
  List<HomeCardType> get cardOrder => _cardOrder;

  /// Kiểm tra card có visible không
  bool isCardVisible(HomeCardType cardType) {
    return _cardVisibility[cardType] ?? true;
  }

  /// Kiểm tra card có data và visible không
  bool shouldShowCard(HomeCardType cardType) {
    if (!isCardVisible(cardType)) return false;
    switch (cardType) {
      case HomeCardType.heartRate:
        return _hasHeartRateData.value;
      case HomeCardType.bloodPressure:
        return _hasBloodPressureData.value;
      case HomeCardType.drinkWater:
        return _hasDrinkWaterData.value;
    }
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _loadCardOrderAndVisibility();
    _loadData();
    _loadHomeCardsData();
  }

  @override
  void onReady() {
    super.onReady();
    // Refresh dữ liệu khi quay lại home screen
    _loadHomeCardsData();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      // App quay lại foreground
      // Refresh dữ liệu home cards
      _loadHomeCardsData();

      // Nếu đang đếm bước, tính lại thời gian dựa trên startTime
      if (_isCounting.value) {
        _recalculateElapsedTime();
      }
    }
    // Không cần xử lý khi app vào background vì thời gian vẫn được tính dựa trên timestamp
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _stepSubscription?.cancel();
    _timer?.cancel();
    _stepPollingTimer?.cancel();
    super.onClose();
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

  /// Load dữ liệu cho các home cards từ database
  Future<void> _loadHomeCardsData() async {
    await Future.wait([
      _loadHeartRateData(),
      _loadBloodPressureData(),
      _loadDrinkWaterData(),
    ]);
  }

  /// Load heart rate data từ database (chỉ lấy dữ liệu hôm nay)
  Future<void> _loadHeartRateData() async {
    try {
      final heartRates = await _heartRateRepository.getTodayHeartRate();
      if (heartRates.isEmpty) {
        _hasHeartRateData.value = false;
        _latestHeartRate.value = null;
        return;
      }
      // Sắp xếp theo dateTime giảm dần và lấy cái đầu tiên
      heartRates.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      _latestHeartRate.value = heartRates.first;
      _hasHeartRateData.value = true;
    } catch (e) {
      print('Error loading heart rate data: $e');
      _hasHeartRateData.value = false;
      _latestHeartRate.value = null;
    }
  }

  /// Load blood pressure data từ database (chỉ lấy dữ liệu hôm nay)
  Future<void> _loadBloodPressureData() async {
    try {
      final bloodPressure = await _bloodPressureRepository
          .getTodayBloodPressure();
      if (bloodPressure == null) {
        _hasBloodPressureData.value = false;
        _latestBloodPressure.value = null;
        return;
      }
      _latestBloodPressure.value = bloodPressure;
      _hasBloodPressureData.value = true;
    } catch (e) {
      print('Error loading blood pressure data: $e');
      _hasBloodPressureData.value = false;
      _latestBloodPressure.value = null;
    }
  }

  /// Load drink water data từ database (chỉ lấy dữ liệu hôm nay)
  Future<void> _loadDrinkWaterData() async {
    try {
      // Load settings từ SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final goal = prefs.getInt('drink_water_goal');
      final cupCapacity = prefs.getInt('drink_water_cup_capacity');

      // Nếu đã có settings, dùng giá trị đó, nếu không dùng default
      _drinkWaterGoal.value = goal ?? 2000;
      _drinkWaterCupCapacity.value = cupCapacity ?? 250;

      // Tính tổng amount hôm nay
      final today = DateTime.now();
      final date = DateTime(today.year, today.month, today.day);
      final currentAmount = await _drinkWaterRepository.getTotalAmountByDate(
        date,
      );
      _drinkWaterCurrentAmount.value = currentAmount;

      // Card chỉ hiển thị nếu có records của ngày hôm nay (đã uống nước hôm nay)
      _hasDrinkWaterData.value = currentAmount > 0;
    } catch (e) {
      print('Error loading drink water data: $e');
      _hasDrinkWaterData.value = false;
    }
  }

  /// Refresh dữ liệu home cards (gọi từ bên ngoài khi cần)
  Future<void> refreshHomeCardsData() async {
    await _loadHomeCardsData();
  }

  /// Load thứ tự và visibility của cards từ SharedPreferences
  Future<void> _loadCardOrderAndVisibility() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load thứ tự
      final orderJson = prefs.getString(_cardOrderKey);
      if (orderJson != null) {
        final List<dynamic> orderList = jsonDecode(orderJson);
        _cardOrder.value = orderList
            .map((e) => HomeCardType.fromString(e as String))
            .whereType<HomeCardType>()
            .toList();
      } else {
        // Default order
        _cardOrder.value = [
          HomeCardType.heartRate,
          HomeCardType.bloodPressure,
          HomeCardType.drinkWater,
        ];
      }

      // Load visibility
      final visibilityJson = prefs.getString(_cardVisibilityKey);
      if (visibilityJson != null) {
        final Map<String, dynamic> visibilityMap = jsonDecode(visibilityJson);
        _cardVisibility.value = visibilityMap.map(
          (key, value) => MapEntry(
            HomeCardType.fromString(key) ?? HomeCardType.heartRate,
            value as bool,
          ),
        );
      }
    } catch (e) {
      print('Error loading card order and visibility: $e');
      // Default values
      _cardOrder.value = [
        HomeCardType.heartRate,
        HomeCardType.bloodPressure,
        HomeCardType.drinkWater,
      ];
    }
  }

  /// Lưu thứ tự và visibility của cards vào SharedPreferences
  Future<void> _saveCardOrderAndVisibility() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save order
      final orderJson = jsonEncode(_cardOrder.map((e) => e.value).toList());
      await prefs.setString(_cardOrderKey, orderJson);

      // Save visibility
      final visibilityMap = _cardVisibility.map(
        (key, value) => MapEntry(key.value, value),
      );
      final visibilityJson = jsonEncode(visibilityMap);
      await prefs.setString(_cardVisibilityKey, visibilityJson);
    } catch (e) {
      print('Error saving card order and visibility: $e');
    }
  }

  /// Cập nhật thứ tự cards sau khi drag & drop
  Future<void> updateCardOrder(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = _cardOrder.removeAt(oldIndex);
    _cardOrder.insert(newIndex, item);
    await _saveCardOrderAndVisibility();
  }

  /// Ẩn/hiện card
  Future<void> toggleCardVisibility(HomeCardType cardType) async {
    _cardVisibility[cardType] = !(_cardVisibility[cardType] ?? true);
    await _saveCardOrderAndVisibility();
  }

  /// Xóa card (ẩn card)
  Future<void> removeCard(HomeCardType cardType) async {
    await toggleCardVisibility(cardType);
  }
}
