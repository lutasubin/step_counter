import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Helper class để quản lý SQLite database
class DatabaseHelper {
  static const String _databaseName = 'step_counter.db';
  static const int _databaseVersion =
      3; // Tăng version để thêm bảng blood_pressures
  static const String _tableName = 'daily_activities';
  static const String _heartRateTableName = 'heart_rates';
  static const String _bloodPressureTableName = 'blood_pressures';

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
      onUpgrade: _onUpgrade,
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

    // Tạo bảng heart_rates
    await db.execute('''
      CREATE TABLE $_heartRateTableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date_time TEXT NOT NULL,
        bpm INTEGER NOT NULL,
        status TEXT NOT NULL,
        normal_range TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Tạo index cho date_time để query nhanh hơn
    await db.execute('''
      CREATE INDEX idx_heart_rate_date_time ON $_heartRateTableName(date_time)
    ''');

    // Tạo bảng blood_pressures
    await db.execute('''
      CREATE TABLE $_bloodPressureTableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date_time TEXT NOT NULL,
        systolic INTEGER NOT NULL,
        diastolic INTEGER NOT NULL,
        pulse INTEGER NOT NULL,
        status TEXT NOT NULL,
        normal_range TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Tạo index cho date_time
    await db.execute('''
      CREATE INDEX idx_blood_pressure_date_time ON $_bloodPressureTableName(date_time)
    ''');
  }

  /// Upgrade database khi version thay đổi
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Thêm bảng heart_rates cho version 2
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $_heartRateTableName (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date_time TEXT NOT NULL,
          bpm INTEGER NOT NULL,
          status TEXT NOT NULL,
          normal_range TEXT NOT NULL,
          created_at TEXT NOT NULL
        )
      ''');

      // Tạo index
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_heart_rate_date_time ON $_heartRateTableName(date_time)
      ''');
    }

    if (oldVersion < 3) {
      // Thêm bảng blood_pressures cho version 3
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $_bloodPressureTableName (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date_time TEXT NOT NULL,
          systolic INTEGER NOT NULL,
          diastolic INTEGER NOT NULL,
          pulse INTEGER NOT NULL,
          status TEXT NOT NULL,
          normal_range TEXT NOT NULL,
          created_at TEXT NOT NULL
        )
      ''');

      // Tạo index
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_blood_pressure_date_time ON $_bloodPressureTableName(date_time)
      ''');
    }
  }

  /// Đóng database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  /// Getter cho heart rate table name (để sử dụng trong repository)
  static String get heartRateTableName => _heartRateTableName;

  /// Getter cho blood pressure table name (để sử dụng trong repository)
  static String get bloodPressureTableName => _bloodPressureTableName;
}
