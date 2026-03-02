import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/error_handler.dart';
import '../../../domain/entities/weekly_status_entity.dart';
import '../../controllers/driver_weekly_summary_controller.dart';
import '../../widgets/section_card.dart';
import '../../../core/utils/pdf_utils.dart';

/// Paste in: lib/presentation/screens/driver/weekly_summary_screen.dart
class DriverWeeklySummaryScreen extends StatefulWidget {
  const DriverWeeklySummaryScreen({super.key});

  @override
  State<DriverWeeklySummaryScreen> createState() => _DriverWeeklySummaryScreenState();
}

class _DriverWeeklySummaryScreenState extends State<DriverWeeklySummaryScreen> {
  DateTime? _start;
  DateTime? _end;
  DateTime? _day;
  bool _isDailyFilter = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weekly Summary')),
      body: GetX<DriverWeeklySummaryController>(
        builder: (ctrl) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionCard(
                  title: _isDailyFilter ? 'Filter by day' : 'Filter by week',
                  child: Column(
                    children: [
                      SegmentedButton<bool>(
                        showSelectedIcon: false,
                        segments: const [
                          ButtonSegment<bool>(
                            value: false,
                            label: Text('Weekly'),
                            icon: Icon(Icons.date_range_outlined),
                          ),
                          ButtonSegment<bool>(
                            value: true,
                            label: Text('Daily'),
                            icon: Icon(Icons.today_outlined),
                          ),
                        ],
                        selected: {_isDailyFilter},
                        onSelectionChanged: (selection) {
                          setState(() {
                            _isDailyFilter = selection.first;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      if (_isDailyFilter)
                        ListTile(
                          title: const Text('Date'),
                          subtitle: Text(_day == null ? 'Select' : DateFormat.yMMMd().format(_day!)),
                          trailing: IconButton(
                            onPressed: () async {
                              final now = DateTime.now();
                              var initialDate = _day ?? now;
                              if (initialDate.isAfter(now)) {
                                initialDate = now;
                              }
                              final d = await showDatePicker(
                                context: context,
                                initialDate: initialDate,
                                firstDate: DateTime(2020),
                                lastDate: now,
                              );
                              if (d != null) setState(() => _day = d);
                            },
                            tooltip: 'Pick date',
                            icon: const Icon(Icons.calendar_month_outlined),
                          ),
                        ),
                      if (!_isDailyFilter) ...[
                        ListTile(
                          title: const Text('Start Date'),
                          subtitle: Text(_start == null ? 'Select' : DateFormat.yMMMd().format(_start!)),
                          trailing: IconButton(
                            onPressed: () async {
                              final now = DateTime.now();
                              var initialDate = _start ?? _end ?? now;
                              if (initialDate.isAfter(now)) {
                                initialDate = now;
                              }
                              final d = await showDatePicker(
                                context: context,
                                initialDate: initialDate,
                                firstDate: DateTime(2020),
                                lastDate: now,
                              );
                              if (d != null) {
                                setState(() {
                                  _start = d;
                                  if (_end != null && _end!.isBefore(d)) {
                                    _end = null;
                                  }
                                });
                              }
                            },
                            tooltip: 'Pick start date',
                            icon: const Icon(Icons.calendar_month_outlined),
                          ),
                        ),
                        ListTile(
                          title: const Text('End Date'),
                          subtitle: Text(_end == null ? 'Select' : DateFormat.yMMMd().format(_end!)),
                          trailing: IconButton(
                            onPressed: () async {
                              final now = DateTime.now();
                              var initialDate = _end ?? _start ?? now;
                              if (initialDate.isAfter(now)) {
                                initialDate = now;
                              }
                              final d = await showDatePicker(
                                context: context,
                                initialDate: initialDate,
                                firstDate: DateTime(2020),
                                lastDate: now,
                              );
                              if (d != null) {
                                if (_start != null && d.isBefore(_start!)) {
                                  ErrorHandler.showInfo(
                                    'End date cannot be before start date.',
                                    title: 'Invalid end date',
                                  );
                                  return;
                                }
                                setState(() => _end = d);
                              }
                            },
                            tooltip: 'Pick end date',
                            icon: const Icon(Icons.calendar_month_outlined),
                          ),
                        ),
                      ],
                      ElevatedButton(
                        onPressed: () {
                          if (_isDailyFilter) {
                            if (_day != null) {
                              ctrl.loadSummaryByDay(_day!);
                            } else {
                              ErrorHandler.showInfo(
                                'Please pick a date.',
                                title: 'Select date',
                              );
                            }
                            return;
                          }

                          if (_start == null || _end == null) {
                            ErrorHandler.showInfo('Please pick start and end date.', title: 'Select dates');
                            return;
                          }

                          ctrl.loadSummary(start: _start, end: _end);
                        },
                        child: const Text('View Summary'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (ctrl.isLoading.value)
                  const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
                else if (ctrl.list.isEmpty)
                  const Card(child: Padding(padding: EdgeInsets.all(24), child: Text('No summary for this period.')))
                else
                  ...ctrl.list.map((s) => _SummaryCard(
                        status: s,
                        onDownload: () {
                        Future.microtask(() async {
                          try {
                            final file = await PdfUtils.generateWeeklyBill(s);
                            ErrorHandler.showSuccess('PDF saved: ${file.path}');
                          } catch (e) {
                            ErrorHandler.showError(e, title: 'Could not create PDF');
                          }
                        });
                      },
                      )),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.status, required this.onDownload});

  final WeeklyStatusEntity status;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: '${status.driverName} (${DateFormat.yMMMd().format(status.weekStartDate)} - ${DateFormat.yMMMd().format(status.weekEndDate)})',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Row('Total Earnings', status.totalEarnings),
          _Row('Total Cash Collected', status.totalCashCollected),
          _Row('Cash vs Earnings', status.cashAgainstEarnings),
          _Row('Commission (40%)', status.commissionFleet),
          _Row('PhonePay', status.phonePayReceived),
          _Row('Room Rent', status.roomRent),
          _Row('Petrol', status.petrolExpense),
          _Row('Pending', status.pendingBalance),
          _Row('Final Balance', status.finalBalance, bold: true),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onDownload,
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Download PDF'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value, {this.bold = false});

  final String label;
  final double value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: bold ? FontWeight.bold : null)),
          Text('₹ ${value.toStringAsFixed(2)}', style: TextStyle(fontWeight: bold ? FontWeight.bold : null)),
        ],
      ),
    );
  }
}
