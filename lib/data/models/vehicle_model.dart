import '../../core/constants/firebase_constants.dart';
import '../../domain/entities/vehicle_entity.dart';

class VehicleModel extends VehicleEntity {
  const VehicleModel({
    required super.id,
    required super.name,
    required super.number,
    super.createdAt,
    super.updatedAt,
  });

  factory VehicleModel.fromEntity(VehicleEntity e) => VehicleModel(
        id: e.id,
        name: e.name,
        number: e.number,
        createdAt: e.createdAt,
        updatedAt: e.updatedAt,
      );

  factory VehicleModel.fromFirestore(Map<String, dynamic> map, String id) {
    return VehicleModel(
      id: id,
      name: map[FirebaseConstants.name] as String? ?? '',
      number: map[FirebaseConstants.vehicleNumber] as String? ?? '',
      createdAt: map[FirebaseConstants.createdAt] == null
          ? null
          : (map[FirebaseConstants.createdAt] as dynamic).toDate(),
      updatedAt: map['updatedAt'] == null
          ? null
          : (map['updatedAt'] as dynamic).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      FirebaseConstants.name: name,
      FirebaseConstants.vehicleNumber: number,
      if (createdAt != null) FirebaseConstants.createdAt: createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
    };
  }
}
