import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/routes/app_pages.dart';
import '../../../domain/entities/driver_profile_entity.dart';
import '../../controllers/admin_weekly_status_controller.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/section_card.dart';

class WeeklyStatusScreen extends StatefulWidget {
  const WeeklyStatusScreen({super.key});

  @override
  State<WeeklyStatusScreen> createState() => _WeeklyStatusScreenState();
}

class _WeeklyStatusScreenState extends State<WeeklyStatusScreen> {
  final _phonePay = TextEditingController();
  final _roomRentPerDay = TextEditingController();
  final _pendingBalance = TextEditingController();
  String _seedKey = '';

  @override
  void dispose() {
    _phonePay.dispose();
    _roomRentPerDay.dispose();
    _pendingBalance.dispose();
    super.dispose();
  }

  void _seedEditableFields(AdminWeeklyStatusController ctrl) {
    final driver = ctrl.selectedDriver.value;
    if (driver == null) return;

    final filter = ctrl.selectedFilter.value;
    final rangeStart =
        filter == WorkStatusFilter.daily ? ctrl.selectedDate : ctrl.weekStart;
    final key = '${driver.userId}|${filter.name}|${rangeStart.toIso8601String()}';
    if (_seedKey == key) return;
    _seedKey = key;

    final status = ctrl.currentStatus.value;
    final days = ctrl.totalDaysCount.value == 0 ? 1 : ctrl.totalDaysCount.value;
    _phonePay.text = (status?.phonePayReceived ?? 0).toStringAsFixed(2);
    _pendingBalance.text = (status?.pendingBalance ?? 0).toStringAsFixed(2);
    _roomRentPerDay.text =
        ((status?.roomRent ?? 0) / days).toStringAsFixed(2);
  }

  Future<void> _pickDailyDate(
    BuildContext context,
    AdminWeeklyStatusController ctrl,
  ) async {
    final d = await showDatePicker(
      context: context,
      initialDate: ctrl.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (d != null) {
      _seedKey = '';
      await ctrl.pickDailyDate(d);
    }
  }

  Future<void> _pickWeeklyStart(
    BuildContext context,
    AdminWeeklyStatusController ctrl,
  ) async {
    final d = await showDatePicker(
      context: context,
      initialDate: ctrl.weekStart,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (d != null) {
      _seedKey = '';
      await ctrl.pickWeeklyStart(d);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Work Status')),
      body: GetX<AdminWeeklyStatusController>(
        initState: (_) {
          final args = Get.arguments;
          String? driverId;
          if (args is DriverProfileEntity) {
            driverId = args.userId;
          } else if (args is Map && args['driverId'] is String) {
            driverId = args['driverId'] as String;
          }
          _seedKey = '';
          Get.find<AdminWeeklyStatusController>().loadDrivers(
            preferredDriverId: driverId,
          );
        },
        builder: (ctrl) {
          final driver = ctrl.selectedDriver.value;
          _seedEditableFields(ctrl);

          final totalE = ctrl.aggregatedEarnings.value;
          final totalC = ctrl.aggregatedCashCollected.value;
          final cashAgainst = totalE - totalC;
          final commission = totalE * AppConstants.commissionPercent;
          final petrol = ctrl.aggregatedPetrolExpense.value;
          final phoneP = double.tryParse(_phonePay.text) ?? 0;
          final pending = double.tryParse(_pendingBalance.text) ?? 0;
          final roomPerDay = double.tryParse(_roomRentPerDay.text) ?? 0;
          final roomRent = ctrl.calculatedRoomRent(roomPerDay);
          final finalBal =
              (commission + roomRent + petrol) - cashAgainst - phoneP - pending;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (ctrl.isLoading.value) const LinearProgressIndicator(),
                SectionCard(
                  title: 'Select Driver',
                  child: DropdownButtonFormField<DriverProfileEntity>(
                    initialValue: driver,
                    decoration: const InputDecoration(labelText: 'Driver'),
                    items: ctrl.drivers
                        .map((d) => DropdownMenuItem(value: d, child: Text(d.name)))
                        .toList(),
                    onChanged: (d) async {
                      _seedKey = '';
                      await ctrl.selectDriver(d);
                    },
                  ),
                ),
                if (driver != null) ...[
                  const SizedBox(height: 12),
                  SectionCard(
                    title: 'Filter',
                    child: SegmentedButton<WorkStatusFilter>(
                      segments: const [
                        ButtonSegment(
                          value: WorkStatusFilter.daily,
                          label: Text('Daily'),
                          icon: Icon(Icons.today),
                        ),
                        ButtonSegment(
                          value: WorkStatusFilter.weekly,
                          label: Text('Weekly'),
                          icon: Icon(Icons.date_range),
                        ),
                      ],
                      selected: {ctrl.selectedFilter.value},
                      onSelectionChanged: (value) async {
                        _seedKey = '';
                        await ctrl.onFilterChanged(value.first);
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  SectionCard(
                    title: ctrl.selectedFilter.value == WorkStatusFilter.daily
                        ? 'Day'
                        : 'Week (Monday to Sunday)',
                    child: ctrl.selectedFilter.value == WorkStatusFilter.daily
                        ? ListTile(
                            title: const Text('Date'),
                            subtitle:
                                Text(DateFormat.yMMMd().format(ctrl.selectedDate)),
                            trailing: IconButton(
                              onPressed: () => _pickDailyDate(context, ctrl),
                              tooltip: 'Pick date',
                              icon: const Icon(Icons.calendar_month_outlined),
                            ),
                          )
                        : Column(
                            children: [
                              ListTile(
                                title: const Text('Start (Monday)'),
                                subtitle:
                                    Text(DateFormat.yMMMd().format(ctrl.weekStart)),
                                trailing: IconButton(
                                  onPressed: () => _pickWeeklyStart(context, ctrl),
                                  tooltip: 'Pick start date',
                                  icon:
                                      const Icon(Icons.calendar_month_outlined),
                                ),
                              ),
                              ListTile(
                                title: const Text('End (Sunday)'),
                                subtitle:
                                    Text(DateFormat.yMMMd().format(ctrl.weekEnd)),
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 12),
                  SectionCard(
                    title: 'Status',
                    child: Column(
                      children: [
                        _ReadOnlyRow('Total Earnings', totalE),
                        const SizedBox(height: 8),
                        _ReadOnlyRow('Total Cash Collected', totalC),
                        const SizedBox(height: 8),
                        _ReadOnlyRow('Cash collected against Earnings', cashAgainst),
                        const SizedBox(height: 8),
                        _ReadOnlyRow('Commission for fleet (40%)', commission),
                        const SizedBox(height: 8),
                        _ReadOnlyRow('Petrol expense', petrol),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _roomRentPerDay,
                          label: 'Room rent per day',
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 8),
                        _ReadOnlyRow(
                          'Room Rent (includes leave days)',
                          roomRent,
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _phonePay,
                          label: 'Total cash received in PhonePay',
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
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Working days: ${ctrl.nonLeaveDaysCount.value} / ${ctrl.totalDaysCount.value}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Get.toNamed(
                            AppRoutes.adminWeeklySummaryReport,
                            arguments: {
                              'start': ctrl.selectedFilter.value ==
                                      WorkStatusFilter.daily
                                  ? ctrl.selectedDate
                                  : ctrl.weekStart,
                              'end': ctrl.selectedFilter.value ==
                                      WorkStatusFilter.daily
                                  ? ctrl.selectedDate
                                  : ctrl.weekEnd,
                            },
                          ),
                          icon: const Icon(Icons.summarize),
                          label: const Text('View Summary'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: ctrl.isSaving.value
                              ? null
                              : () {
                                  final rangeStart = ctrl.selectedFilter.value ==
                                          WorkStatusFilter.daily
                                      ? ctrl.selectedDate
                                      : ctrl.weekStart;
                                  final rangeEnd = ctrl.selectedFilter.value ==
                                          WorkStatusFilter.daily
                                      ? ctrl.selectedDate
                                      : ctrl.weekEnd;
                                  ctrl.saveWeeklyStatus(
                                    driverId: driver.userId,
                                    driverName: driver.name,
                                    weekStartDate: rangeStart,
                                    weekEndDate: rangeEnd,
                                    totalEarnings: totalE,
                                    totalCashCollected: totalC,
                                    phonePayReceived: phoneP,
                                    roomRent: roomRent,
                                    petrolExpense: petrol,
                                    pendingBalance: pending,
                                  );
                                },
                          child: ctrl.isSaving.value
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Save'),
                        ),
                      ),
                    ],
                  ),
                  if (ctrl.saveSuccess.value) ...[
                    const SizedBox(height: 8),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Status saved successfully.',
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                  if (ctrl.saveError.value.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        ctrl.saveError.value,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
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
        Text(
          '₹ ${value.toStringAsFixed(2)}',
          style: TextStyle(fontWeight: bold ? FontWeight.bold : null),
        ),
      ],
    );
  }
}
