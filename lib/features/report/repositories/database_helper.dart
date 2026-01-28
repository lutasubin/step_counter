import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Helper class để quản lý SQLite database
class DatabaseHelper {
  static const String _databaseName = 'step_counter.db';
  static const int _databaseVersion = 1;
  static const String _tableName = 'daily_activities';

  static Database? _database;

  /// Lấy database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Khởi tạo database
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  /// Tạo bảng khi database được tạo lần đầu
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        date TEXT PRIMARY KEY,
        steps INTEGER NOT NULL,
        calories REAL NOT NULL,
        distance REAL NOT NULL,
        duration_seconds INTEGER NOT NULL
      )
    ''');
  }

  /// Đóng database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
