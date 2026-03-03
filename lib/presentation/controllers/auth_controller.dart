import 'package:get/get.dart';
import 'dart:async';
import 'package:flutter/widgets.dart';
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
  final RxBool authResolved = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool isSigningOut = false.obs;
  final RxString error = ''.obs;
  StreamSubscription<UserEntity?>? _authSub;
  String? _pendingRoute;

  @override
  void onInit() {
    super.onInit();
    _authSub = _authRepository.authStateChanges().listen((user) {
      currentUser.value = user;
      authResolved.value = true;

      if (user == null) {
        _navigateToAuthIfNeeded();
        return;
      }

      if (user.isSuspended) {
        _navigateIfNeeded(AppRoutes.roleSelection);
        ErrorHandler.showError('Your account has been suspended. Please contact your admin.');
        _authRepository.signOut();
        return;
      }
      final targetRoute = user.role == AppConstants.roleAdmin
          ? AppRoutes.adminHome
          : AppRoutes.driverHome;
      _navigateToHomeIfOutOfScope(targetRoute);
    });
  }

  @override
  void onClose() {
    _authSub?.cancel();
    super.onClose();
  }

  void _navigateIfNeeded(String route) {
    if (Get.key.currentState == null) {
      _pendingRoute = route;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _flushPendingNavigation();
      });
      return;
    }

    if (Get.currentRoute == route) {
      return;
    }
    Get.offAllNamed(route);
  }

  void _flushPendingNavigation() {
    final route = _pendingRoute;
    if (route == null) return;
    if (Get.key.currentState == null) return;
    _pendingRoute = null;
    if (Get.currentRoute != route) {
      Get.offAllNamed(route);
    }
  }

  void _navigateToHomeIfOutOfScope(String homeRoute) {
    final current = Get.currentRoute;
    final isSplash = current == AppRoutes.splash;
    final isAuthRoute = current == AppRoutes.roleSelection ||
        current == AppRoutes.login ||
        current == AppRoutes.register ||
        isSplash ||
        current.isEmpty;

    final inDriverArea = current.startsWith('/driver/');
    final inAdminArea = current.startsWith('/admin/');

    if (homeRoute == AppRoutes.driverHome) {
      if (inDriverArea) return;
      if (isAuthRoute || inAdminArea) {
        _navigateIfNeeded(homeRoute);
      }
      return;
    }

    if (homeRoute == AppRoutes.adminHome) {
      if (inAdminArea) return;
      if (isAuthRoute || inDriverArea) {
        _navigateIfNeeded(homeRoute);
      }
    }
  }

  void _navigateToAuthIfNeeded() {
    final current = Get.currentRoute;
    final inDriverArea = current.startsWith('/driver/');
    final inAdminArea = current.startsWith('/admin/');
    final isSplash = current == AppRoutes.splash;

    if (isSplash || inDriverArea || inAdminArea || current.isEmpty) {
      _navigateIfNeeded(AppRoutes.roleSelection);
    }
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
