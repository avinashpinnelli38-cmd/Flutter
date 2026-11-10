class Vehicle {
  final int? id;
  final int userId;
  final String name;
  final String fuelType;
  final double tankCapacity;

  Vehicle({
    this.id,
    this.userId = 0,
    required this.name,
    required this.fuelType,
    required this.tankCapacity,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'name': name,
      'fuel_type': fuelType,
      'tank_capacity': tankCapacity,
    };
  }

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      id: map['id'] as int?,
      userId: (map['user_id'] as int?) ?? 0,
      name: map['name'] as String,
      fuelType: map['fuel_type'] as String,
      tankCapacity: map['tank_capacity'] as double,
    );
  }

  Vehicle copyWith({
    int? id,
    int? userId,
    String? name,
    String? fuelType,
    double? tankCapacity,
  }) {
    return Vehicle(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      fuelType: fuelType ?? this.fuelType,
      tankCapacity: tankCapacity ?? this.tankCapacity,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Vehicle &&
        id == other.id &&
        userId == other.userId &&
        name == other.name &&
        fuelType == other.fuelType &&
        tankCapacity == other.tankCapacity;
  }

  @override
  int get hashCode => Object.hash(id, userId, name, fuelType, tankCapacity);

  @override
  String toString() {
    return 'Vehicle(id: $id, name: $name, fuelType: $fuelType, tankCapacity: $tankCapacity)';
  }
}
