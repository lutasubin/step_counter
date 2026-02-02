import 'package:sqflite/sqflite.dart';
import 'package:step_counter/features/drink_water/model/drink_water_record_model.dart';
import 'package:step_counter/features/report/repositories/database_helper.dart';

/// Helper class để quản lý SQLite operations cho drink water
class DrinkWaterDatabase {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Lưu drink water record vào database
  Future<int> insertDrinkWaterRecord(DrinkWaterRecordModel record) async {
    final db = await _dbHelper.database;
    return await db.insert(
      DatabaseHelper.drinkWaterTableName,
      record.toDatabase(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Lấy tất cả records, sắp xếp theo date_time giảm dần
  Future<List<DrinkWaterRecordModel>> getAllRecords() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DatabaseHelper.drinkWaterTableName,
      orderBy: 'date_time DESC',
    );

    return maps.map((map) => DrinkWaterRecordModel.fromDatabase(map)).toList();
  }

  /// Lấy records theo ngày
  Future<List<DrinkWaterRecordModel>> getRecordsByDate(DateTime date) async {
    final db = await _dbHelper.database;
    final dateStart = DateTime(date.year, date.month, date.day);
    final dateEnd = dateStart.add(const Duration(days: 1));

    final maps = await db.query(
      DatabaseHelper.drinkWaterTableName,
      where: 'date_time >= ? AND date_time < ?',
      whereArgs: [dateStart.toIso8601String(), dateEnd.toIso8601String()],
      orderBy: 'date_time DESC',
    );

    return maps.map((map) => DrinkWaterRecordModel.fromDatabase(map)).toList();
  }

  /// Lấy tổng số ml đã uống trong ngày
  Future<int> getTotalAmountByDate(DateTime date) async {
    final db = await _dbHelper.database;
    final dateStart = DateTime(date.year, date.month, date.day);
    final dateEnd = dateStart.add(const Duration(days: 1));

    final result = await db.rawQuery(
      '''
      SELECT SUM(amount) as total
      FROM ${DatabaseHelper.drinkWaterTableName}
      WHERE date_time >= ? AND date_time < ?
      ''',
      [dateStart.toIso8601String(), dateEnd.toIso8601String()],
    );

    final total = result.first['total'] as int?;
    return total ?? 0;
  }

  /// Lấy record theo ID
  Future<DrinkWaterRecordModel?> getRecordById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DatabaseHelper.drinkWaterTableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return DrinkWaterRecordModel.fromDatabase(maps.first);
  }

  /// Xóa record theo ID
  Future<void> deleteRecord(int id) async {
    final db = await _dbHelper.database;
    await db.delete(
      DatabaseHelper.drinkWaterTableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Xóa tất cả records
  Future<void> deleteAllRecords() async {
    final db = await _dbHelper.database;
    await db.delete(DatabaseHelper.drinkWaterTableName);
  }
}
