import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/firebase_constants.dart';
import '../../domain/entities/driver_profile_entity.dart';
import '../../domain/entities/daily_entry_entity.dart';
import '../../domain/entities/weekly_status_entity.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../models/driver_profile_model.dart';
import '../models/daily_entry_model.dart';
import '../models/weekly_status_model.dart';
import '../models/vehicle_model.dart';

/// Firebase driver, daily entry, weekly status datasource.
/// Paste in: lib/data/datasources/firebase_driver_datasource.dart
class FirebaseDriverDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Drivers subcollection under users, or separate collection
  String get _driversPath => AppConstants.driversCollection;
  String get _vehiclesPath => AppConstants.vehiclesCollection;
  String get _dailyPath => AppConstants.dailyEntriesCollection;
  String get _weeklyPath => AppConstants.weeklyStatusCollection;

  String _dailyEntryDocId(String driverId, DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    final mm = day.month.toString().padLeft(2, '0');
    final dd = day.day.toString().padLeft(2, '0');
    return '${driverId}_${day.year}$mm$dd';
  }

  String _vehicleDocId(String number) {
    return number.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
  }

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
      mobileNumber: profile.mobileNumber,
      aadharNumber: profile.aadharNumber,
      drivingLicenceNumber: profile.drivingLicenceNumber,
      profileImagePath: profile.profileImagePath,
      aadharImagePath: profile.aadharImagePath,
      drivingLicenceImagePath: profile.drivingLicenceImagePath,
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

  // --- Vehicles
  Future<List<VehicleEntity>> getVehicles() async {
    final snap = await _firestore
        .collection(_vehiclesPath)
        .orderBy(FirebaseConstants.createdAt, descending: true)
        .get();
    return snap.docs.map((d) => VehicleModel.fromFirestore(d.data(), d.id)).toList();
  }

  Future<void> addVehicle(String name, String number) async {
    final trimmedName = name.trim();
    final trimmedNumber = number.trim();
    final id = _vehicleDocId(trimmedNumber);
    await _firestore.collection(_vehiclesPath).doc(id).set({
      FirebaseConstants.name: trimmedName,
      FirebaseConstants.vehicleNumber: trimmedNumber,
      FirebaseConstants.createdAt: FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> deleteVehicle(String number) async {
    final id = _vehicleDocId(number);
    final directRef = _firestore.collection(_vehiclesPath).doc(id);
    final direct = await directRef.get();
    if (direct.exists) {
      await directRef.delete();
      return;
    }

    final fallback = await _firestore
        .collection(_vehiclesPath)
        .where(FirebaseConstants.vehicleNumber, isEqualTo: number.trim())
        .limit(1)
        .get();
    if (fallback.docs.isNotEmpty) {
      await fallback.docs.first.reference.delete();
    }
  }

  // --- Daily entries
  Future<String> saveDailyEntry(DailyEntryEntity entry) async {
    final model = DailyEntryModel.fromEntity(entry);
    final data = model.toFirestore();
    data['driverId'] = entry.driverId;
    data['date'] = DateTime(entry.date.year, entry.date.month, entry.date.day);
    data['updatedAt'] = FieldValue.serverTimestamp();
    if (entry.createdAt == null) {
      data['createdAt'] = FieldValue.serverTimestamp();
    }

    final docId = entry.id.isNotEmpty ? entry.id : _dailyEntryDocId(entry.driverId, entry.date);
    final docRef = _firestore.collection(_dailyPath).doc(docId);
    await docRef.set(data, SetOptions(merge: true));
    return docId;
  }

  Future<String?> getDailyEntryId(String driverId, DateTime date) async {
    final docId = _dailyEntryDocId(driverId, date);
    final doc = await _firestore.collection(_dailyPath).doc(docId).get();
    if (doc.exists) return doc.id;

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
    final docId = _dailyEntryDocId(driverId, date);
    final doc = await _firestore.collection(_dailyPath).doc(docId).get();
    if (doc.exists) {
      return DailyEntryModel.fromFirestore(doc.data()!, doc.id);
    }

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
    final matchedDoc = q.docs.first;
    return DailyEntryModel.fromFirestore(matchedDoc.data(), matchedDoc.id);
  }

  Future<List<DailyEntryEntity>> getDailyEntriesByDriver(String driverId, {DateTime? start, DateTime? end}) async {
    Query<Map<String, dynamic>> q = _firestore.collection(_dailyPath).where('driverId', isEqualTo: driverId);
    if (start != null) q = q.where('date', isGreaterThanOrEqualTo: start);
    if (end != null) q = q.where('date', isLessThanOrEqualTo: end);

    try {
      final snap = await q.get();
      final entries = snap.docs.map((d) => DailyEntryModel.fromFirestore(d.data(), d.id)).toList();
      entries.sort((a, b) => b.date.compareTo(a.date));
      return entries;
    } on FirebaseException catch (e) {
      // Fallback when Firestore composite index is not configured for this range query.
      if (e.code != 'failed-precondition') rethrow;

      final baseSnap = await _firestore
          .collection(_dailyPath)
          .where('driverId', isEqualTo: driverId)
          .get();

      final baseEntries = baseSnap.docs.map((d) => DailyEntryModel.fromFirestore(d.data(), d.id)).toList();
      final filtered = baseEntries.where((entry) {
        final day = DateTime(entry.date.year, entry.date.month, entry.date.day);
        final afterStart = start == null || !day.isBefore(DateTime(start.year, start.month, start.day));
        final beforeEnd = end == null || !day.isAfter(DateTime(end.year, end.month, end.day));
        return afterStart && beforeEnd;
      }).toList();

      filtered.sort((a, b) => b.date.compareTo(a.date));
      return filtered;
    }
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
    try {
      final q = await _firestore
          .collection(_weeklyPath)
          .where('driverId', isEqualTo: driverId)
          .where('weekStartDate', isEqualTo: start)
          .limit(1)
          .get();
      if (q.docs.isEmpty) return null;
      final doc = q.docs.first;
      return WeeklyStatusModel.fromFirestore(doc.data(), doc.id);
    } on FirebaseException catch (e) {
      // Fallback when Firestore composite index is not configured.
      if (e.code != 'failed-precondition') rethrow;

      final base = await _firestore
          .collection(_weeklyPath)
          .where('driverId', isEqualTo: driverId)
          .get();
      for (final doc in base.docs) {
        final status = WeeklyStatusModel.fromFirestore(doc.data(), doc.id);
        final s = DateTime(
          status.weekStartDate.year,
          status.weekStartDate.month,
          status.weekStartDate.day,
        );
        if (s == start) return status;
      }
      return null;
    }
  }

  Future<List<WeeklyStatusEntity>> getWeeklyStatusesByDriver(String driverId, {DateTime? start, DateTime? end}) async {
    Query<Map<String, dynamic>> q = _firestore.collection(_weeklyPath).where('driverId', isEqualTo: driverId);
    if (start != null) q = q.where('weekStartDate', isGreaterThanOrEqualTo: start);
    if (end != null) q = q.where('weekStartDate', isLessThanOrEqualTo: end);

    try {
      final snap = await q.get();
      final statuses = snap.docs.map((d) => WeeklyStatusModel.fromFirestore(d.data(), d.id)).toList();
      statuses.sort((a, b) => b.weekStartDate.compareTo(a.weekStartDate));
      return statuses;
    } on FirebaseException catch (e) {
      if (e.code != 'failed-precondition') rethrow;

      final baseSnap = await _firestore
          .collection(_weeklyPath)
          .where('driverId', isEqualTo: driverId)
          .get();
      final base = baseSnap.docs.map((d) => WeeklyStatusModel.fromFirestore(d.data(), d.id)).toList();
      final filtered = base.where((status) {
        final day = DateTime(
          status.weekStartDate.year,
          status.weekStartDate.month,
          status.weekStartDate.day,
        );
        final afterStart = start == null ||
            !day.isBefore(DateTime(start.year, start.month, start.day));
        final beforeEnd = end == null ||
            !day.isAfter(DateTime(end.year, end.month, end.day));
        return afterStart && beforeEnd;
      }).toList();

      filtered.sort((a, b) => b.weekStartDate.compareTo(a.weekStartDate));
      return filtered;
    }
  }

  Future<List<WeeklyStatusEntity>> getWeeklyStatusesInRange(DateTime start, DateTime end) async {
    try {
      final snap = await _firestore
          .collection(_weeklyPath)
          .where('weekStartDate', isGreaterThanOrEqualTo: start)
          .where('weekStartDate', isLessThanOrEqualTo: end)
          .get();
      final statuses = snap.docs.map((d) => WeeklyStatusModel.fromFirestore(d.data(), d.id)).toList();
      statuses.sort((a, b) => a.weekStartDate.compareTo(b.weekStartDate));
      return statuses;
    } on FirebaseException catch (e) {
      if (e.code != 'failed-precondition') rethrow;

      final base = await _firestore.collection(_weeklyPath).get();
      final statuses = base.docs
          .map((d) => WeeklyStatusModel.fromFirestore(d.data(), d.id))
          .where((status) {
        final day = DateTime(
          status.weekStartDate.year,
          status.weekStartDate.month,
          status.weekStartDate.day,
        );
        return !day.isBefore(DateTime(start.year, start.month, start.day)) &&
            !day.isAfter(DateTime(end.year, end.month, end.day));
      }).toList();
      statuses.sort((a, b) => a.weekStartDate.compareTo(b.weekStartDate));
      return statuses;
    }
  }
}
