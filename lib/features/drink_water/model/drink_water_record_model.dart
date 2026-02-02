/// Model lưu trữ dữ liệu uống nước
class DrinkWaterRecordModel {
  final int? id; // ID từ database, null nếu chưa lưu
  final DateTime dateTime; // Thời gian uống nước
  final int amount; // Số ml đã uống

  const DrinkWaterRecordModel({
    this.id,
    required this.dateTime,
    required this.amount,
  });

  /// Tạo model từ JSON
  factory DrinkWaterRecordModel.fromJson(Map<String, dynamic> json) {
    return DrinkWaterRecordModel(
      id: json['id'] as int?,
      dateTime: DateTime.parse(json['dateTime'] as String),
      amount: json['amount'] as int,
    );
  }

  /// Tạo model từ database map
  factory DrinkWaterRecordModel.fromDatabase(Map<String, dynamic> map) {
    return DrinkWaterRecordModel(
      id: map['id'] as int?,
      dateTime: DateTime.parse(map['date_time'] as String),
      amount: map['amount'] as int,
    );
  }

  /// Chuyển model sang JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'dateTime': dateTime.toIso8601String(),
      'amount': amount,
    };
  }

  /// Chuyển model sang database map
  Map<String, dynamic> toDatabase() {
    return {
      if (id != null) 'id': id,
      'date_time': dateTime.toIso8601String(),
      'amount': amount,
      'created_at': DateTime.now().toIso8601String(),
    };
  }
}
