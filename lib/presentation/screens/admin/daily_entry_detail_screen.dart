import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/daily_entry_entity.dart';
import '../../widgets/section_card.dart';

class DailyEntryDetailScreen extends StatelessWidget {
  const DailyEntryDetailScreen({super.key});

  String _num(double? v) => v == null ? '-' : v.toStringAsFixed(2);
  String _txt(String? v) => (v == null || v.trim().isEmpty) ? '-' : v;

  @override
  Widget build(BuildContext context) {
    final entry = Get.arguments as DailyEntryEntity?;
    if (entry == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Entry Details')),
        body: const Center(child: Text('Entry data not found.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Entry Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SectionCard(
              title: 'Driver & Date',
              child: Column(
                children: [
                  _DetailRow(label: 'Driver Name', value: _txt(entry.driverName)),
                  _DetailRow(label: 'Driver ID', value: _txt(entry.driverId)),
                  _DetailRow(
                    label: 'Date',
                    value: DateFormat.yMMMd().format(entry.date),
                  ),
                  _DetailRow(
                    label: 'Leave on Today',
                    value: entry.leaveOnToday ? 'Yes' : 'No',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SectionCard(
              title: 'Trip',
              child: Column(
                children: [
                  _DetailRow(label: 'Vehicle Number', value: _txt(entry.vehicleNumber)),
                  _DetailRow(label: 'Starting Kilometer', value: _num(entry.startKm)),
                  _DetailRow(label: 'Starting Time', value: _txt(entry.startTime)),
                  _DetailRow(label: 'Ending Kilometer', value: _num(entry.endKm)),
                  _DetailRow(label: 'Ending Time', value: _txt(entry.endTime)),
                  _DetailRow(label: 'Fuel Amount', value: _num(entry.fuelAmount)),
                  _DetailRow(label: 'Fuel Paid By', value: _txt(entry.fuelPaidBy)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SectionCard(
              title: 'Earnings & Services',
              child: Column(
                children: [
                  _DetailRow(label: 'Services Used', value: _txt(entry.servicesUsed)),
                  _DetailRow(label: 'Total Earning', value: _num(entry.totalEarning)),
                  _DetailRow(label: 'Cash Collected', value: _num(entry.cashCollected)),
                  _DetailRow(label: 'Private Trip Cash', value: _num(entry.privateTripCash)),
                  _DetailRow(label: 'Toll Paid by Customer', value: _num(entry.tollPaidByCustomer)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
