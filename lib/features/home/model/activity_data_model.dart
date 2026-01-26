/// Model dữ liệu hoạt động
class ActivityDataModel {
  final int stepCount;
  final double calories;
  final double distance;
  final String duration;

  const ActivityDataModel({
    required this.stepCount,
    required this.calories,
    required this.distance,
    required this.duration,
  });

  /// Tạo model với giá trị mặc định
  factory ActivityDataModel.empty() {
    return const ActivityDataModel(
      stepCount: 0,
      calories: 0.0,
      distance: 0.0,
      duration: '0h 0m',
    );
  }

  /// Copy với các giá trị mới
  ActivityDataModel copyWith({
    int? stepCount,
    double? calories,
    double? distance,
    String? duration,
  }) {
    return ActivityDataModel(
      stepCount: stepCount ?? this.stepCount,
      calories: calories ?? this.calories,
      distance: distance ?? this.distance,
      duration: duration ?? this.duration,
    );
  }
}
