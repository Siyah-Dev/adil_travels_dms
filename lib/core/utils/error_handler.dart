import 'package:firebase_auth/firebase_auth.dart';
import 'app_dialogs.dart';
import 'app_snackbar.dart';

/// Central error handling: user-friendly messages and error popup/snackbar.
/// Paste in: lib/core/utils/error_handler.dart
class ErrorHandler {
  ErrorHandler._();

  /// Returns a short, user-friendly message for the exception.
  static String message(Object e, {String? fallback}) {
    if (e is String) return e;
    final msg = fallback ?? 'Something went wrong. Please try again.';
    final str = e.toString().toLowerCase();

    // Firebase Auth
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
        case 'invalid-email':
          return 'Invalid email or password. Please check and try again.';
        case 'email-already-in-use':
          return 'This email is already registered. Try logging in or use another email.';
        case 'weak-password':
          return 'Password is too weak. Use at least 6 characters.';
        case 'operation-not-allowed':
          return 'Login is not enabled. Please contact support.';
        case 'too-many-requests':
          return 'Too many attempts. Please try again later.';
        case 'network-request-failed':
          return 'No internet connection. Please check your network and try again.';
        case 'user-disabled':
          return 'This account has been disabled. Please contact support.';
        default:
          return e.message ?? msg;
      }
    }

    // Firestore / generic
    if (str.contains('permission-denied') || str.contains('permission_denied')) {
      return 'You don\'t have permission to do this.';
    }
    if (str.contains('unavailable') || str.contains('network')) {
      return 'No internet connection. Please try again.';
    }
    if (str.contains('not found') || str.contains('document not found')) {
      return 'Account not set up. Please contact your admin.';
    }
    if (str.contains('already exists')) {
      return 'This is already saved.';
    }

    // Strip "Exception: " for generic exceptions
    if (e is Exception) {
      final text = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
      if (text.length < 120) return text;
    }
    return msg;
  }

  /// Shows an error popup (dialog) with a user-friendly message.
  static void showError(Object e, {String? title, String? fallback}) {
    final msg = message(e, fallback: fallback);
    AppDialogs.alert(
      title: title ?? 'Error',
      message: msg,
      barrierDismissible: false,
    );
  }

  /// Shows a short success snackbar.
  static void showSuccess(String message, {String title = 'Success'}) {
    AppSnackbars.success(title, message);
  }

  /// Shows a short info/warning snackbar (e.g. validation).
  static void showInfo(String message, {String title = 'Notice'}) {
    AppSnackbars.info(title, message);
  }
}
