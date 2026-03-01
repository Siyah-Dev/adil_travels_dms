import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_datasource.dart';

/// Paste in: lib/data/repositories/auth_repository_impl.dart
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDatasource _datasource = FirebaseAuthDatasource();

  @override
  Future<UserEntity?> getCurrentUser() => _datasource.getCurrentUser();

  @override
  Future<UserEntity> signInWithEmailPassword(String email, String password) =>
      _datasource.signInWithEmailPassword(email, password);

  @override
  Future<UserEntity> createDriverAccount(String email, String password, String name) =>
      _datasource.createDriverAccount(email, password, name);

  @override
  Future<void> sendPasswordResetEmail(String email) =>
      _datasource.sendPasswordResetEmail(email);

  @override
  Future<void> signOut() => _datasource.signOut();

  @override
  Stream<UserEntity?> authStateChanges() => _datasource.authStateChanges();
}
