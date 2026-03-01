import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_pages.dart';
import 'core/constants/app_constants.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'presentation/controllers/auth_controller.dart';
import 'core/services/notification_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage m) async {
  await Firebase.initializeApp();
}

/// Paste in: lib/main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await NotificationService.init();

  // Auth controller must be available for all screens (driver profile, daily entry need current user).
  Get.put<AuthController>(AuthController(AuthRepositoryImpl()), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.roleSelection,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}
