import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/driver_profile_entity.dart';
import '../../../domain/entities/weekly_status_entity.dart';
import '../../controllers/admin_weekly_status_controller.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/section_card.dart';
import '../../../core/routes/app_pages.dart';

/// Paste in: lib/presentation/screens/admin/weekly_status_screen.dart
class WeeklyStatusScreen extends StatefulWidget {
  const WeeklyStatusScreen({super.key});

  @override
  State<WeeklyStatusScreen> createState() => _WeeklyStatusScreenState();
}

class _WeeklyStatusScreenState extends State<WeeklyStatusScreen> {
  final _totalEarnings = TextEditingController();
  final _totalCashCollected = TextEditingController();
  final _phonePay = TextEditingController();
  final _roomRent = TextEditingController();
  final _petrolExpense = TextEditingController();
  final _pendingBalance = TextEditingController();
  bool _filled = false;

  @override
  void dispose() {
    _totalEarnings.dispose();
    _totalCashCollected.dispose();
    _phonePay.dispose();
    _roomRent.dispose();
    _petrolExpense.dispose();
    _pendingBalance.dispose();
    super.dispose();
  }

  void _fillFromStatus(WeeklyStatusEntity? s) {
    if (s == null || _filled) return;
    _filled = true;
    _totalEarnings.text = s.totalEarnings.toStringAsFixed(2);
    _totalCashCollected.text = s.totalCashCollected.toStringAsFixed(2);
    _phonePay.text = s.phonePayReceived.toStringAsFixed(2);
    _roomRent.text = s.roomRent.toStringAsFixed(2);
    _petrolExpense.text = s.petrolExpense.toStringAsFixed(2);
    _pendingBalance.text = s.pendingBalance.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weekly Status')),
      body: GetX<AdminWeeklyStatusController>(
        initState: (_) {
          final args = Get.arguments;
          String? driverId;
          if (args is DriverProfileEntity) {
            driverId = args.userId;
          } else if (args is Map && args['driverId'] is String) {
            driverId = args['driverId'] as String;
          }
          _filled = false;
          Get.find<AdminWeeklyStatusController>().loadDrivers(
            preferredDriverId: driverId,
          );
        },
        builder: (ctrl) {
          final s = ctrl.currentStatus.value;
          if (s != null) WidgetsBinding.instance.addPostFrameCallback((_) => _fillFromStatus(s));
          final driver = ctrl.selectedDriver.value;
          final cashAgainst = (double.tryParse(_totalEarnings.text) ?? 0) - (double.tryParse(_totalCashCollected.text) ?? 0);
          final commission = (double.tryParse(_totalEarnings.text) ?? 0) * AppConstants.commissionPercent;
          final totalE = double.tryParse(_totalEarnings.text) ?? 0;
          final totalC = double.tryParse(_totalCashCollected.text) ?? 0;
          final phoneP = double.tryParse(_phonePay.text) ?? 0;
          final room = double.tryParse(_roomRent.text) ?? 0;
          final petrol = double.tryParse(_petrolExpense.text) ?? 0;
          final pending = double.tryParse(_pendingBalance.text) ?? 0;
          final finalBal = (commission + room + petrol) - cashAgainst - phoneP - pending;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SectionCard(
                  title: 'Select Driver',
                  child: DropdownButtonFormField<DriverProfileEntity>(
                    initialValue: driver,
                    decoration: const InputDecoration(labelText: 'Driver'),
                    items: ctrl.drivers
                        .map((d) => DropdownMenuItem(value: d, child: Text(d.name)))
                        .toList(),
                    onChanged: (d) {
                      _filled = false;
                      ctrl.selectDriver(d);
                    },
                  ),
                ),
                if (driver != null) ...[
                  const SizedBox(height: 12),
                  SectionCard(
                    title: 'Week',
                    child: Column(
                      children: [
                        ListTile(
                          title: const Text('Start'),
                          subtitle: Text(DateFormat.yMMMd().format(ctrl.weekStart)),
                          trailing: IconButton(
                            onPressed: () async {
                              final d = await showDatePicker(
                                context: context,
                                initialDate: ctrl.weekStart,
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                              );
                              if (d != null) {
                                _filled = false;
                                ctrl.loadWeeklyStatus(driver.userId, d);
                              }
                            },
                            tooltip: 'Pick start date',
                            icon: const Icon(Icons.calendar_month_outlined),
                          ),
                        ),
                        ListTile(
                          title: const Text('End'),
                          subtitle: Text(DateFormat.yMMMd().format(ctrl.weekEnd)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SectionCard(
                    title: 'Amounts',
                    child: Column(
                      children: [
                        AppTextField(
                          controller: _totalEarnings,
                          label: 'Total Earnings',
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _totalCashCollected,
                          label: 'Total Cash Collected',
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 8),
                        _ReadOnlyRow('Cash collected against Earnings', cashAgainst),
                        const SizedBox(height: 8),
                        _ReadOnlyRow('Commission for fleet (40%)', commission),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _phonePay,
                          label: 'Total cash received in PhonePay',
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _roomRent,
                          label: 'Room rent',
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _petrolExpense,
                          label: 'Petrol expense',
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _pendingBalance,
                          label: 'Pending (-/+) balance',
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 8),
                        _ReadOnlyRow('Final Balance', finalBal, bold: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child:                       OutlinedButton.icon(
                          onPressed: () => Get.toNamed(
                            AppRoutes.adminWeeklySummaryReport,
                            arguments: {'start': ctrl.weekStart, 'end': ctrl.weekEnd},
                          ),
                          icon: const Icon(Icons.summarize),
                          label: const Text('View Summary'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            ctrl.saveWeeklyStatus(
                              driverId: driver.userId,
                              driverName: driver.name,
                              weekStartDate: ctrl.weekStart,
                              weekEndDate: ctrl.weekEnd,
                              totalEarnings: totalE,
                              totalCashCollected: totalC,
                              phonePayReceived: phoneP,
                              roomRent: room,
                              petrolExpense: petrol,
                              pendingBalance: pending,
                            );
                          },
                          child: const Text('Save'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ReadOnlyRow extends StatelessWidget {
  const _ReadOnlyRow(this.label, this.value, {this.bold = false});

  final String label;
  final double value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontWeight: bold ? FontWeight.bold : null)),
        Text('₹ ${value.toStringAsFixed(2)}', style: TextStyle(fontWeight: bold ? FontWeight.bold : null)),
      ],
    );
  }
}
