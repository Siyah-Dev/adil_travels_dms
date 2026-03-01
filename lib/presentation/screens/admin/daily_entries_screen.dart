import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/daily_entry_entity.dart';
import '../../controllers/admin_daily_entries_controller.dart';
import '../../widgets/section_card.dart';

/// Paste in: lib/presentation/screens/admin/daily_entries_screen.dart
class DailyEntriesScreen extends StatelessWidget {
  const DailyEntriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Entries')),
      body: GetX<AdminDailyEntriesController>(
        initState: (_) => Get.find<AdminDailyEntriesController>().loadEntriesForDate(DateTime.now()),
        builder: (ctrl) {
          return Column(
            children: [
              SectionCard(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Text(DateFormat.yMMMd().format(ctrl.selectedDate)),
                    const Spacer(),
                    TextButton(
                      onPressed: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: ctrl.selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now().add(const Duration(days: 1)),
                        );
                        if (d != null) ctrl.loadEntriesForDate(d);
                      },
                      child: const Text('Change date'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ctrl.isLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : ctrl.entries.isEmpty
                        ? const Center(child: Text('No entries for this date'))
                        : ListView.builder(
                            itemCount: ctrl.entries.length,
                            itemBuilder: (_, i) {
                              final e = ctrl.entries[i];
                              return _EntryCard(entry: e);
                            },
                          ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({required this.entry});

  final DailyEntryEntity entry;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        title: Text(entry.driverName),
        subtitle: Text(
          '${entry.vehicleNumber ?? '-'} | ${entry.startKm ?? '-'} - ${entry.endKm ?? '-'} km | Earning ₹${entry.totalEarning ?? 0}',
        ),
      ),
    );
  }
}
