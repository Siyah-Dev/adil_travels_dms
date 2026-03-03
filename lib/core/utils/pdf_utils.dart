import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/daily_entry_entity.dart';
import '../../domain/entities/weekly_status_entity.dart';

/// Generate weekly summary as a written-bill style PDF.
/// Paste in: lib/core/utils/pdf_utils.dart
class PdfUtils {
  static Future<File> generateWeeklyBill(WeeklyStatusEntity s) async {
    final isDailyStatus = DateTime(
          s.weekStartDate.year,
          s.weekStartDate.month,
          s.weekStartDate.day,
        ) ==
        DateTime(
          s.weekEndDate.year,
          s.weekEndDate.month,
          s.weekEndDate.day,
        );

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
                  isDailyStatus ? 'DAILY STATUS - BILL' : 'WEEKLY STATUS - BILL',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 20),
              _line('Driver Name', s.driverName),
              _line(
                isDailyStatus ? 'Date' : 'Week',
                '${DateFormat.yMMMd().format(s.weekStartDate)} - ${DateFormat.yMMMd().format(s.weekEndDate)}',
              ),
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

  static Future<File> generateDailyBill(DailyEntryEntity e) async {
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
                  'DAILY SUMMARY - BILL',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 20),
              _line('Driver Name', e.driverName),
              _line('Driver ID', e.driverId),
              _line('Date', DateFormat.yMMMd().format(e.date)),
              _line('Leave On Today', e.leaveOnToday ? 'Yes' : 'No'),
              pw.Divider(),
              _line('Vehicle Number', e.vehicleNumber ?? '-'),
              _line('Start KM', e.startKm?.toStringAsFixed(2) ?? '-'),
              _line('End KM', e.endKm?.toStringAsFixed(2) ?? '-'),
              _line('Fuel Amount', '₹ ${(e.fuelAmount ?? 0).toStringAsFixed(2)}'),
              _line('Fuel Paid By', e.fuelPaidBy ?? '-'),
              _line('Total Earnings', '₹ ${(e.totalEarning ?? 0).toStringAsFixed(2)}'),
              _line('Cash Collected', '₹ ${(e.cashCollected ?? 0).toStringAsFixed(2)}'),
              _line('Services Used', e.servicesUsed ?? '-'),
              _line('Private Trip Cash', '₹ ${(e.privateTripCash ?? 0).toStringAsFixed(2)}'),
              _line('Toll Paid By Customer', '₹ ${(e.tollPaidByCustomer ?? 0).toStringAsFixed(2)}'),
              pw.Spacer(),
              pw.Center(
                child: pw.Text(
                  'Generated on ${DateFormat.yMMMd().add_Hm().format(DateTime.now())}',
                  style: const pw.TextStyle(fontSize: 8),
                ),
              ),
            ],
          );
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File(
      '${dir.path}/daily_${e.driverName}_${DateTime(e.date.year, e.date.month, e.date.day).millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static Future<File> generateDriverDailySummaryBill({
    required String driverName,
    required DateTime date,
    required List<DailyEntryEntity> entries,
  }) async {
    final pdf = pw.Document();
    final totalEarnings = entries.fold<double>(0, (sum, e) => sum + (e.totalEarning ?? 0));
    final totalCash = entries.fold<double>(0, (sum, e) => sum + (e.cashCollected ?? 0));
    final totalFuel = entries.fold<double>(0, (sum, e) => sum + (e.fuelAmount ?? 0));

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => [
          pw.Center(
            child: pw.Text(
              'DAILY DRIVER SUMMARY',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 12),
          _line('Driver Name', driverName),
          _line('Date', DateFormat.yMMMd().format(date)),
          _line('Entries', entries.length.toString()),
          pw.Divider(),
          ...entries.map((e) => pw.Column(
                children: [
                  _line('Vehicle', e.vehicleNumber ?? '-'),
                  _line('Start/End KM', '${e.startKm ?? '-'} / ${e.endKm ?? '-'}'),
                  _line('Total Earnings', '₹ ${(e.totalEarning ?? 0).toStringAsFixed(2)}'),
                  _line('Cash Collected', '₹ ${(e.cashCollected ?? 0).toStringAsFixed(2)}'),
                  _line('Fuel Amount', '₹ ${(e.fuelAmount ?? 0).toStringAsFixed(2)}'),
                  _line('Leave', e.leaveOnToday ? 'Yes' : 'No'),
                  pw.Divider(),
                ],
              )),
          _line('Total Earnings', '₹ ${totalEarnings.toStringAsFixed(2)}'),
          _line('Total Cash Collected', '₹ ${totalCash.toStringAsFixed(2)}'),
          _line('Total Fuel Amount', '₹ ${totalFuel.toStringAsFixed(2)}'),
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File(
      '${dir.path}/daily_driver_${driverName}_${DateTime(date.year, date.month, date.day).millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static Future<File> generateDriverWeeklySummaryBill({
    required String driverName,
    required DateTime start,
    required DateTime end,
    required List<WeeklyStatusEntity> statuses,
  }) async {
    final pdf = pw.Document();

    final totalEarnings = statuses.fold<double>(0, (sum, s) => sum + s.totalEarnings);
    final totalCash = statuses.fold<double>(0, (sum, s) => sum + s.totalCashCollected);
    final totalCommission = statuses.fold<double>(0, (sum, s) => sum + s.commissionFleet);
    final totalPhonePay = statuses.fold<double>(0, (sum, s) => sum + s.phonePayReceived);
    final totalRoom = statuses.fold<double>(0, (sum, s) => sum + s.roomRent);
    final totalPetrol = statuses.fold<double>(0, (sum, s) => sum + s.petrolExpense);
    final totalPending = statuses.fold<double>(0, (sum, s) => sum + s.pendingBalance);
    final totalFinal = statuses.fold<double>(0, (sum, s) => sum + s.finalBalance);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => [
          pw.Center(
            child: pw.Text(
              'WEEKLY DRIVER SUMMARY',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 12),
          _line('Driver Name', driverName),
          _line('Period', '${DateFormat.yMMMd().format(start)} - ${DateFormat.yMMMd().format(end)}'),
          _line('Weeks', statuses.length.toString()),
          pw.Divider(),
          ...statuses.map((s) => pw.Column(
                children: [
                  _line(
                    'Week',
                    '${DateFormat.yMMMd().format(s.weekStartDate)} - ${DateFormat.yMMMd().format(s.weekEndDate)}',
                  ),
                  _line('Total Earnings', '₹ ${s.totalEarnings.toStringAsFixed(2)}'),
                  _line('Total Cash Collected', '₹ ${s.totalCashCollected.toStringAsFixed(2)}'),
                  _line('Commission', '₹ ${s.commissionFleet.toStringAsFixed(2)}'),
                  _line('Final Balance', '₹ ${s.finalBalance.toStringAsFixed(2)}'),
                  pw.Divider(),
                ],
              )),
          _line('Total Earnings', '₹ ${totalEarnings.toStringAsFixed(2)}'),
          _line('Total Cash Collected', '₹ ${totalCash.toStringAsFixed(2)}'),
          _line('Total Commission', '₹ ${totalCommission.toStringAsFixed(2)}'),
          _line('Total PhonePay', '₹ ${totalPhonePay.toStringAsFixed(2)}'),
          _line('Total Room Rent', '₹ ${totalRoom.toStringAsFixed(2)}'),
          _line('Total Petrol Expense', '₹ ${totalPetrol.toStringAsFixed(2)}'),
          _line('Total Pending', '₹ ${totalPending.toStringAsFixed(2)}'),
          _line('Total Final Balance', '₹ ${totalFinal.toStringAsFixed(2)}'),
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File(
      '${dir.path}/weekly_driver_${driverName}_${start.millisecondsSinceEpoch}_${end.millisecondsSinceEpoch}.pdf',
    );
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

  static Future<void> previewWeeklyBill(WeeklyStatusEntity s) async {
    final file = await generateWeeklyBill(s);
    await Printing.layoutPdf(onLayout: (_) async => await file.readAsBytes());
  }

  static Future<void> previewDailyBill(DailyEntryEntity e) async {
    final file = await generateDailyBill(e);
    await Printing.layoutPdf(onLayout: (_) async => await file.readAsBytes());
  }

  static Future<void> shareWeeklyBill(WeeklyStatusEntity s) async {
    final file = await generateWeeklyBill(s);
    await Printing.sharePdf(
      bytes: await file.readAsBytes(),
      filename: file.path.split(Platform.pathSeparator).last,
    );
  }

  static Future<void> previewDriverDailySummaryBill({
    required String driverName,
    required DateTime date,
    required List<DailyEntryEntity> entries,
  }) async {
    final file = await generateDriverDailySummaryBill(
      driverName: driverName,
      date: date,
      entries: entries,
    );
    await Printing.layoutPdf(onLayout: (_) async => await file.readAsBytes());
  }

  static Future<void> previewDriverWeeklySummaryBill({
    required String driverName,
    required DateTime start,
    required DateTime end,
    required List<WeeklyStatusEntity> statuses,
  }) async {
    final file = await generateDriverWeeklySummaryBill(
      driverName: driverName,
      start: start,
      end: end,
      statuses: statuses,
    );
    await Printing.layoutPdf(onLayout: (_) async => await file.readAsBytes());
  }
}
