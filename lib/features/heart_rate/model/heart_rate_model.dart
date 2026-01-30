/// Model lưu trữ dữ liệu nhịp tim
class HeartRateModel {
  final int? id; // ID từ database, null nếu chưa lưu
  final DateTime dateTime;
  final int bpm;
  final String status; // "Normal", "High", "Low"
  final String normalRange; // "BPM 75-89"

  const HeartRateModel({
    this.id,
    required this.dateTime,
    required this.bpm,
    required this.status,
    required this.normalRange,
  });

  /// Tạo model từ JSON
  factory HeartRateModel.fromJson(Map<String, dynamic> json) {
    return HeartRateModel(
      id: json['id'] as int?,
      dateTime: DateTime.parse(json['dateTime'] as String),
      bpm: json['bpm'] as int,
      status: json['status'] as String,
      normalRange: json['normalRange'] as String,
    );
  }

  /// Tạo model từ database map
  factory HeartRateModel.fromDatabase(Map<String, dynamic> map) {
    return HeartRateModel(
      id: map['id'] as int?,
      dateTime: DateTime.parse(map['date_time'] as String),
      bpm: map['bpm'] as int,
      status: map['status'] as String,
      normalRange: map['normal_range'] as String,
    );
  }

  /// Chuyển model sang JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'dateTime': dateTime.toIso8601String(),
      'bpm': bpm,
      'status': status,
      'normalRange': normalRange,
    };
  }
}
