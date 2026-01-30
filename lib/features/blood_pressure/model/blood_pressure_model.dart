/// Model lưu trữ dữ liệu huyết áp
class BloodPressureModel {
  final int? id; // ID từ database, null nếu chưa lưu
  final DateTime dateTime;
  final int systolic; // Huyết áp tâm thu (mmHg)
  final int diastolic; // Huyết áp tâm trương (mmHg)
  final int pulse; // Nhịp tim (BPM)
  final String status; // "Normal", "High", "Low"
  final String normalRange; // "SYS 90-119 and DIA 60-79"

  const BloodPressureModel({
    this.id,
    required this.dateTime,
    required this.systolic,
    required this.diastolic,
    required this.pulse,
    required this.status,
    required this.normalRange,
  });

  /// Tạo model từ JSON
  factory BloodPressureModel.fromJson(Map<String, dynamic> json) {
    return BloodPressureModel(
      id: json['id'] as int?,
      dateTime: DateTime.parse(json['dateTime'] as String),
      systolic: json['systolic'] as int,
      diastolic: json['diastolic'] as int,
      pulse: json['pulse'] as int,
      status: json['status'] as String,
      normalRange: json['normalRange'] as String,
    );
  }

  /// Tạo model từ database map
  factory BloodPressureModel.fromDatabase(Map<String, dynamic> map) {
    return BloodPressureModel(
      id: map['id'] as int?,
      dateTime: DateTime.parse(map['date_time'] as String),
      systolic: map['systolic'] as int,
      diastolic: map['diastolic'] as int,
      pulse: map['pulse'] as int,
      status: map['status'] as String,
      normalRange: map['normal_range'] as String,
    );
  }

  /// Chuyển model sang JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'dateTime': dateTime.toIso8601String(),
      'systolic': systolic,
      'diastolic': diastolic,
      'pulse': pulse,
      'status': status,
      'normalRange': normalRange,
    };
  }

  /// Chuyển model sang database map
  Map<String, dynamic> toDatabase() {
    return {
      if (id != null) 'id': id,
      'date_time': dateTime.toIso8601String(),
      'systolic': systolic,
      'diastolic': diastolic,
      'pulse': pulse,
      'status': status,
      'normal_range': normalRange,
      'created_at': DateTime.now().toIso8601String(),
    };
  }
}
