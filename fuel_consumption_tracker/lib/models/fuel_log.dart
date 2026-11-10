class FuelLog {
  final int? id;
  final int userId;
  final int vehicleId;
  final String date;
  final double odometer;
  final double fuelVolume;
  final double totalCost;
  final bool isFullTank;

  FuelLog({
    this.id,
    this.userId = 0,
    required this.vehicleId,
    required this.date,
    required this.odometer,
    required this.fuelVolume,
    required this.totalCost,
    required this.isFullTank,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'vehicle_id': vehicleId,
      'date': date,
      'odometer': odometer,
      'fuel_volume': fuelVolume,
      'total_cost': totalCost,
      'is_full_tank': isFullTank ? 1 : 0,
    };
  }

  factory FuelLog.fromMap(Map<String, dynamic> map) {
    return FuelLog(
      id: map['id'] as int?,
      userId: (map['user_id'] as int?) ?? 0,
      vehicleId: map['vehicle_id'] as int,
      date: map['date'] as String,
      odometer: map['odometer'] as double,
      fuelVolume: map['fuel_volume'] as double,
      totalCost: map['total_cost'] as double,
      isFullTank: map['is_full_tank'] == 1,
    );
  }

  FuelLog copyWith({
    int? id,
    int? userId,
    int? vehicleId,
    String? date,
    double? odometer,
    double? fuelVolume,
    double? totalCost,
    bool? isFullTank,
  }) {
    return FuelLog(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      vehicleId: vehicleId ?? this.vehicleId,
      date: date ?? this.date,
      odometer: odometer ?? this.odometer,
      fuelVolume: fuelVolume ?? this.fuelVolume,
      totalCost: totalCost ?? this.totalCost,
      isFullTank: isFullTank ?? this.isFullTank,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FuelLog &&
        id == other.id &&
        userId == other.userId &&
        vehicleId == other.vehicleId &&
        date == other.date &&
        odometer == other.odometer &&
        fuelVolume == other.fuelVolume &&
        totalCost == other.totalCost &&
        isFullTank == other.isFullTank;
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    vehicleId,
    date,
    odometer,
    fuelVolume,
    totalCost,
    isFullTank,
  );

  @override
  String toString() {
    return 'FuelLog(id: $id, vehicleId: $vehicleId, date: $date, odometer: $odometer, fuelVolume: $fuelVolume, totalCost: $totalCost, isFullTank: $isFullTank)';
  }
}
