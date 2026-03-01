import '../../domain/entities/driver_profile_entity.dart';
import '../../core/constants/firebase_constants.dart';

/// Driver profile model.
/// Paste in: lib/data/models/driver_profile_model.dart
class DriverProfileModel extends DriverProfileEntity {
  const DriverProfileModel({
    required super.id,
    required super.userId,
    required super.name,
    super.age,
    super.address,
    super.place,
    super.pincode,
    super.aadharNumber,
    super.drivingLicenceNumber,
    super.updatedAt,
  });

  factory DriverProfileModel.fromEntity(DriverProfileEntity e) => DriverProfileModel(
        id: e.id,
        userId: e.userId,
        name: e.name,
        age: e.age,
        address: e.address,
        place: e.place,
        pincode: e.pincode,
        aadharNumber: e.aadharNumber,
        drivingLicenceNumber: e.drivingLicenceNumber,
        updatedAt: e.updatedAt,
      );

  factory DriverProfileModel.fromFirestore(Map<String, dynamic> map, String id) {
    return DriverProfileModel(
      id: id,
      userId: map['userId'] as String? ?? map[FirebaseConstants.driverId] as String? ?? id,
      name: map[FirebaseConstants.name] as String? ?? '',
      age: (map[FirebaseConstants.age] as num?)?.toInt(),
      address: map['address'] as String?,
      place: map[FirebaseConstants.place] as String?,
      pincode: map[FirebaseConstants.pincode] as String?,
      aadharNumber: map[FirebaseConstants.aadharNumber] as String?,
      drivingLicenceNumber: map[FirebaseConstants.drivingLicenceNumber] as String?,
      updatedAt: (map['updatedAt'] as dynamic)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      FirebaseConstants.name: name,
      if (age != null) FirebaseConstants.age: age,
      if (address != null) 'address': address,
      if (place != null) FirebaseConstants.place: place,
      if (pincode != null) FirebaseConstants.pincode: pincode,
      if (aadharNumber != null) FirebaseConstants.aadharNumber: aadharNumber,
      if (drivingLicenceNumber != null) FirebaseConstants.drivingLicenceNumber: drivingLicenceNumber,
      'updatedAt': DateTime.now(),
    };
  }
}
