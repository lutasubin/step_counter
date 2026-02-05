import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:step_counter/core/constants/route_names.dart';
import 'package:step_counter/core/di/di_setup.dart';
import 'package:step_counter/features/drink_water/model/drink_water_record_model.dart';
import 'package:step_counter/features/drink_water/repositories/drink_water_repository.dart';
import 'package:step_counter/features/home/service/step_counter_service.dart';
import 'package:step_counter/features/report/model/daily_activity_model.dart';
import 'package:step_counter/features/report/service/report_service.dart';

/// Enum cho period type
enum PeriodType { day, week, month }

/// Controller quản lý logic của report screen
class ReportController extends GetxController {
  final ReportService _reportService;
  final DrinkWaterRepository _drinkWaterRepository =
      getIt<DrinkWaterRepository>();
  late final bool isDrinkWaterMode;
  final _selectedPeriod = PeriodType.day.obs;
  final _currentDate = DateTime.now().obs;
  final _activities = <DailyActivityModel>[].obs;
  final _selectedIndex = 0.obs;
  final _reloadToken = 0.obs;

  ReportController(this._reportService);

  /// Period được chọn
  PeriodType get selectedPeriod => _selectedPeriod.value;

  /// Ngày hiện tại
  DateTime get currentDate => _currentDate.value;

  /// Danh sách activities
  List<DailyActivityModel> get activities => _activities;

  /// Index được chọn trên chart
  int get selectedIndex => _selectedIndex.value;

  /// Token để trigger reload cho các widget dùng FutureBuilder (drink mode)
  int get reloadToken => _reloadToken.value;

  @override
  void onInit() {
    super.onInit();
    // Xác định chế độ: báo cáo bước chân hay báo cáo uống nước
    // Nếu route là drinkWaterReport hoặc arguments là 'drink-water' thì là chế độ drink
    final currentRoute = Get.currentRoute;
    final args = Get.arguments;
    isDrinkWaterMode =
        currentRoute == RouteNames.drinkWaterReport || args == 'drink-water';
    _loadData();
  }

  @override
  void onReady() {
    super.onReady();
    // Chỉ sync pedometer cho chế độ bước chân
    if (!isDrinkWaterMode) {
      _syncTodayData();
      // Reload data khi màn hình sẵn sàng
      _loadData();
    }
  }

  /// Load dữ liệu
  Future<void> _loadData() async {
    await _loadActivities();
  }

  /// Reload dữ liệu cho report drink water sau khi user đổi setting
  Future<void> reloadDrinkReport() async {
    await _loadActivities();
    _reloadToken.value++;
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
    // Nếu là report drink water → load dữ liệu uống nước từ SQLite
    if (isDrinkWaterMode) {
      switch (_selectedPeriod.value) {
        case PeriodType.day:
          _activities.value = await _generateDrinkDayData(_currentDate.value);
          break;
        case PeriodType.week:
          final weekStart = _getWeekStart(_currentDate.value);
          _activities.value = await _generateDrinkWeekData(weekStart);
          break;
        case PeriodType.month:
          _activities.value = await _generateDrinkMonthData(_currentDate.value);
          break;
      }
    } else {
      // Report bước chân: dùng dữ liệu từ ReportService như cũ
      switch (_selectedPeriod.value) {
        case PeriodType.day:
          // Normalize date về 00:00:00 để query đúng
          final normalizedDate = DateTime(
            _currentDate.value.year,
            _currentDate.value.month,
            _currentDate.value.day,
          );
          final activity = await _reportService.getActivityByDate(
            normalizedDate,
          );
          _activities.value = _generateDayHourlyData(activity);
          break;
        case PeriodType.week:
          final weekStart = _getWeekStart(_currentDate.value);
          _activities.value = await _generateWeekData(weekStart);
          break;
        case PeriodType.month:
          _activities.value = await _generateMonthData(_currentDate.value);
          break;
      }
    }
    // Reset selectedIndex về 0 khi load dữ liệu mới
    // Tránh index out of range khi chuyển period hoặc khi activities thay đổi
    _selectedIndex.value = 0;
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

  /// Tạo dữ liệu uống nước cho Day view: chia 6 khoảng 4 giờ, mỗi khoảng tổng ml
  Future<List<DailyActivityModel>> _generateDrinkDayData(
    DateTime currentDate,
  ) async {
    // Lấy tất cả record uống nước trong ngày
    final records = await _drinkWaterRepository.getRecordsByDate(currentDate);
    final date = DateTime(currentDate.year, currentDate.month, currentDate.day);

    // 6 khoảng 4 giờ: 00-04, 04-08, 08-12, 12-16, 16-20, 20-24
    final buckets = List<int>.filled(6, 0);

    for (final DrinkWaterRecordModel record in records) {
      final hour = record.dateTime.hour;
      final bucketIndex = hour ~/ 4; // 0..5
      if (bucketIndex >= 0 && bucketIndex < 6) {
        buckets[bucketIndex] += record.amount;
      }
    }

    return List.generate(6, (index) {
      final hourStart = index * 4;
      final amount = buckets[index];

      return DailyActivityModel(
        date: DateTime(date.year, date.month, date.day, hourStart),
        // Reuse trường steps để biểu diễn ml cho chart
        steps: amount,
        calories: 0,
        distance: 0,
        durationSeconds: 0,
      );
    });
  }

  /// Tạo đủ 7 ngày cho Week view (kể cả ngày không có dữ liệu -> 0 step)
  Future<List<DailyActivityModel>> _generateWeekData(DateTime weekStart) async {
    final rawActivities = await _reportService.getActivitiesByWeek(weekStart);

    return List.generate(7, (index) {
      final date = DateTime(
        weekStart.year,
        weekStart.month,
        weekStart.day + index,
      );

      final existing = rawActivities.firstWhere(
        (a) =>
            a.date.year == date.year &&
            a.date.month == date.month &&
            a.date.day == date.day,
        orElse: () => DailyActivityModel(
          date: date,
          steps: 0,
          calories: 0,
          distance: 0,
          durationSeconds: 0,
        ),
      );

      return existing;
    });
  }

  /// Tạo dữ liệu uống nước cho Week view: 7 ngày, mỗi ngày tổng ml
  Future<List<DailyActivityModel>> _generateDrinkWeekData(
    DateTime weekStart,
  ) async {
    return Future.wait(
      List.generate(7, (index) async {
        final date = DateTime(
          weekStart.year,
          weekStart.month,
          weekStart.day + index,
        );
        final totalMl = await _drinkWaterRepository.getTotalAmountByDate(date);

        return DailyActivityModel(
          date: date,
          steps: totalMl, // dùng steps làm ml
          calories: 0,
          distance: 0,
          durationSeconds: 0,
        );
      }),
    );
  }

  /// Tạo dữ liệu tháng: chỉ lấy những ngày có step > 0
  /// Nhưng vẫn đảm bảo có các mốc 1, 15, 31 trên trục X
  Future<List<DailyActivityModel>> _generateMonthData(
    DateTime monthDate,
  ) async {
    final rawActivities = await _reportService.getActivitiesByMonth(monthDate);
    final year = monthDate.year;
    final month = monthDate.month;

    // Lấy số ngày trong tháng
    final daysInMonth = DateTime(year, month + 1, 0).day;

    // Debug: In ra tất cả rawActivities
    print(
      'ReportController: _generateMonthData - Raw activities count: ${rawActivities.length}',
    );
    for (final activity in rawActivities) {
      print('  Day ${activity.date.day}: ${activity.steps} steps');
    }

    // Tạo map để dễ tìm kiếm theo ngày (bao gồm cả ngày có step = 0)
    final activitiesMap = <int, DailyActivityModel>{};
    for (final activity in rawActivities) {
      // Normalize date để đảm bảo so sánh đúng
      final normalizedDate = DateTime(
        activity.date.year,
        activity.date.month,
        activity.date.day,
      );
      activitiesMap[normalizedDate.day] = activity;
    }

    // Lọc chỉ lấy những ngày có step > 0
    final activitiesWithSteps = rawActivities
        .where((a) => a.steps > 0)
        .toList();

    print(
      'ReportController: Activities with steps > 0: ${activitiesWithSteps.length}',
    );
    for (final activity in activitiesWithSteps) {
      print('  Day ${activity.date.day}: ${activity.steps} steps');
    }

    // Tạo danh sách các mốc cần hiển thị: 1, 15, và ngày cuối tháng (28/29/30/31)
    final milestoneDays = <int>[1, 15];
    final lastDay = daysInMonth; // Ngày cuối tháng
    milestoneDays.add(lastDay);

    // Tạo danh sách kết quả: gồm các mốc và các ngày có step
    final result = <DailyActivityModel>[];
    final addedDays = <int>{};

    // Thêm các mốc (1, 15, cuối tháng) - nếu có step thì dùng dữ liệu thật, không có thì tạo với 0
    for (final day in milestoneDays) {
      if (day <= daysInMonth) {
        final date = DateTime(year, month, day);
        if (activitiesMap.containsKey(day)) {
          // Mốc có dữ liệu (có thể step > 0 hoặc = 0), dùng dữ liệu thật
          result.add(activitiesMap[day]!);
          print(
            'ReportController: Added milestone day $day with ${activitiesMap[day]!.steps} steps',
          );
        } else {
          // Mốc không có dữ liệu, tạo với 0 để hiển thị trên trục X
          result.add(
            DailyActivityModel(
              date: date,
              steps: 0,
              calories: 0,
              distance: 0,
              durationSeconds: 0,
            ),
          );
          print(
            'ReportController: Added milestone day $day with 0 steps (no data)',
          );
        }
        addedDays.add(day);
      }
    }

    // Thêm các ngày có step còn lại (không phải mốc)
    // Sắp xếp theo ngày để đảm bảo thứ tự
    final sortedActivities = List<DailyActivityModel>.from(activitiesWithSteps)
      ..sort((a, b) => a.date.day.compareTo(b.date.day));

    for (final activity in sortedActivities) {
      final day = activity.date.day;
      if (!addedDays.contains(day)) {
        result.add(activity);
        addedDays.add(day);
        print('ReportController: Added day $day with ${activity.steps} steps');
      } else {
        print('ReportController: Day $day already added as milestone');
      }
    }

    // Sắp xếp theo ngày
    result.sort((a, b) => a.date.day.compareTo(b.date.day));

    print('ReportController: Final result count: ${result.length}');
    for (final activity in result) {
      print('  Day ${activity.date.day}: ${activity.steps} steps');
    }

    return result;
  }

  /// Tạo dữ liệu uống nước cho Month view: chỉ lấy những ngày có ml > 0,
  /// nhưng vẫn đảm bảo có các mốc 1, 15, và ngày cuối tháng trên trục X
  Future<List<DailyActivityModel>> _generateDrinkMonthData(
    DateTime monthDate,
  ) async {
    final year = monthDate.year;
    final month = monthDate.month;
    final daysInMonth = DateTime(year, month + 1, 0).day;

    // Lấy tổng ml cho từng ngày trong tháng
    final dayTotals = <int, int>{};
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      final totalMl = await _drinkWaterRepository.getTotalAmountByDate(date);
      dayTotals[day] = totalMl;
    }

    final milestoneDays = <int>[1, 15, daysInMonth];
    final result = <DailyActivityModel>[];
    final addedDays = <int>{};

    // Thêm các mốc (1, 15, ngày cuối tháng)
    for (final day in milestoneDays) {
      if (day <= daysInMonth) {
        final date = DateTime(year, month, day);
        final totalMl = dayTotals[day] ?? 0;
        result.add(
          DailyActivityModel(
            date: date,
            steps: totalMl,
            calories: 0,
            distance: 0,
            durationSeconds: 0,
          ),
        );
        addedDays.add(day);
      }
    }

    // Thêm các ngày còn lại có ml > 0
    for (int day = 1; day <= daysInMonth; day++) {
      if (addedDays.contains(day)) continue;
      final totalMl = dayTotals[day] ?? 0;
      if (totalMl > 0) {
        final date = DateTime(year, month, day);
        result.add(
          DailyActivityModel(
            date: date,
            steps: totalMl,
            calories: 0,
            distance: 0,
            durationSeconds: 0,
          ),
        );
      }
    }

    // Sắp xếp theo ngày
    result.sort((a, b) => a.date.day.compareTo(b.date.day));
    return result;
  }

  /// Chuyển period
  void changePeriod(PeriodType period) {
    // Chỉ chuyển nếu period khác với period hiện tại
    if (_selectedPeriod.value != period) {
      _selectedPeriod.value = period;
      // Reset selectedIndex trước khi load để tránh index out of range
      _selectedIndex.value = 0;
      // Normalize _currentDate về ngày hiện tại khi chuyển period
      // Để tránh nhảy sang tuần/ngày khác
      final now = DateTime.now();
      switch (period) {
        case PeriodType.day:
          _currentDate.value = DateTime(now.year, now.month, now.day);
          break;
        case PeriodType.week:
          // Giữ nguyên ngày hiện tại, _getWeekStart sẽ tính tuần chứa ngày này
          _currentDate.value = DateTime(now.year, now.month, now.day);
          break;
        case PeriodType.month:
          _currentDate.value = DateTime(now.year, now.month);
          break;
      }
      _loadActivities();
    }
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
