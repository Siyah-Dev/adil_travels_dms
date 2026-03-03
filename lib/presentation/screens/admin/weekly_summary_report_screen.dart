import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/utils/pdf_utils.dart';
import '../../../domain/entities/weekly_status_entity.dart';
import '../../controllers/admin_weekly_summary_controller.dart';
import '../../widgets/section_card.dart';

enum SummaryFilterType { daily, weekly }

class WeeklySummaryReportScreen extends StatefulWidget {
  const WeeklySummaryReportScreen({super.key});

  @override
  State<WeeklySummaryReportScreen> createState() => _WeeklySummaryReportScreenState();
}

class _WeeklySummaryReportScreenState extends State<WeeklySummaryReportScreen> {
  SummaryFilterType _filterType = SummaryFilterType.daily;
  DateTime _dailyDate = DateTime.now();
  DateTime? _start;
  DateTime? _end;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      final startArg = args['start'] as DateTime?;
      final endArg = args['end'] as DateTime?;
      if (startArg != null && endArg != null) {
        _filterType = SummaryFilterType.weekly;
        _start = startArg;
        _end = endArg;
      } else if (startArg != null) {
        _dailyDate = startArg;
      }
    }
  }

  Future<void> _load(AdminWeeklySummaryController ctrl) async {
    if (_filterType == SummaryFilterType.daily) {
      final day = DateTime(_dailyDate.year, _dailyDate.month, _dailyDate.day);
      await ctrl.loadSummary(start: day, end: day);
      return;
    } else if (_start != null && _end != null) {
      await ctrl.loadSummary(start: _start!, end: _end!);
      return;
    }
    ErrorHandler.showInfo('Please pick start and end date.', title: 'Select dates');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Summary Report')),
      body: GetX<AdminWeeklySummaryController>(
        initState: (_) {
          final c = Get.find<AdminWeeklySummaryController>();
          c.loadDrivers();
          Future.microtask(() => _load(c));
        },
        builder: (ctrl) {
          final weeklyData = ctrl.filteredWeeklyList;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionCard(
                  title: 'Filter',
                  child: Column(
                    children: [
                      SegmentedButton<SummaryFilterType>(
                        segments: const [
                          ButtonSegment(
                            value: SummaryFilterType.daily,
                            label: Text('Daily'),
                            icon: Icon(Icons.today),
                          ),
                          ButtonSegment(
                            value: SummaryFilterType.weekly,
                            label: Text('Weekly'),
                            icon: Icon(Icons.date_range),
                          ),
                        ],
                        selected: {_filterType},
                        onSelectionChanged: (selection) {
                          setState(() {
                            _filterType = selection.first;
                          });
                          _load(ctrl);
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: ctrl.selectedDriverId.value.isEmpty
                            ? ''
                            : ctrl.selectedDriverId.value,
                        decoration: const InputDecoration(
                          labelText: 'Driver',
                        ),
                        items: [
                          const DropdownMenuItem<String>(
                            value: '',
                            child: Text('All Drivers'),
                          ),
                          ...ctrl.drivers.map(
                            (d) => DropdownMenuItem<String>(
                              value: d.userId,
                              child: Text(d.name),
                            ),
                          ),
                        ],
                        onChanged: (v) {
                          ctrl.setDriverFilter(v);
                        },
                      ),
                      const SizedBox(height: 12),
                      if (_filterType == SummaryFilterType.daily)
                        ListTile(
                          title: const Text('Date'),
                          subtitle: Text(DateFormat.yMMMd().format(_dailyDate)),
                          trailing: IconButton(
                            onPressed: () async {
                              final d = await showDatePicker(
                                context: context,
                                initialDate: _dailyDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                              );
                              if (d != null) {
                                setState(() => _dailyDate = d);
                              }
                            },
                            tooltip: 'Pick date',
                            icon: const Icon(Icons.calendar_month_outlined),
                          ),
                        )
                      else ...[
                        ListTile(
                          title: const Text('Start Date'),
                          subtitle: Text(_start == null
                              ? 'Select'
                              : DateFormat.yMMMd().format(_start!)),
                          trailing: IconButton(
                            onPressed: () async {
                              final d = await showDatePicker(
                                context: context,
                                initialDate: _start ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                              );
                              if (d != null) setState(() => _start = d);
                            },
                            tooltip: 'Pick start date',
                            icon: const Icon(Icons.calendar_month_outlined),
                          ),
                        ),
                        ListTile(
                          title: const Text('End Date'),
                          subtitle: Text(_end == null
                              ? 'Select'
                              : DateFormat.yMMMd().format(_end!)),
                          trailing: IconButton(
                            onPressed: () async {
                              final d = await showDatePicker(
                                context: context,
                                initialDate: _end ?? _start ?? DateTime.now(),
                                firstDate: _start ?? DateTime(2020),
                                lastDate: DateTime.now(),
                              );
                              if (d != null) setState(() => _end = d);
                            },
                            tooltip: 'Pick end date',
                            icon: const Icon(Icons.calendar_month_outlined),
                          ),
                        ),
                      ],
                      ElevatedButton(
                        onPressed: () => _load(ctrl),
                        child: const Text('View Summary'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (ctrl.isLoading.value)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_filterType == SummaryFilterType.daily &&
                    weeklyData.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('No daily status data for this date.'),
                    ),
                  )
                else if (_filterType == SummaryFilterType.weekly &&
                    weeklyData.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('No weekly status data for this period.'),
                    ),
                  )
                else
                  ...weeklyData.map(
                    (s) => _WeeklyBillCard(
                      status: s,
                      onView: () {
                        Future.microtask(() async {
                          try {
                            await PdfUtils.previewWeeklyBill(s);
                          } catch (err) {
                            ErrorHandler.showError(err, title: 'Could not open PDF');
                          }
                        });
                      },
                      onDownload: () {
                        Future.microtask(() async {
                          try {
                            final file = await PdfUtils.generateWeeklyBill(s);
                            if (context.mounted) {
                              ErrorHandler.showSuccess('PDF saved: ${file.path}');
                            }
                          } catch (err) {
                            ErrorHandler.showError(err, title: 'Could not create PDF');
                          }
                        });
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _WeeklyBillCard extends StatelessWidget {
  const _WeeklyBillCard({
    required this.status,
    required this.onView,
    required this.onDownload,
  });

  final WeeklyStatusEntity status;
  final VoidCallback onView;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title:
          '${status.driverName} (${DateFormat.yMMMd().format(status.weekStartDate)} - ${DateFormat.yMMMd().format(status.weekEndDate)})',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Line('Total Earnings', status.totalEarnings),
          _Line('Total Cash Collected', status.totalCashCollected),
          _Line('Cash vs Earnings', status.cashAgainstEarnings),
          _Line('Commission (40%)', status.commissionFleet),
          _Line('PhonePay', status.phonePayReceived),
          _Line('Room Rent', status.roomRent),
          _Line('Petrol', status.petrolExpense),
          _Line('Pending', status.pendingBalance),
          _Line('Final Balance', status.finalBalance, bold: true),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onView,
                  icon: const Icon(Icons.visibility),
                  label: const Text('View PDF'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onDownload,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Download PDF'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line(
    this.label,
    this.value, {
    this.bold = false,
  });

  final String label;
  final dynamic value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final display = '₹ ${(value as num).toStringAsFixed(2)}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: bold ? FontWeight.bold : null)),
          Text(
            display,
            style: TextStyle(fontWeight: bold ? FontWeight.bold : null),
          ),
        ],
      ),
    );
  }
}
