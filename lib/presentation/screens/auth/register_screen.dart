import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/app_text_field.dart';

/// Driver registration screen.
/// Paste in: lib/presentation/screens/auth/register_screen.dart
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _resetFormState(AuthController auth) {
    _formKey.currentState?.reset();
    _name.clear();
    _email.clear();
    _password.clear();
    _confirmPassword.clear();
    auth.error.value = '';
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create account'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _resetFormState(Get.find<AuthController>());
            Get.back();
          },
        ),
      ),
      body: Obx(
        () => SingleChildScrollView(
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
                    height: 110,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 20),
                AppTextField(
                  controller: _name,
                  label: 'Name',
                  hint: 'Your full name',
                  onChanged: (_) {
                    if (auth.error.value.isNotEmpty) auth.error.value = '';
                  },
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _email,
                  label: 'Email',
                  hint: 'Enter email',
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (_) {
                    if (auth.error.value.isNotEmpty) auth.error.value = '';
                  },
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _password,
                  label: 'Password',
                  hint: 'Min 6 characters',
                  obscureText: true,
                  enableObscureToggle: true,
                  onChanged: (_) {
                    if (auth.error.value.isNotEmpty) auth.error.value = '';
                  },
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (v.length < 6) return 'At least 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _confirmPassword,
                  label: 'Confirm password',
                  hint: 'Re-enter password',
                  obscureText: true,
                  enableObscureToggle: true,
                  onChanged: (_) {
                    if (auth.error.value.isNotEmpty) auth.error.value = '';
                  },
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (v != _password.text) return 'Passwords do not match';
                    return null;
                  },
                ),
                if (auth.error.value.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    auth.error.value,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: auth.isLoading.value
                      ? null
                      : () {
                          if (_formKey.currentState?.validate() ?? false) {
                            auth.createDriverAccount(
                              _email.text.trim(),
                              _password.text,
                              _name.text.trim(),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(minimumSize: const Size(0, 48)),
                  child: auth.isLoading.value
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Create account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
