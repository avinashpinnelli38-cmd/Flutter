import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/app_user.dart';
import '../models/vehicle.dart';
import '../models/fuel_log.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'fuel_tracker.db');
    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDb,
      onUpgrade: _upgradeDb,
    );
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        phone TEXT,
        salt TEXT NOT NULL,
        password_hash TEXT NOT NULL,
        is_guest INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE vehicles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        fuel_type TEXT NOT NULL,
        tank_capacity REAL NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');
    await db.execute('''
      CREATE TABLE fuel_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        vehicle_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        odometer REAL NOT NULL,
        fuel_volume REAL NOT NULL,
        total_cost REAL NOT NULL,
        is_full_tank INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (vehicle_id) REFERENCES vehicles (id)
      )
    ''');
    await _createIndexes(db);
  }

  /// The dashboard, vehicles list and log list all filter fuel logs by
  /// user/vehicle and order by date, so these keep those queries off a full
  /// table scan as the log history grows.
  static Future<void> _createIndexes(Database db) async {
    await db.execute('CREATE INDEX IF NOT EXISTS idx_vehicles_user ON vehicles(user_id)');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_fuel_logs_user_vehicle_date '
      'ON fuel_logs(user_id, vehicle_id, date)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_fuel_logs_vehicle_date '
      'ON fuel_logs(vehicle_id, date)',
    );
  }

  Future<void> _upgradeDb(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          email TEXT NOT NULL UNIQUE,
          phone TEXT,
          salt TEXT NOT NULL,
          password_hash TEXT NOT NULL,
          is_guest INTEGER NOT NULL DEFAULT 0
        )
      ''');
      await db.execute('ALTER TABLE vehicles ADD COLUMN user_id INTEGER');
      await db.execute('ALTER TABLE fuel_logs ADD COLUMN user_id INTEGER');
    }
    if (oldVersion < 3) {
      await _createIndexes(db);
    }
  }

  // ----- Users -----

  Future<int> insertUser(AppUser user) async {
    final db = await database;
    return await db.insert('users', {
      'name': user.name,
      'email': user.email,
      'phone': user.phone,
      'salt': user.salt,
      'password_hash': user.passwordHash,
      'is_guest': user.isGuest ? 1 : 0,
    });
  }

  Future<AppUser?> getUserByEmail(String email) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return AppUser.fromMap(maps.first);
  }

  Future<AppUser?> getUserById(int id) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return AppUser.fromMap(maps.first);
  }

  Future<AppUser?> getGuestUser() async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'is_guest = ?',
      whereArgs: [1],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return AppUser.fromMap(maps.first);
  }

  Future<int> updateUserProfile(
    int userId, {
    required String name,
    String? phone,
    String? newEmail,
  }) async {
    final db = await database;
    final values = <String, dynamic>{'name': name, 'phone': phone};
    if (newEmail != null) values['email'] = newEmail;
    return await db.update(
      'users',
      values,
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  /// Claims legacy rows (created before user accounts) for this user.
  Future<void> assignOrphanDataToUser(int userId) async {
    final db = await database;
    await db.rawUpdate(
      'UPDATE vehicles SET user_id = ? WHERE user_id IS NULL',
      [userId],
    );
    await db.rawUpdate(
      'UPDATE fuel_logs SET user_id = ? WHERE user_id IS NULL',
      [userId],
    );
  }

  // ----- Vehicles -----

  Future<int> insertVehicle(int userId, Vehicle vehicle) async {
    final db = await database;
    return await db.insert(
      'vehicles',
      vehicle.copyWith(userId: userId).toMap(),
    );
  }

  Future<List<Vehicle>> getVehicles(int userId) async {
    final db = await database;
    final maps = await db.query(
      'vehicles',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Vehicle.fromMap(maps[i]));
  }

  Future<Vehicle?> getVehicle(int id, int userId) async {
    final db = await database;
    final maps = await db.query(
      'vehicles',
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
    if (maps.isNotEmpty) return Vehicle.fromMap(maps.first);
    return null;
  }

  Future<int> updateVehicle(int userId, Vehicle vehicle) async {
    final db = await database;
    return await db.update(
      'vehicles',
      vehicle.copyWith(userId: userId).toMap(),
      where: 'id = ? AND user_id = ?',
      whereArgs: [vehicle.id, userId],
    );
  }

  Future<int> deleteVehicle(int userId, int id) async {
    final db = await database;
    await db.delete(
      'fuel_logs',
      where: 'vehicle_id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
    return await db.delete(
      'vehicles',
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
  }

  // ----- Fuel logs -----

  Future<int> insertFuelLog(int userId, FuelLog log) async {
    final db = await database;
    return await db.insert('fuel_logs', log.copyWith(userId: userId).toMap());
  }

  Future<List<FuelLog>> getFuelLogs({int? userId, int? vehicleId}) async {
    final db = await database;
    final where = <String>[];
    final args = <Object?>[];
    if (userId != null) {
      where.add('user_id = ?');
      args.add(userId);
    }
    if (vehicleId != null) {
      where.add('vehicle_id = ?');
      args.add(vehicleId);
    }
    final maps = await db.query(
      'fuel_logs',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: where.isEmpty ? null : args,
      orderBy: 'date ASC',
    );
    return List.generate(maps.length, (i) => FuelLog.fromMap(maps[i]));
  }

  Future<List<FuelLog>> getFuelLogsByVehicleId(
    int userId,
    int vehicleId,
  ) async {
    return await getFuelLogs(userId: userId, vehicleId: vehicleId);
  }

  Future<FuelLog?> getFuelLog(int id, int userId) async {
    final db = await database;
    final maps = await db.query(
      'fuel_logs',
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
    if (maps.isNotEmpty) return FuelLog.fromMap(maps.first);
    return null;
  }

  Future<int> updateFuelLog(int userId, FuelLog log) async {
    final db = await database;
    return await db.update(
      'fuel_logs',
      log.copyWith(userId: userId).toMap(),
      where: 'id = ? AND user_id = ?',
      whereArgs: [log.id, userId],
    );
  }

  Future<int> deleteFuelLog(int userId, int id) async {
    final db = await database;
    return await db.delete(
      'fuel_logs',
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
  }

  Future<List<Map<String, dynamic>>> getMonthlyExpenses(
    int vehicleId,
    int userId,
  ) async {
    final db = await database;
    final maps = await db.rawQuery(
      '''
      SELECT strftime('%Y-%m', date) as month, SUM(total_cost) as total_cost
      FROM fuel_logs
      WHERE vehicle_id = ? AND user_id = ?
      GROUP BY strftime('%Y-%m', date)
      ORDER BY month ASC
    ''',
      [vehicleId, userId],
    );
    return maps;
  }

  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) async {
    final db = await database;
    return await db.rawQuery(sql, arguments);
  }

  Future<int> rawExecute(String sql, [List<Object?>? arguments]) async {
    final db = await database;
    await db.execute(sql, arguments);
    return 0;
  }

  Future close() async {
    final db = await database;
    await db.close();
  }
}
