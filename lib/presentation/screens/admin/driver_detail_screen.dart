import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/routes/app_pages.dart';
import '../../../domain/entities/daily_entry_entity.dart';
import '../../controllers/admin_driver_detail_controller.dart';
import '../../widgets/section_card.dart';

/// Paste in: lib/presentation/screens/admin/driver_detail_screen.dart
class DriverDetailScreen extends StatelessWidget {
  const DriverDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final driverId = Get.arguments as String;
    return Scaffold(
      appBar: AppBar(title: const Text('Driver Detail')),
      body: GetX<AdminDriverDetailController>(
        initState: (_) {
          Get.find<AdminDriverDetailController>().loadDriver(driverId);
          Get.find<AdminDriverDetailController>().loadDailyEntries(driverId);
        },
        builder: (ctrl) {
          if (ctrl.loadingProfile.value && ctrl.driver.value == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final d = ctrl.driver.value;
          if (d == null) {
            return const Center(child: Text('Driver not found'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionCard(
                  title: 'Profile',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ProfileRow('Name', d.name),
                      if (d.age != null) _ProfileRow('Age', d.age.toString()),
                      if (d.address != null) _ProfileRow('Address', d.address!),
                      if (d.place != null) _ProfileRow('Place', d.place!),
                      if (d.pincode != null) _ProfileRow('Pincode', d.pincode!),
                      if (d.aadharNumber != null) _ProfileRow('Aadhar', d.aadharNumber!),
                      if (d.drivingLicenceNumber != null) _ProfileRow('Licence', d.drivingLicenceNumber!),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SectionCard(
                  title: 'Daily entries (date wise)',
                  child: ctrl.loadingEntries.value
                      ? const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
                      : ctrl.dailyEntries.isEmpty
                          ? const Text('No entries')
                          : Column(
                              children: ctrl.dailyEntries.map((e) => _EntryTile(entry: e)).toList(),
                            ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => Get.toNamed(
                    AppRoutes.adminWeeklyStatus,
                    arguments: {'driverId': d.userId},
                  ),
                  icon: const Icon(Icons.date_range),
                  label: const Text('Weekly Status'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.w500))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({required this.entry});

  final DailyEntryEntity entry;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(DateFormat.yMMMd().format(entry.date)),
      subtitle: Text(
        'Start ${entry.startKm ?? '-'} km → End ${entry.endKm ?? '-'} km | ₹${entry.totalEarning ?? 0}',
      ),
      dense: true,
    );
  }
}
