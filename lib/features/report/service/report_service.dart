import 'package:step_counter/features/report/model/daily_activity_model.dart';
import 'package:step_counter/features/report/repositories/report_repository.dart';

/// Service xử lý logic thống kê
class ReportService {
  final ReportRepository _repository;

  ReportService(this._repository);

  /// Lưu dữ liệu hoạt động
  Future<void> saveActivity(DailyActivityModel activity) async {
    await _repository.saveDailyActivity(activity);
  }

  /// Lấy dữ liệu theo ngày
  Future<DailyActivityModel?> getActivityByDate(DateTime date) async {
    return await _repository.getDailyActivity(date);
  }

  /// Lấy dữ liệu theo tuần
  Future<List<DailyActivityModel>> getActivitiesByWeek(
    DateTime weekStart,
  ) async {
    final weekEnd = weekStart.add(const Duration(days: 6));
    return await _repository.getActivitiesInRange(weekStart, weekEnd);
  }

  /// Lấy dữ liệu theo tháng
  Future<List<DailyActivityModel>> getActivitiesByMonth(DateTime month) async {
    final startDate = DateTime(month.year, month.month, 1);
    final endDate = DateTime(month.year, month.month + 1, 0);
    return await _repository.getActivitiesInRange(startDate, endDate);
  }

  /// Tính tổng steps
  int calculateTotalSteps(List<DailyActivityModel> activities) {
    return activities.fold(0, (sum, activity) => sum + activity.steps);
  }

  /// Tính trung bình steps
  double calculateAverageSteps(List<DailyActivityModel> activities) {
    if (activities.isEmpty) return 0;
    return calculateTotalSteps(activities) / activities.length;
  }

  /// Tính tổng calories
  double calculateTotalCalories(List<DailyActivityModel> activities) {
    return activities.fold(0.0, (sum, activity) => sum + activity.calories);
  }

  /// Tính tổng distance
  double calculateTotalDistance(List<DailyActivityModel> activities) {
    return activities.fold(0.0, (sum, activity) => sum + activity.distance);
  }
}
