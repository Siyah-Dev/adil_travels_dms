/// Driver profile entity.
/// Paste in: lib/domain/entities/driver_profile_entity.dart
class DriverProfileEntity {
  final String id;
  final String userId;
  final String name;
  final int? age;
  final String? address;
  final String? place;
  final String? pincode;
  final String? mobileNumber;
  final String? aadharNumber;
  final String? drivingLicenceNumber;
  final DateTime? updatedAt;

  const DriverProfileEntity({
    required this.id,
    required this.userId,
    required this.name,
    this.age,
    this.address,
    this.place,
    this.pincode,
    this.mobileNumber,
    this.aadharNumber,
    this.drivingLicenceNumber,
    this.updatedAt,
  });
}
