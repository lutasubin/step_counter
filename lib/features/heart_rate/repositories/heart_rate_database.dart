import 'package:step_counter/features/report/repositories/database_helper.dart';

/// Helper class để quản lý SQLite operations cho heart rate
class HeartRateDatabase {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Lưu heart rate vào database
  Future<int> insertHeartRate({
    required DateTime dateTime,
    required int bpm,
    required String status,
    required String normalRange,
  }) async {
    final db = await _dbHelper.database;
    return await db.insert(DatabaseHelper.heartRateTableName, {
      'date_time': dateTime.toIso8601String(),
      'bpm': bpm,
      'status': status,
      'normal_range': normalRange,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  /// Lấy tất cả heart rates, sắp xếp theo date_time giảm dần
  Future<List<Map<String, dynamic>>> getAllHeartRates() async {
    final db = await _dbHelper.database;
    return await db.query(
      DatabaseHelper.heartRateTableName,
      orderBy: 'date_time DESC',
    );
  }

  /// Lấy heart rate theo ID
  Future<Map<String, dynamic>?> getHeartRateById(int id) async {
    final db = await _dbHelper.database;
    final results = await db.query(
      DatabaseHelper.heartRateTableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// Lấy heart rates của ngày hôm nay
  Future<List<Map<String, dynamic>>> getTodayHeartRates() async {
    final db = await _dbHelper.database;
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return await db.query(
      DatabaseHelper.heartRateTableName,
      where: 'date_time >= ? AND date_time < ?',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      orderBy: 'date_time DESC',
    );
  }

  /// Xóa heart rate theo ID
  Future<int> deleteHeartRate(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      DatabaseHelper.heartRateTableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Xóa tất cả heart rates
  Future<int> deleteAllHeartRates() async {
    final db = await _dbHelper.database;
    return await db.delete(DatabaseHelper.heartRateTableName);
  }
}
