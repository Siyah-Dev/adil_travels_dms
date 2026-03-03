import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/services/supabase_storage_service.dart';
import '../../../core/utils/error_handler.dart';
import '../../controllers/driver_contacts_controller.dart';

class DriverContactsScreen extends StatelessWidget {
  const DriverContactsScreen({super.key});

  Future<void> _call(String? mobileNumber) async {
    final number = mobileNumber?.trim() ?? '';
    if (number.isEmpty) {
      ErrorHandler.showInfo(
        'Mobile number is not available.',
        title: 'Cannot call',
      );
      return;
    }

    final uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      return;
    }
    ErrorHandler.showInfo('Could not open dialer.', title: 'Call failed');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Drivers')),
      body: GetX<DriverContactsController>(
        initState: (_) => Get.find<DriverContactsController>().loadDrivers(),
        builder: (ctrl) {
          if (ctrl.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (ctrl.drivers.isEmpty) {
            return const Center(child: Text('No other drivers found.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: ctrl.drivers.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final driver = ctrl.drivers[i];
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  leading: _DriverAvatar(imagePath: driver.profileImagePath),
                  title: Text(
                    driver.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    (driver.mobileNumber == null ||
                            driver.mobileNumber!.trim().isEmpty)
                        ? 'Mobile Number not available'
                        : driver.mobileNumber!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    onPressed: () => _call(driver.mobileNumber),
                    tooltip: 'Call',
                    icon: const Icon(Icons.call),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _DriverAvatar extends StatelessWidget {
  const _DriverAvatar({required this.imagePath});

  final String? imagePath;

  Future<String?> _loadImageUrl() async {
    if (imagePath == null || imagePath!.trim().isEmpty) return null;
    try {
      return await SupabaseStorageService.createSignedUrl(imagePath!);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (imagePath == null || imagePath!.trim().isEmpty) {
      return const CircleAvatar(child: Icon(Icons.person));
    }

    return FutureBuilder<String?>(
      future: _loadImageUrl(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircleAvatar(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }
        final url = snapshot.data;
        if (url == null || url.isEmpty) {
          return const CircleAvatar(child: Icon(Icons.person));
        }
        return CircleAvatar(backgroundImage: NetworkImage(url));
      },
    );
  }
}
