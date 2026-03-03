import 'package:get/get.dart';
import '../../presentation/bindings/auth_binding.dart';
import '../../presentation/bindings/driver_binding.dart';
import '../../presentation/bindings/admin_binding.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/auth/role_selection_screen.dart';
import '../../presentation/screens/auth/splash_screen.dart';
import '../../presentation/screens/driver/driver_home_screen.dart';
import '../../presentation/screens/driver/driver_profile_screen.dart';
import '../../presentation/screens/driver/daily_entry_screen.dart';
import '../../presentation/screens/driver/weekly_summary_screen.dart';
import '../../presentation/screens/driver/driver_contacts_screen.dart';
import '../../presentation/screens/driver/driver_helpline_screen.dart';
import '../../presentation/screens/admin/admin_home_screen.dart';
import '../../presentation/screens/admin/driver_list_screen.dart';
import '../../presentation/screens/admin/driver_detail_screen.dart';
import '../../presentation/screens/admin/daily_entries_screen.dart';
import '../../presentation/screens/admin/daily_entry_detail_screen.dart';
import '../../presentation/screens/admin/weekly_status_screen.dart';
import '../../presentation/screens/admin/weekly_summary_report_screen.dart';
import '../../presentation/screens/admin/vehicle_management_screen.dart';
import '../../presentation/screens/admin/helpline_numbers_screen.dart';

/// Route names and page list.
/// Paste in: lib/core/routes/app_pages.dart
abstract class AppRoutes {
  static const splash = '/splash';
  static const roleSelection = '/';
  static const login = '/login';
  static const register = '/register';
  static const driverHome = '/driver/home';
  static const driverProfile = '/driver/profile';
  static const dailyEntry = '/driver/daily-entry';
  static const driverWeeklySummary = '/driver/weekly-summary';
  static const driverContacts = '/driver/contacts';
  static const driverHelplines = '/driver/helplines';
  static const adminHome = '/admin/home';
  static const adminDriverList = '/admin/drivers';
  static const adminDriverDetail = '/admin/driver-detail';
  static const adminDailyEntries = '/admin/daily-entries';
  static const adminDailyEntryDetail = '/admin/daily-entry-detail';
  static const adminWeeklyStatus = '/admin/weekly-status';
  static const adminWeeklySummaryReport = '/admin/weekly-summary-report';
  static const adminVehicles = '/admin/vehicles';
  static const adminHelplineNumbers = '/admin/helpline-numbers';
}

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.roleSelection,
      page: () => const RoleSelectionScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => LoginScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.driverHome,
      page: () => const DriverHomeScreen(),
      binding: DriverBinding(),
    ),
    GetPage(
      name: AppRoutes.driverProfile,
      page: () => const DriverProfileScreen(),
      binding: DriverBinding(),
    ),
    GetPage(
      name: AppRoutes.dailyEntry,
      page: () => const DailyEntryScreen(),
      binding: DriverBinding(),
    ),
    GetPage(
      name: AppRoutes.driverWeeklySummary,
      page: () => const DriverWeeklySummaryScreen(),
      binding: DriverBinding(),
    ),
    GetPage(
      name: AppRoutes.driverContacts,
      page: () => const DriverContactsScreen(),
      binding: DriverBinding(),
    ),
    GetPage(
      name: AppRoutes.driverHelplines,
      page: () => const DriverHelplineScreen(),
      binding: DriverBinding(),
    ),
    GetPage(
      name: AppRoutes.adminHome,
      page: () => const AdminHomeScreen(),
      binding: AdminBinding(),
    ),
    GetPage(
      name: AppRoutes.adminDriverList,
      page: () => const DriverListScreen(),
      binding: AdminBinding(),
    ),
    GetPage(
      name: AppRoutes.adminDriverDetail,
      page: () => const DriverDetailScreen(),
      binding: AdminBinding(),
    ),
    GetPage(
      name: AppRoutes.adminDailyEntries,
      page: () => const DailyEntriesScreen(),
      binding: AdminBinding(),
    ),
    GetPage(
      name: AppRoutes.adminDailyEntryDetail,
      page: () => const DailyEntryDetailScreen(),
      binding: AdminBinding(),
    ),
    GetPage(
      name: AppRoutes.adminWeeklyStatus,
      page: () => const WeeklyStatusScreen(),
      binding: AdminBinding(),
    ),
    GetPage(
      name: AppRoutes.adminWeeklySummaryReport,
      page: () => const WeeklySummaryReportScreen(),
      binding: AdminBinding(),
    ),
    GetPage(
      name: AppRoutes.adminVehicles,
      page: () => const VehicleManagementScreen(),
      binding: AdminBinding(),
    ),
    GetPage(
      name: AppRoutes.adminHelplineNumbers,
      page: () => const HelplineNumbersScreen(),
      binding: AdminBinding(),
    ),
  ];
}
