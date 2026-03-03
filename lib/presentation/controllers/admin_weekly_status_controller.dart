import 'package:get/get.dart';
import '../../core/utils/error_handler.dart';
import '../../domain/entities/driver_profile_entity.dart';
import '../../domain/entities/weekly_status_entity.dart';
import '../../domain/repositories/driver_repository.dart';

enum WorkStatusFilter { daily, weekly }

/// Paste in: lib/presentation/controllers/admin_weekly_status_controller.dart
class AdminWeeklyStatusController extends GetxController {
  AdminWeeklyStatusController(this._repo);

  final DriverRepository _repo;

  final RxList<DriverProfileEntity> drivers = <DriverProfileEntity>[].obs;
  final Rx<DriverProfileEntity?> selectedDriver = Rx<DriverProfileEntity?>(null);
  final Rx<WeeklyStatusEntity?> currentStatus = Rx<WeeklyStatusEntity?>(null);
  final Rx<WorkStatusFilter> selectedFilter = WorkStatusFilter.daily.obs;
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxString saveError = ''.obs;
  final RxBool saveSuccess = false.obs;

  final RxDouble aggregatedEarnings = 0.0.obs;
  final RxDouble aggregatedCashCollected = 0.0.obs;
  final RxDouble aggregatedPetrolExpense = 0.0.obs;
  final RxInt nonLeaveDaysCount = 0.obs;
  final RxInt totalDaysCount = 0.obs;

  DateTime selectedDate = _dateOnly(DateTime.now());
  DateTime weekStart = _startOfWeek(_dateOnly(DateTime.now()));
  DateTime weekEnd = _endOfWeek(_startOfWeek(_dateOnly(DateTime.now())));

  Future<void> loadDrivers({String? preferredDriverId}) async {
    isLoading.value = true;
    try {
      drivers.value = await _repo.getAllDrivers();
      if (drivers.isEmpty) return;

      DriverProfileEntity? matched;
      if (preferredDriverId != null && preferredDriverId.isNotEmpty) {
        for (final d in drivers) {
          if (d.userId == preferredDriverId) {
            matched = d;
            break;
          }
        }
      }

      matched ??= drivers.first;
      await selectDriver(matched);
    } catch (e) {
      ErrorHandler.showError(e, title: 'Could not load drivers');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> selectDriver(DriverProfileEntity? driver) async {
    selectedDriver.value = driver;
    if (driver == null) {
      currentStatus.value = null;
      _clearAggregates();
      return;
    }
    await _loadDefaultRangeForCurrentFilter(driver.userId);
    await refreshCurrentRange();
  }

  Future<void> onFilterChanged(WorkStatusFilter filter) async {
    selectedFilter.value = filter;
    final driverId = selectedDriver.value?.userId;
    if (driverId == null) return;
    await _loadDefaultRangeForCurrentFilter(driverId);
    await refreshCurrentRange();
  }

  Future<void> pickDailyDate(DateTime date) async {
    selectedDate = _dateOnly(date);
    await refreshCurrentRange();
  }

  Future<void> pickWeeklyStart(DateTime date) async {
    weekStart = _startOfWeek(_dateOnly(date));
    weekEnd = _endOfWeek(weekStart);
    await refreshCurrentRange();
  }

  Future<void> refreshCurrentRange() async {
    final driver = selectedDriver.value;
    if (driver == null) return;

    isLoading.value = true;
    try {
      final rangeStart = selectedFilter.value == WorkStatusFilter.daily
          ? selectedDate
          : weekStart;
      final rangeEnd = selectedFilter.value == WorkStatusFilter.daily
          ? selectedDate
          : weekEnd;

      currentStatus.value = await _repo.getWeeklyStatus(driver.userId, rangeStart);
      await _loadAggregates(driver.userId, rangeStart, rangeEnd);
    } catch (e) {
      ErrorHandler.showError(e, title: 'Could not load status');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadDefaultRangeForCurrentFilter(String driverId) async {
    if (selectedFilter.value == WorkStatusFilter.daily) {
      selectedDate = _dateOnly(DateTime.now());
      return;
    }

    final allEntries = await _repo.getDailyEntriesByDriver(driverId);
    final latestDate = allEntries.isEmpty
        ? _dateOnly(DateTime.now())
        : _dateOnly(allEntries.first.date);
    weekStart = _startOfWeek(latestDate);
    weekEnd = _endOfWeek(weekStart);
  }

  Future<void> _loadAggregates(
    String driverId,
    DateTime rangeStart,
    DateTime rangeEnd,
  ) async {
    final start = _dateOnly(rangeStart);
    final endExclusive = _dateOnly(rangeEnd).add(const Duration(days: 1));

    final entries = await _repo.getDailyEntriesByDriver(
      driverId,
      start: start,
      end: endExclusive,
    );

    final filtered = entries
        .where((e) => !_dateOnly(e.date).isBefore(start))
        .where((e) => !_dateOnly(e.date).isAfter(_dateOnly(rangeEnd)))
        .toList();

    final nonLeaveEntries = filtered.where((e) => !e.leaveOnToday).toList();

    double earnings = 0;
    double cash = 0;
    double petrol = 0;

    for (final entry in nonLeaveEntries) {
      earnings += entry.totalEarning ?? 0;
      cash += entry.cashCollected ?? 0;
      petrol += entry.fuelAmount ?? 0;
    }

    aggregatedEarnings.value = earnings;
    aggregatedCashCollected.value = cash;
    aggregatedPetrolExpense.value = petrol;
    nonLeaveDaysCount.value = nonLeaveEntries.length;
    totalDaysCount.value = _inclusiveDays(rangeStart, rangeEnd);
  }

  void _clearAggregates() {
    aggregatedEarnings.value = 0;
    aggregatedCashCollected.value = 0;
    aggregatedPetrolExpense.value = 0;
    nonLeaveDaysCount.value = 0;
    totalDaysCount.value = 0;
  }

  Future<void> saveWeeklyStatus({
    required String driverId,
    required String driverName,
    required DateTime weekStartDate,
    required DateTime weekEndDate,
    required double totalEarnings,
    required double totalCashCollected,
    required double phonePayReceived,
    required double roomRent,
    required double petrolExpense,
    required double pendingBalance,
  }) async {
    if (isSaving.value) return;
    saveError.value = '';
    saveSuccess.value = false;
    isSaving.value = true;

    try {
      final cashAgainst = totalEarnings - totalCashCollected;
      final entity = WeeklyStatusEntity(
        id: currentStatus.value?.id ?? '',
        driverId: driverId,
        driverName: driverName,
        weekStartDate: weekStartDate,
        weekEndDate: weekEndDate,
        totalEarnings: totalEarnings,
        totalCashCollected: totalCashCollected,
        cashAgainstEarnings: cashAgainst,
        commissionFleet: 0,
        phonePayReceived: phonePayReceived,
        roomRent: roomRent,
        petrolExpense: petrolExpense,
        pendingBalance: pendingBalance,
        finalBalance: 0,
      );
      await _repo.saveWeeklyStatus(entity);
      currentStatus.value = await _repo.getWeeklyStatus(driverId, weekStartDate);
      saveSuccess.value = true;
      ErrorHandler.showSuccess('Weekly status saved');
    } catch (e) {
      saveError.value = ErrorHandler.message(e);
      ErrorHandler.showError(e, title: 'Could not save weekly status');
    } finally {
      isSaving.value = false;
    }
  }

  double calculatedRoomRent(double roomRentPerDay) =>
      roomRentPerDay * totalDaysCount.value;

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static DateTime _startOfWeek(DateTime date) {
    final d = _dateOnly(date);
    return d.subtract(Duration(days: d.weekday - DateTime.monday));
  }

  static DateTime _endOfWeek(DateTime start) => _dateOnly(start).add(
        const Duration(days: 6),
      );

  static int _inclusiveDays(DateTime start, DateTime end) {
    final s = _dateOnly(start);
    final e = _dateOnly(end);
    return e.difference(s).inDays + 1;
  }
}
