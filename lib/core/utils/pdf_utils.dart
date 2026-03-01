import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/weekly_status_entity.dart';

/// Generate weekly summary as a written-bill style PDF.
/// Paste in: lib/core/utils/pdf_utils.dart
class PdfUtils {
  static Future<File> generateWeeklyBill(WeeklyStatusEntity s) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'WEEKLY STATUS - BILL',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 20),
              _line('Driver Name', s.driverName),
              _line('Week', '${DateFormat.yMMMd().format(s.weekStartDate)} - ${DateFormat.yMMMd().format(s.weekEndDate)}'),
              pw.Divider(),
              _line('Total Earnings', '₹ ${s.totalEarnings.toStringAsFixed(2)}'),
              _line('Total Cash Collected', '₹ ${s.totalCashCollected.toStringAsFixed(2)}'),
              _line('Cash collected against Earnings', '₹ ${s.cashAgainstEarnings.toStringAsFixed(2)}'),
              _line('Commission for the fleet (40%)', '₹ ${s.commissionFleet.toStringAsFixed(2)}'),
              _line('Total cash received in PhonePay', '₹ ${s.phonePayReceived.toStringAsFixed(2)}'),
              _line('Room rent', '₹ ${s.roomRent.toStringAsFixed(2)}'),
              _line('Petrol expense', '₹ ${s.petrolExpense.toStringAsFixed(2)}'),
              _line('Pending (-/+) balance', '₹ ${s.pendingBalance.toStringAsFixed(2)}'),
              pw.Divider(),
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 8),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('FINAL BALANCE', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('₹ ${s.finalBalance.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ),
              pw.Spacer(),
              pw.Center(child: pw.Text('Generated on ${DateFormat.yMMMd().add_Hm().format(DateTime.now())}', style: const pw.TextStyle(fontSize: 8))),
            ],
          );
        },
      ),
    );
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/weekly_${s.driverName}_${s.weekStartDate.millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static pw.Widget _line(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label),
          pw.Text(value),
        ],
      ),
    );
  }

  static Future<void> printOrShare(WeeklyStatusEntity s) async {
    final file = await generateWeeklyBill(s);
    await Printing.layoutPdf(onLayout: (_) async => await file.readAsBytes());
  }
}
