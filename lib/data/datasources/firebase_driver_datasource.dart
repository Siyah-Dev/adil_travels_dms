import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/driver_profile_entity.dart';
import '../../domain/entities/daily_entry_entity.dart';
import '../../domain/entities/weekly_status_entity.dart';
import '../models/driver_profile_model.dart';
import '../models/daily_entry_model.dart';
import '../models/weekly_status_model.dart';

/// Firebase driver, daily entry, weekly status datasource.
/// Paste in: lib/data/datasources/firebase_driver_datasource.dart
class FirebaseDriverDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Drivers subcollection under users, or separate collection
  String get _driversPath => AppConstants.driversCollection;
  String get _dailyPath => AppConstants.dailyEntriesCollection;
  String get _weeklyPath => AppConstants.weeklyStatusCollection;

  // --- Driver profile (docId = userId)
  Future<DriverProfileEntity?> getDriverProfile(String userId) async {
    final doc = await _firestore.collection(_driversPath).doc(userId).get();
    if (!doc.exists) return null;
    return DriverProfileModel.fromFirestore(doc.data()!, doc.id);
  }

  Future<void> saveDriverProfile(DriverProfileEntity profile) async {
    final id = profile.id.isEmpty ? profile.userId : profile.id;
    final model = DriverProfileModel(
      id: id,
      userId: profile.userId,
      name: profile.name,
      age: profile.age,
      address: profile.address,
      place: profile.place,
      pincode: profile.pincode,
      aadharNumber: profile.aadharNumber,
      drivingLicenceNumber: profile.drivingLicenceNumber,
      updatedAt: DateTime.now(),
    );
    await _firestore.collection(_driversPath).doc(id).set(
      model.toFirestore(),
      SetOptions(merge: true),
    );
  }

  Future<List<DriverProfileEntity>> getAllDrivers() async {
    final snap = await _firestore.collection(_driversPath).orderBy('name').get();
    return snap.docs.map((d) => DriverProfileModel.fromFirestore(d.data(), d.id)).toList();
  }

  Future<List<DriverProfileEntity>> searchDrivers(String query) async {
    if (query.trim().isEmpty) return getAllDrivers();
    final all = await getAllDrivers();
    final q = query.toLowerCase();
    return all.where((d) => d.name.toLowerCase().contains(q)).toList();
  }

  Future<void> deleteDriver(String driverId) async {
    await _firestore.collection(_driversPath).doc(driverId).delete();
  }

  // --- Daily entries
  Future<String> saveDailyEntry(DailyEntryEntity entry) async {
    final model = DailyEntryModel.fromEntity(entry);
    final data = model.toFirestore();
    data['createdAt'] = DateTime.now();
    data['driverId'] = entry.driverId;
    data['date'] = entry.date;
    if (entry.id.isEmpty) {
      final ref = await _firestore.collection(_dailyPath).add(data);
      return ref.id;
    }
    await _firestore.collection(_dailyPath).doc(entry.id).set(data, SetOptions(merge: true));
    return entry.id;
  }

  Future<String?> getDailyEntryId(String driverId, DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    final q = await _firestore
        .collection(_dailyPath)
        .where('driverId', isEqualTo: driverId)
        .where('date', isGreaterThanOrEqualTo: start)
        .where('date', isLessThan: end)
        .limit(1)
        .get();
    if (q.docs.isEmpty) return null;
    return q.docs.first.id;
  }

  Future<DailyEntryEntity?> getDailyEntry(String driverId, DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    final q = await _firestore
        .collection(_dailyPath)
        .where('driverId', isEqualTo: driverId)
        .where('date', isGreaterThanOrEqualTo: start)
        .where('date', isLessThan: end)
        .limit(1)
        .get();
    if (q.docs.isEmpty) return null;
    final doc = q.docs.first;
    return DailyEntryModel.fromFirestore(doc.data(), doc.id);
  }

  Future<List<DailyEntryEntity>> getDailyEntriesByDriver(String driverId, {DateTime? start, DateTime? end}) async {
    Query<Map<String, dynamic>> q = _firestore.collection(_dailyPath).where('driverId', isEqualTo: driverId);
    if (start != null) q = q.where('date', isGreaterThanOrEqualTo: start);
    if (end != null) q = q.where('date', isLessThanOrEqualTo: end);
    final snap = await q.orderBy('date', descending: true).get();
    return snap.docs.map((d) => DailyEntryModel.fromFirestore(d.data(), d.id)).toList();
  }

  Future<List<DailyEntryEntity>> getDailyEntriesByDate(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    final snap = await _firestore
        .collection(_dailyPath)
        .where('date', isGreaterThanOrEqualTo: start)
        .where('date', isLessThan: end)
        .get();
    return snap.docs.map((d) => DailyEntryModel.fromFirestore(d.data(), d.id)).toList();
  }

  Future<List<DailyEntryEntity>> getEntriesWithMissingMandatoryFields(DateTime date) async {
    final entries = await getDailyEntriesByDate(date);
    return entries.where((e) => !e.hasMandatoryFields).toList();
  }

  // --- Weekly status
  Future<void> saveWeeklyStatus(WeeklyStatusEntity status) async {
    final model = WeeklyStatusModel.fromEntity(status);
    final data = model.toFirestore();
    data['createdAt'] = DateTime.now();
    if (status.id.isEmpty) {
      await _firestore.collection(_weeklyPath).add(data);
      return;
    }
    await _firestore.collection(_weeklyPath).doc(status.id).set(data, SetOptions(merge: true));
  }

  Future<WeeklyStatusEntity?> getWeeklyStatus(String driverId, DateTime weekStart) async {
    final start = DateTime(weekStart.year, weekStart.month, weekStart.day);
    final q = await _firestore
        .collection(_weeklyPath)
        .where('driverId', isEqualTo: driverId)
        .where('weekStartDate', isEqualTo: start)
        .limit(1)
        .get();
    if (q.docs.isEmpty) return null;
    final doc = q.docs.first;
    return WeeklyStatusModel.fromFirestore(doc.data(), doc.id);
  }

  Future<List<WeeklyStatusEntity>> getWeeklyStatusesByDriver(String driverId, {DateTime? start, DateTime? end}) async {
    Query<Map<String, dynamic>> q = _firestore.collection(_weeklyPath).where('driverId', isEqualTo: driverId);
    if (start != null) q = q.where('weekStartDate', isGreaterThanOrEqualTo: start);
    if (end != null) q = q.where('weekStartDate', isLessThanOrEqualTo: end);
    final snap = await q.orderBy('weekStartDate', descending: true).get();
    return snap.docs.map((d) => WeeklyStatusModel.fromFirestore(d.data(), d.id)).toList();
  }

  Future<List<WeeklyStatusEntity>> getWeeklyStatusesInRange(DateTime start, DateTime end) async {
    final snap = await _firestore
        .collection(_weeklyPath)
        .where('weekStartDate', isGreaterThanOrEqualTo: start)
        .where('weekStartDate', isLessThanOrEqualTo: end)
        .orderBy('weekStartDate')
        .get();
    return snap.docs.map((d) => WeeklyStatusModel.fromFirestore(d.data(), d.id)).toList();
  }
}
