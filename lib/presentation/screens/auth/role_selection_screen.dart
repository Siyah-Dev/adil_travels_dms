import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/routes/app_pages.dart';
import '../../../core/theme/app_theme.dart';

/// Paste in: lib/presentation/screens/auth/role_selection_screen.dart
class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    // color: Colors.white,
                    // borderRadius: BorderRadius.circular(20),
                    // border: Border.all(color: AppTheme.accentColor, width: 2),
                  ),
                  child: Image.asset(
                    AppConstants.logoAsset,
                    height: 180,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 20),
                // Text(
                //   AppConstants.appName,
                //   textAlign: TextAlign.center,
                //   style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                //     color: AppTheme.primaryColor,
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: () => Get.toNamed(AppRoutes.login),
                  icon: const Icon(Icons.login),
                  label: const Text('Login'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => Get.toNamed(AppRoutes.register),
                  icon: const Icon(Icons.person_add),
                  label: const Text('Create account (Driver)'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
