import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/routes/app_pages.dart';
import '../../../core/utils/app_dialogs.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/driver_profile_controller.dart';
import '../../widgets/logout_action_button.dart';
import '../../widgets/navigation_menu_tile.dart';

/// Paste in: lib/presentation/screens/driver/driver_home_screen.dart
class DriverHomeScreen extends StatelessWidget {
  const DriverHomeScreen({super.key});

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
        title: const Text(AppConstants.appName),
        actions: [
          Obx(
            () => LogoutActionButton(
              isLoading: auth.isSigningOut.value,
              onPressed: () => _confirmLogout(context),
            ),
          ),
        ],
      ),
      body: GetX<DriverProfileController>(
        init: Get.find<DriverProfileController>(),
        initState: (_) => Get.find<DriverProfileController>().loadProfile(),
        builder: (profileCtrl) {
          if (profileCtrl.isLoading.value &&
              profileCtrl.profile.value == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final profile = profileCtrl.profile.value;
          final name = profile?.name ?? 'Driver';
          final mobile = profile?.mobileNumber?.trim();
          final hasPhone = mobile != null && mobile.isNotEmpty;
          final phone = hasPhone ? mobile : 'Mobile Number';
          final imagePath = profile?.profileImagePath;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DriverProfileSummaryCard(
                  name: name,
                  phone: phone,
                  isPhonePlaceholder: !hasPhone,
                  imagePath: imagePath,
                  signedUrlLoader: profileCtrl.getSignedUrl,
                  onTap: () => Get.toNamed(AppRoutes.driverProfile),
                ),
                const SizedBox(height: 24),
                NavigationMenuTile(
                  icon: Icons.edit_note,
                  title: 'Daily Entry',
                  subtitle: 'Fill today\'s trip details',
                  margin: EdgeInsets.zero,
                  onTap: () => Get.toNamed(AppRoutes.dailyEntry),
                ),
                NavigationMenuTile(
                  icon: Icons.summarize,
                  title: 'Weekly Summary',
                  subtitle: 'View and download weekly report',
                  margin: const EdgeInsets.only(top: 12),
                  onTap: () => Get.toNamed(AppRoutes.driverWeeklySummary),
                ),
                NavigationMenuTile(
                  icon: Icons.people_alt_outlined,
                  title: 'View All Drivers',
                  subtitle: 'See other drivers and call quickly',
                  margin: const EdgeInsets.only(top: 12),
                  onTap: () => Get.toNamed(AppRoutes.driverContacts),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DriverProfileSummaryCard extends StatelessWidget {
  const _DriverProfileSummaryCard({
    required this.name,
    required this.phone,
    required this.isPhonePlaceholder,
    required this.imagePath,
    required this.signedUrlLoader,
    required this.onTap,
  });

  final String name;
  final String phone;
  final bool isPhonePlaceholder;
  final String? imagePath;
  final Future<String?> Function(String?) signedUrlLoader;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final avatar = imagePath == null || imagePath!.isEmpty
        ? const CircleAvatar(
            radius: 44,
            child: Icon(Icons.person, size: 38),
          )
        : FutureBuilder<String?>(
            future: signedUrlLoader(imagePath),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircleAvatar(
                  radius: 44,
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
                return const CircleAvatar(
                  radius: 44,
                  child: Icon(Icons.person, size: 38),
                );
              }
              return CircleAvatar(
                radius: 44,
                backgroundImage: NetworkImage(snapshot.data!),
              );
            },
          );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: AspectRatio(
          aspectRatio: 1,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Align(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      avatar,
                      const SizedBox(height: 14),
                      Text(
                        name,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        phone,
                        textAlign: TextAlign.center,
                        style: isPhonePlaceholder
                            ? Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                )
                            : Theme.of(context).textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: TextButton(
                  onPressed: onTap,
                  child: const Text('Edit Profile'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
