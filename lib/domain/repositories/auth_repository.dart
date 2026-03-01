import '../entities/user_entity.dart';

/// Auth repository contract.
/// Paste in: lib/domain/repositories/auth_repository.dart
abstract class AuthRepository {
  Future<UserEntity?> getCurrentUser();
  Future<UserEntity> signInWithEmailPassword(String email, String password);
  Future<UserEntity> createDriverAccount(String email, String password, String name);
  Future<void> sendPasswordResetEmail(String email);
  Future<void> signOut();
  Stream<UserEntity?> authStateChanges();
}
