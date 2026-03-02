import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/error_handler.dart';
import '../../../domain/entities/weekly_status_entity.dart';
import '../../controllers/admin_weekly_summary_controller.dart';
import '../../widgets/section_card.dart';
import '../../../core/utils/pdf_utils.dart';

/// Paste in: lib/presentation/screens/admin/weekly_summary_report_screen.dart
class WeeklySummaryReportScreen extends StatefulWidget {
  const WeeklySummaryReportScreen({super.key});

  @override
  State<WeeklySummaryReportScreen> createState() => _WeeklySummaryReportScreenState();
}

class _WeeklySummaryReportScreenState extends State<WeeklySummaryReportScreen> {
  DateTime? _start;
  DateTime? _end;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      _start = args['start'] as DateTime?;
      _end = args['end'] as DateTime?;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weekly Summary Report')),
      body: GetX<AdminWeeklySummaryController>(
        initState: (_) {
          if (_start != null && _end != null) {
            Get.find<AdminWeeklySummaryController>().loadSummary(start: _start!, end: _end!);
          }
        },
        builder: (ctrl) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionCard(
                  title: 'Filter',
                  child: Column(
                    children: [
                      ListTile(
                        title: const Text('Start Date'),
                        subtitle: Text(_start == null ? 'Select' : DateFormat.yMMMd().format(_start!)),
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
                        subtitle: Text(_end == null ? 'Select' : DateFormat.yMMMd().format(_end!)),
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
                      ElevatedButton(
                        onPressed: () {
                          if (_start != null && _end != null) {
                            ctrl.loadSummary(start: _start!, end: _end!);
                          } else {
                            ErrorHandler.showInfo('Please pick start and end date.', title: 'Select dates');
                          }
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
                  const Card(child: Padding(padding: EdgeInsets.all(24), child: Text('No data for this period.')))
                else
                  ...ctrl.list.map((s) => _BillCard(
                        status: s,
                        onDownload: () {
                          Future.microtask(() async {
                            try {
                              final file = await PdfUtils.generateWeeklyBill(s);
                              if (context.mounted) {
                                ErrorHandler.showSuccess('PDF saved: ${file.path}');
                              }
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

class _BillCard extends StatelessWidget {
  const _BillCard({required this.status, required this.onDownload});

  final WeeklyStatusEntity status;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: '${status.driverName} (${DateFormat.yMMMd().format(status.weekStartDate)} - ${DateFormat.yMMMd().format(status.weekEndDate)})',
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

class _Line extends StatelessWidget {
  const _Line(this.label, this.value, {this.bold = false});

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
