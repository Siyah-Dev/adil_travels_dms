import 'package:get/get.dart';
import '../../core/constants/app_constants.dart';
import '../../core/routes/app_pages.dart';
import '../../core/utils/error_handler.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

/// Paste in: lib/presentation/controllers/auth_controller.dart
class AuthController extends GetxController {
  AuthController(this._authRepository);

  final AuthRepository _authRepository;

  final Rx<UserEntity?> currentUser = Rx<UserEntity?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isSigningOut = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _authRepository.authStateChanges().listen((user) {
      currentUser.value = user;
      if (user != null) {
        if (user.isSuspended) {
          _navigateIfNeeded(AppRoutes.roleSelection);
          ErrorHandler.showError('Your account has been suspended. Please contact your admin.');
          _authRepository.signOut();
          return;
        }
        final targetRoute = user.role == AppConstants.roleAdmin
            ? AppRoutes.adminHome
            : AppRoutes.driverHome;
        _navigateIfNeeded(targetRoute);
      }
    });
  }

  void _navigateIfNeeded(String route) {
    if (Get.currentRoute == route) {
      return;
    }
    Get.offAllNamed(route);
  }

  Future<void> signIn(String email, String password) async {
    try {
      isLoading.value = true;
      error.value = '';
      await _authRepository.signInWithEmailPassword(email, password);
    } catch (e) {
      final msg = ErrorHandler.message(e);
      error.value = msg;
      ErrorHandler.showError(e, title: 'Login failed', fallback: msg);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createDriverAccount(String email, String password, String name) async {
    try {
      isLoading.value = true;
      error.value = '';
      await _authRepository.createDriverAccount(email, password, name);
    } catch (e) {
      final msg = ErrorHandler.message(e);
      error.value = msg;
      ErrorHandler.showError(e, title: 'Registration failed', fallback: msg);
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> sendPasswordReset(String email) async {
    try {
      isLoading.value = true;
      error.value = '';
      await _authRepository.sendPasswordResetEmail(email.trim());
      ErrorHandler.showSuccess(
        'Password reset email sent. Please check your inbox.',
        title: 'Email Sent',
      );
      return true;
    } catch (e) {
      final msg = ErrorHandler.message(e);
      error.value = msg;
      ErrorHandler.showInfo(msg, title: 'Reset password failed');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> signOut() async {
    if (isSigningOut.value) return false;

    try {
      isSigningOut.value = true;
      await _authRepository.signOut();
      ErrorHandler.showSuccess('You have been logged out.', title: 'Logged out');
      _navigateIfNeeded(AppRoutes.roleSelection);
      return true;
    } catch (e) {
      ErrorHandler.showError(e, title: 'Sign out failed');
      return false;
    } finally {
      isSigningOut.value = false;
    }
  }
}
