/// Vehicle master data managed by admin.
class VehicleEntity {
  final String id;
  final String name;
  final String number;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const VehicleEntity({
    required this.id,
    required this.name,
    required this.number,
    this.createdAt,
    this.updatedAt,
  });
}
