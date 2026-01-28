import 'package:sqflite/sqflite.dart';
import 'package:step_counter/features/report/model/daily_activity_model.dart';
import 'package:step_counter/features/report/repositories/database_helper.dart';
import 'package:step_counter/features/report/repositories/report_repository.dart';

/// Implementation của ReportRepository sử dụng SQLite
class ReportRepositoryImpl implements ReportRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Chuyển DateTime sang string format YYYY-MM-DD
  String _dateToString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Chuyển string format YYYY-MM-DD sang DateTime
  DateTime _stringToDate(String dateStr) {
    return DateTime.parse(dateStr);
  }

  @override
  Future<void> saveDailyActivity(DailyActivityModel activity) async {
    final db = await _dbHelper.database;
    // Normalize date về 00:00:00 để lưu đúng
    final normalizedDate = DateTime(
      activity.date.year,
      activity.date.month,
      activity.date.day,
    );
    final dateStr = _dateToString(normalizedDate);

    await db.insert('daily_activities', {
      'date': dateStr,
      'steps': activity.steps,
      'calories': activity.calories,
      'distance': activity.distance,
      'duration_seconds': activity.durationSeconds,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<DailyActivityModel?> getDailyActivity(DateTime date) async {
    final db = await _dbHelper.database;
    // Normalize date về 00:00:00 để query đúng
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final dateStr = _dateToString(normalizedDate);

    final maps = await db.query(
      'daily_activities',
      where: 'date = ?',
      whereArgs: [dateStr],
    );

    if (maps.isEmpty) return null;

    return _mapToActivity(maps.first);
  }

  @override
  Future<List<DailyActivityModel>> getActivitiesInRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _dbHelper.database;
    final startStr = _dateToString(startDate);
    final endStr = _dateToString(endDate);

    final maps = await db.query(
      'daily_activities',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startStr, endStr],
      orderBy: 'date ASC',
    );

    return maps.map((map) => _mapToActivity(map)).toList();
  }

  @override
  Future<List<DailyActivityModel>> getAllActivities() async {
    final db = await _dbHelper.database;

    final maps = await db.query('daily_activities', orderBy: 'date ASC');

    return maps.map((map) => _mapToActivity(map)).toList();
  }

  /// Chuyển Map từ database sang DailyActivityModel
  DailyActivityModel _mapToActivity(Map<String, dynamic> map) {
    return DailyActivityModel(
      date: _stringToDate(map['date'] as String),
      steps: map['steps'] as int,
      calories: (map['calories'] as num).toDouble(),
      distance: (map['distance'] as num).toDouble(),
      durationSeconds: map['duration_seconds'] as int,
    );
  }
}
