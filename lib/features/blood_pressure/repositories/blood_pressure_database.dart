import 'package:sqflite/sqflite.dart';
import 'package:step_counter/features/blood_pressure/model/blood_pressure_model.dart';
import 'package:step_counter/features/report/repositories/database_helper.dart';

/// Helper class để quản lý SQLite operations cho blood pressure
class BloodPressureDatabase {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Lưu blood pressure vào database
  Future<int> insertBloodPressure(BloodPressureModel bloodPressure) async {
    final db = await _dbHelper.database;
    return await db.insert(
      DatabaseHelper.bloodPressureTableName,
      bloodPressure.toDatabase(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Lấy tất cả blood pressures, sắp xếp theo date_time giảm dần
  Future<List<BloodPressureModel>> getAllBloodPressures() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DatabaseHelper.bloodPressureTableName,
      orderBy: 'date_time DESC',
    );

    return maps.map((map) => BloodPressureModel.fromDatabase(map)).toList();
  }

  /// Lấy blood pressure theo ID
  Future<BloodPressureModel?> getBloodPressureById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DatabaseHelper.bloodPressureTableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return BloodPressureModel.fromDatabase(maps.first);
  }

  /// Lấy blood pressure hôm nay (mới nhất)
  Future<BloodPressureModel?> getTodayBloodPressure() async {
    final db = await _dbHelper.database;
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    final maps = await db.query(
      DatabaseHelper.bloodPressureTableName,
      where: 'date_time >= ? AND date_time < ?',
      whereArgs: [
        todayStart.toIso8601String(),
        todayEnd.toIso8601String(),
      ],
      orderBy: 'date_time DESC',
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return BloodPressureModel.fromDatabase(maps.first);
  }

  /// Xóa blood pressure theo ID
  Future<int> deleteBloodPressure(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      DatabaseHelper.bloodPressureTableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Xóa tất cả blood pressures
  Future<int> deleteAllBloodPressures() async {
    final db = await _dbHelper.database;
    return await db.delete(DatabaseHelper.bloodPressureTableName);
  }
}
