import 'package:flutter/material.dart';

import '../models/vehicle.dart';
import '../models/fuel_log.dart';
import '../services/database_helper.dart';

class FuelProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  int? _currentUserId;

  List<Vehicle> _vehicles = [];
  List<FuelLog> _fuelLogs = [];
  List<Map<String, dynamic>> _mileageRecords = [];
  List<Map<String, dynamic>> _monthlyExpenses = [];
  Vehicle? _selectedVehicle;

  bool _notifyScheduled = false;

  void _scheduleNotify() {
    if (_notifyScheduled) return;
    _notifyScheduled = true;
    Future.microtask(() {
      _notifyScheduled = false;
      notifyListeners();
    });
  }

  int? get currentUserId => _currentUserId;

  List<Vehicle> get vehicles => _vehicles;
  List<FuelLog> get fuelLogs => _fuelLogs;
  List<Map<String, dynamic>> get mileageRecords => _mileageRecords;
  List<Map<String, dynamic>> get monthlyExpenses => _monthlyExpenses;
  Vehicle? get selectedVehicle => _selectedVehicle;

  set selectedVehicle(Vehicle? vehicle) {
    _selectedVehicle = vehicle;
    _scheduleNotify();
  }

  int _requireUserId() {
    final id = _currentUserId;
    if (id == null) {
      throw StateError('No user session. Sign in or continue as guest first.');
    }
    return id;
  }

  /// Binds this provider to the signed-in user and loads their data.
  Future<void> setCurrentUser(int userId) async {
    _currentUserId = userId;
    await loadAll();
  }

  /// Clears the session and all in-memory data (used on sign out).
  void clearSession() {
    _currentUserId = null;
    _vehicles = [];
    _fuelLogs = [];
    _mileageRecords = [];
    _monthlyExpenses = [];
    _selectedVehicle = null;
    _scheduleNotify();
  }

  Future<void> loadVehicles() async {
    final userId = _currentUserId;
    if (userId == null) {
      _vehicles = [];
      _scheduleNotify();
      return;
    }
    _vehicles = await _db.getVehicles(userId);
    _scheduleNotify();
  }

  Future<void> addVehicle(Vehicle vehicle) async {
    await _db.insertVehicle(_requireUserId(), vehicle);
    await loadVehicles();
    _scheduleNotify();
  }

  Future<void> updateVehicle(Vehicle vehicle) async {
    await _db.updateVehicle(_requireUserId(), vehicle);
    await loadVehicles();
    _scheduleNotify();
  }

  Future<void> deleteVehicle(int id) async {
    await _db.deleteVehicle(_requireUserId(), id);
    await loadVehicles();
    if (_selectedVehicle?.id == id) _selectedVehicle = null;
    _scheduleNotify();
  }

  Future<void> loadFuelLogs() async {
    final userId = _currentUserId;
    if (_selectedVehicle != null && userId != null) {
      _fuelLogs = await _db.getFuelLogsByVehicleId(
        userId,
        _selectedVehicle!.id!,
      );
    } else {
      _fuelLogs = [];
    }
    _scheduleNotify();
  }

  Future<void> addFuelLog(FuelLog log) async {
    await _db.insertFuelLog(_requireUserId(), log);
    if (_selectedVehicle != null) {
      await loadFuelLogs();
      calculateMileage();
    }
    _scheduleNotify();
  }

  Future<void> updateFuelLog(FuelLog log) async {
    await _db.updateFuelLog(_requireUserId(), log);
    if (_selectedVehicle != null) {
      await loadFuelLogs();
      calculateMileage();
    }
    _scheduleNotify();
  }

  Future<void> deleteFuelLog(int id) async {
    await _db.deleteFuelLog(_requireUserId(), id);
    if (_selectedVehicle != null) {
      await loadFuelLogs();
      calculateMileage();
    }
    _scheduleNotify();
  }

  void calculateMileage() {
    if (_selectedVehicle == null || _fuelLogs.isEmpty) {
      _mileageRecords = [];
      _scheduleNotify();
      return;
    }

    final sorted = List<FuelLog>.from(_fuelLogs)
      ..sort((a, b) => a.date.compareTo(b.date));
    final records = <Map<String, dynamic>>[];

    int? refIndex;
    for (int i = 0; i < sorted.length; i++) {
      if (sorted[i].isFullTank) {
        refIndex = i;
        break;
      }
    }

    if (refIndex == null || refIndex == sorted.length - 1) {
      _mileageRecords = records;
      _scheduleNotify();
      return;
    }

    double accumulatedFuel = 0.0;
    double accumulatedCost = 0.0;
    double refOdometer = sorted[refIndex].odometer;
    String refDate = sorted[refIndex].date;

    for (int i = refIndex + 1; i < sorted.length; i++) {
      final log = sorted[i];
      accumulatedFuel += log.fuelVolume;
      accumulatedCost += log.totalCost;

      if (log.isFullTank) {
        final distance = log.odometer - refOdometer;
        final mileage = distance > 0 ? distance / accumulatedFuel : 0.0;
        final totalCost = accumulatedCost;
        final costPerKm = distance > 0 ? totalCost / distance : 0.0;

        records.add({
          'reference_date': refDate,
          'end_date': log.date,
          'start_odometer': refOdometer,
          'end_odometer': log.odometer,
          'distance': distance,
          'fuel_consumed': accumulatedFuel,
          'mileage': mileage,
          'cost_per_km': costPerKm,
          'total_cost': totalCost,
          'vehicle_id': log.vehicleId,
        });

        refOdometer = log.odometer;
        refDate = log.date;
        accumulatedFuel = 0.0;
        accumulatedCost = 0.0;
      }
    }

    _mileageRecords = records;
    _scheduleNotify();
  }

  Future<void> loadMonthlyExpenses() async {
    final userId = _currentUserId;
    if (_selectedVehicle != null && userId != null) {
      _monthlyExpenses = await _db.getMonthlyExpenses(
        _selectedVehicle!.id!,
        userId,
      );
    } else {
      _monthlyExpenses = [];
    }
    _scheduleNotify();
  }

  void selectVehicle(Vehicle vehicle) {
    _selectedVehicle = vehicle;
    loadFuelLogs();
    calculateMileage();
    loadMonthlyExpenses();
    _scheduleNotify();
  }

  Future<void> addVehicleAndSelect(Vehicle vehicle) async {
    await addVehicle(vehicle);
    if (_vehicles.isNotEmpty) {
      _selectedVehicle = _vehicles.last;
      await loadFuelLogs();
      calculateMileage();
      await loadMonthlyExpenses();
    }
    _scheduleNotify();
  }

  Future<void> loadAll() async {
    await loadVehicles();
    if (_selectedVehicle != null) {
      await loadFuelLogs();
      calculateMileage();
      await loadMonthlyExpenses();
    } else if (_vehicles.isNotEmpty) {
      _selectedVehicle = _vehicles.first;
      await loadFuelLogs();
      calculateMileage();
      await loadMonthlyExpenses();
    }
    _scheduleNotify();
  }

  Future<void> clearAllData() async {
    final userId = _currentUserId;
    if (userId == null) return;
    for (final vehicle in _vehicles) {
      await _db.deleteVehicle(userId, vehicle.id!);
    }
    _vehicles = [];
    _fuelLogs = [];
    _mileageRecords = [];
    _monthlyExpenses = [];
    _selectedVehicle = null;
    _scheduleNotify();
  }
}
