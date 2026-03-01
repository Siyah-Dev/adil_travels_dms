import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/routes/app_pages.dart';
import '../../../core/utils/app_dialogs.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/app_text_field.dart';

/// Paste in: lib/presentation/screens/auth/login_screen.dart
class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final _email = TextEditingController();
  final _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _resetFormState(AuthController auth) {
    _formKey.currentState?.reset();
    _email.clear();
    _password.clear();
    auth.error.value = '';
  }

  Future<void> _showForgotPasswordDialog(AuthController auth) async {
    final email = await AppDialogs.promptText(
      title: 'Reset Password',
      label: 'Email',
      hint: 'Enter your account email',
      keyboardType: TextInputType.emailAddress,
      confirmText: 'Send Link',
      initialValue: _email.text.trim(),
    );

    if (email == null) return;
    if (email.isEmpty || !email.contains('@')) {
      AppSnackbars.info('Invalid email', 'Please enter a valid email address.');
      return;
    }

    await auth.sendPasswordReset(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: GetBuilder<AuthController>(
        builder: (auth) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  Center(
                    child: Image.asset(
                      AppConstants.logoAsset,
                      height: 120,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    controller: _email,
                    label: 'Email',
                    hint: 'Enter email',
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _password,
                    label: 'Password',
                    hint: 'Enter password',
                    obscureText: true,
                    enableObscureToggle: true,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: auth.isLoading.value
                          ? null
                          : () => _showForgotPasswordDialog(auth),
                      child: const Text('Forgot password?'),
                    ),
                  ),
                  if (auth.error.value.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      auth.error.value,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: auth.isLoading.value
                        ? null
                        : () {
                            if (_formKey.currentState?.validate() ?? false) {
                              auth.signIn(_email.text.trim(), _password.text);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                    ),
                    child: auth.isLoading.value
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Login'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      _resetFormState(auth);
                      Get.toNamed(AppRoutes.register);
                    },
                    child: const Text('Create account (Driver)'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
