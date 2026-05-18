class Vehicle {
  final String? id;
  final String driverId;
  final String type;
  final String plateNumber;
  final String color;
  final String model;
  final int year;

  Vehicle({
    this.id,
    required this.driverId,
    required this.type,
    required this.plateNumber,
    required this.color,
    required this.model,
    required this.year,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id']?.toString() ?? json['_id']?.toString(),
      driverId: json['driverId']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      plateNumber: json['plateNumber']?.toString() ?? '',
      color: json['color']?.toString() ?? '',
      model: json['model']?.toString() ?? '',
      year: json['year'] is int ? json['year'] : int.tryParse(json['year']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'driverId': driverId,
      'type': type,
      'plateNumber': plateNumber,
      'color': color,
      'model': model,
      'year': year,
    };
  }

  Vehicle copyWith({
    String? id,
    String? driverId,
    String? type,
    String? plateNumber,
    String? color,
    String? model,
    int? year,
  }) {
    return Vehicle(
      id: id ?? this.id,
      driverId: driverId ?? this.driverId,
      type: type ?? this.type,
      plateNumber: plateNumber ?? this.plateNumber,
      color: color ?? this.color,
      model: model ?? this.model,
      year: year ?? this.year,
    );
  }
}
