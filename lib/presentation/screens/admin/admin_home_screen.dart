import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/routes/app_pages.dart';
import '../../../core/utils/app_dialogs.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/logout_action_button.dart';
import '../../widgets/navigation_menu_tile.dart';

/// Paste in: lib/presentation/screens/admin/admin_home_screen.dart
class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final auth = Get.find<AuthController>();
    if (auth.isSigningOut.value) return;

    final shouldLogout = await AppDialogs.confirm(
      title: 'Confirm Logout',
      message: 'Are you sure you want to log out?',
    );

    if (shouldLogout) {
      await auth.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('${AppConstants.appName} - Admin'),
        actions: [
          Obx(
            () => LogoutActionButton(
              isLoading: auth.isSigningOut.value,
              onPressed: () => _confirmLogout(context),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          NavigationMenuTile(
            icon: Icons.people,
            title: 'Manage Drivers',
            subtitle: 'View, search, delete, suspend drivers',
            margin: EdgeInsets.zero,
            onTap: () => Get.toNamed(AppRoutes.adminDriverList),
          ),
          NavigationMenuTile(
            icon: Icons.calendar_today,
            title: 'Daily Entries',
            subtitle: 'View drivers\' daily entries by date',
            onTap: () => Get.toNamed(AppRoutes.adminDailyEntries),
          ),
          NavigationMenuTile(
            icon: Icons.date_range,
            title: 'Weekly Status',
            subtitle: 'Add and manage weekly status per driver',
            onTap: () => Get.toNamed(AppRoutes.adminWeeklyStatus),
          ),
          NavigationMenuTile(
            icon: Icons.summarize,
            title: 'View Summary Report',
            subtitle: 'Filter by date range and download PDF',
            onTap: () => Get.toNamed(AppRoutes.adminWeeklySummaryReport),
          ),
        ],
      ),
    );
  }
}
