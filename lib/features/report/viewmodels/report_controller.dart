import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:step_counter/core/di/di_setup.dart';
import 'package:step_counter/features/home/service/step_counter_service.dart';
import 'package:step_counter/features/report/model/daily_activity_model.dart';
import 'package:step_counter/features/report/service/report_service.dart';

/// Enum cho period type
enum PeriodType { day, week, month }

/// Controller quản lý logic của report screen
class ReportController extends GetxController {
  final ReportService _reportService;
  final _selectedPeriod = PeriodType.day.obs;
  final _currentDate = DateTime.now().obs;
  final _activities = <DailyActivityModel>[].obs;
  final _selectedIndex = 0.obs;

  ReportController(this._reportService);

  /// Period được chọn
  PeriodType get selectedPeriod => _selectedPeriod.value;

  /// Ngày hiện tại
  DateTime get currentDate => _currentDate.value;

  /// Danh sách activities
  List<DailyActivityModel> get activities => _activities;

  /// Index được chọn trên chart
  int get selectedIndex => _selectedIndex.value;

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  @override
  void onReady() {
    super.onReady();
    // Sync dữ liệu hôm nay từ pedometer
    _syncTodayData();
    // Reload data khi màn hình sẵn sàng
    _loadData();
  }

  /// Load dữ liệu
  Future<void> _loadData() async {
    await _loadActivities();
  }

  /// Sync dữ liệu hôm nay từ pedometer
  Future<void> _syncTodayData() async {
    try {
      final stepCounterService = getIt<StepCounterService>();

      // Kiểm tra quyền trước khi sync
      final hasPermission = await stepCounterService
          .checkAndRequestPermission();
      if (!hasPermission) {
        print('ReportController: No permission to sync today data');
        return;
      }

      final today = DateTime.now();
      final normalizedDate = DateTime(today.year, today.month, today.day);

      // Kiểm tra xem đã có dữ liệu hôm nay chưa
      final existingActivity = await _reportService.getActivityByDate(
        normalizedDate,
      );

      // Lấy số bước thật từ pedometer
      final todaySteps = await stepCounterService.getTodaySteps();
      print('ReportController: Today steps from pedometer: $todaySteps');

      // Nếu chưa có hoặc số bước trong DB nhỏ hơn số bước thật, cập nhật
      if (existingActivity == null || existingActivity.steps < todaySteps) {
        // Tính toán calories và distance
        final calories = stepCounterService.calculateCalories(todaySteps);
        final distance = stepCounterService.calculateDistance(todaySteps);

        // Tính duration: nếu đã có dữ liệu, giữ nguyên duration, nếu chưa thì 0
        final duration = existingActivity?.durationSeconds ?? 0;

        final activity = DailyActivityModel(
          date: normalizedDate,
          steps: todaySteps,
          calories: calories,
          distance: distance,
          durationSeconds: duration,
        );

        await _reportService.saveActivity(activity);
        print(
          'ReportController: Synced today data - Steps: $todaySteps, Calories: $calories, Distance: $distance',
        );

        // Reload data sau khi sync
        await _loadActivities();
      } else {
        print(
          'ReportController: Today data already up to date - DB: ${existingActivity.steps}, Pedometer: $todaySteps',
        );
      }
    } catch (e) {
      print('ReportController: Error syncing today data: $e');
    }
  }

  /// Load activities theo period
  Future<void> _loadActivities() async {
    switch (_selectedPeriod.value) {
      case PeriodType.day:
        // Normalize date về 00:00:00 để query đúng
        final normalizedDate = DateTime(
          _currentDate.value.year,
          _currentDate.value.month,
          _currentDate.value.day,
        );
        final activity = await _reportService.getActivityByDate(normalizedDate);
        _activities.value = _generateDayHourlyData(activity);
        break;
      case PeriodType.week:
        final weekStart = _getWeekStart(_currentDate.value);
        _activities.value = await _reportService.getActivitiesByWeek(weekStart);
        break;
      case PeriodType.month:
        _activities.value = await _reportService.getActivitiesByMonth(
          _currentDate.value,
        );
        break;
    }
    if (_selectedPeriod.value == PeriodType.day) {
      // Mặc định chọn điểm cuối cùng (16-20) hoặc điểm có giá trị cao nhất
      _selectedIndex.value = _activities.isNotEmpty
          ? _activities.length - 1
          : 0;
    } else {
      _selectedIndex.value = _activities.isNotEmpty
          ? _activities.length - 1
          : 0;
    }
  }

  /// Tạo dữ liệu theo 6 khoảng 4 giờ cho Day view
  List<DailyActivityModel> _generateDayHourlyData(
    DailyActivityModel? activity,
  ) {
    final totalSteps = activity?.steps ?? 0;
    final totalDuration = activity?.durationSeconds ?? 0;
    final date = _currentDate.value;

    // Phân bổ số bước theo 6 khoảng 4 giờ (giả lập)
    // Khoảng 08-12 và 16-20 thường có nhiều bước nhất
    final distribution = [0.05, 0.15, 0.30, 0.20, 0.25, 0.05]; // Tỷ lệ phân bổ

    // Debug: In ra để kiểm tra
    print('ReportController: Generating day hourly data');
    print('Total steps: $totalSteps');
    print('Total duration: $totalDuration');
    print('Date: $date');

    return List.generate(6, (index) {
      final hourStart = index * 4;
      final steps = (totalSteps * distribution[index]).round();
      // Phân bổ duration theo cùng tỷ lệ
      final duration = (totalDuration * distribution[index]).round();

      return DailyActivityModel(
        date: DateTime(date.year, date.month, date.day, hourStart),
        steps: steps,
        calories: steps * 0.04,
        distance: steps * 0.0008,
        durationSeconds: duration,
      );
    });
  }

  /// Chuyển period
  void changePeriod(PeriodType period) {
    _selectedPeriod.value = period;
    _loadActivities();
  }

  /// Chuyển ngày/tuần/tháng trước
  void previousPeriod() {
    switch (_selectedPeriod.value) {
      case PeriodType.day:
        _currentDate.value = _currentDate.value.subtract(
          const Duration(days: 1),
        );
        break;
      case PeriodType.week:
        _currentDate.value = _currentDate.value.subtract(
          const Duration(days: 7),
        );
        break;
      case PeriodType.month:
        _currentDate.value = DateTime(
          _currentDate.value.year,
          _currentDate.value.month - 1,
        );
        break;
    }
    _loadActivities();
  }

  /// Chuyển ngày/tuần/tháng sau
  void nextPeriod() {
    switch (_selectedPeriod.value) {
      case PeriodType.day:
        _currentDate.value = _currentDate.value.add(const Duration(days: 1));
        break;
      case PeriodType.week:
        _currentDate.value = _currentDate.value.add(const Duration(days: 7));
        break;
      case PeriodType.month:
        _currentDate.value = DateTime(
          _currentDate.value.year,
          _currentDate.value.month + 1,
        );
        break;
    }
    _loadActivities();
  }

  /// Format date display
  String getDateDisplay() {
    switch (_selectedPeriod.value) {
      case PeriodType.day:
        return DateFormat('MMM dd, yyyy').format(_currentDate.value);
      case PeriodType.week:
        final weekStart = _getWeekStart(_currentDate.value);
        final weekEnd = weekStart.add(const Duration(days: 6));
        return '${DateFormat('MMM dd', 'en_US').format(weekStart)} - ${DateFormat('MMM dd, yyyy', 'en_US').format(weekEnd)}';
      case PeriodType.month:
        return DateFormat('MMM, yyyy').format(_currentDate.value);
    }
  }

  /// Lấy week start (Monday)
  DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday;
    return date.subtract(Duration(days: weekday - 1));
  }

  /// Tính tổng steps
  int getTotalSteps() {
    return _reportService.calculateTotalSteps(_activities);
  }

  /// Tính trung bình steps
  double getAverageSteps() {
    return _reportService.calculateAverageSteps(_activities);
  }

  /// Tính tổng calories
  double getTotalCalories() {
    return _reportService.calculateTotalCalories(_activities);
  }

  /// Tính tổng distance
  double getTotalDistance() {
    return _reportService.calculateTotalDistance(_activities);
  }

  /// Set selected index trên chart
  void setSelectedIndex(int index) {
    _selectedIndex.value = index;
  }
}
