import '../../domain/entities/user_entity.dart';
import '../../core/constants/firebase_constants.dart';

/// User model with Firestore serialization.
/// Paste in: lib/data/models/user_model.dart
class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
    required super.role,
    super.displayName,
    super.fcmToken,
    super.isSuspended = false,
    super.createdAt,
  });

  factory UserModel.fromEntity(UserEntity e) => UserModel(
        uid: e.uid,
        email: e.email,
        role: e.role,
        displayName: e.displayName,
        fcmToken: e.fcmToken,
        isSuspended: e.isSuspended,
        createdAt: e.createdAt,
      );

  factory UserModel.fromFirestore(Map<String, dynamic> map, String id) {
    return UserModel(
      uid: id,
      email: map[FirebaseConstants.email] as String? ?? '',
      role: map[FirebaseConstants.role] as String? ?? 'driver',
      displayName: map[FirebaseConstants.displayName] as String?,
      fcmToken: map[FirebaseConstants.fcmToken] as String?,
      isSuspended: map[FirebaseConstants.isSuspended] as bool? ?? false,
      createdAt: (map[FirebaseConstants.createdAt] as dynamic)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      FirebaseConstants.uid: uid,
      FirebaseConstants.email: email,
      FirebaseConstants.role: role,
      if (displayName != null) FirebaseConstants.displayName: displayName,
      if (fcmToken != null) FirebaseConstants.fcmToken: fcmToken,
      FirebaseConstants.isSuspended: isSuspended,
      if (createdAt != null) FirebaseConstants.createdAt: createdAt,
    };
  }
}
