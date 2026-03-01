/// User entity (admin or driver).
/// Paste in: lib/domain/entities/user_entity.dart
class UserEntity {
  final String uid;
  final String email;
  final String role; // admin | driver
  final String? displayName;
  final String? fcmToken;
  final bool isSuspended;
  final DateTime? createdAt;

  const UserEntity({
    required this.uid,
    required this.email,
    required this.role,
    this.displayName,
    this.fcmToken,
    this.isSuspended = false,
    this.createdAt,
  });
}
