/// Model lưu trữ dữ liệu hoạt động theo ngày
class DailyActivityModel {
  final DateTime date;
  final int steps;
  final double calories;
  final double distance;
  final int durationSeconds;

  const DailyActivityModel({
    required this.date,
    required this.steps,
    required this.calories,
    required this.distance,
    required this.durationSeconds,
  });

  /// Tạo model từ JSON
  factory DailyActivityModel.fromJson(Map<String, dynamic> json) {
    return DailyActivityModel(
      date: DateTime.parse(json['date'] as String),
      steps: json['steps'] as int,
      calories: (json['calories'] as num).toDouble(),
      distance: (json['distance'] as num).toDouble(),
      durationSeconds: json['durationSeconds'] as int,
    );
  }

  /// Chuyển model sang JSON
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'steps': steps,
      'calories': calories,
      'distance': distance,
      'durationSeconds': durationSeconds,
    };
  }
}
