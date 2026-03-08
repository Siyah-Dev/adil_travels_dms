import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_pages.dart';
import 'core/constants/app_constants.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'presentation/controllers/auth_controller.dart';
import 'core/services/notification_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage m) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }
}

Future<void> _initializeFirebase() async {
  if (!kIsWeb) {
    await Firebase.initializeApp();
    return;
  }

  const apiKey = String.fromEnvironment('FIREBASE_WEB_API_KEY');
  const appId = String.fromEnvironment('FIREBASE_WEB_APP_ID');
  const messagingSenderId = String.fromEnvironment('FIREBASE_WEB_MESSAGING_SENDER_ID');
  const projectId = String.fromEnvironment('FIREBASE_WEB_PROJECT_ID');
  const authDomain = String.fromEnvironment('FIREBASE_WEB_AUTH_DOMAIN');
  const storageBucket = String.fromEnvironment('FIREBASE_WEB_STORAGE_BUCKET');

  if (apiKey.isEmpty ||
      appId.isEmpty ||
      messagingSenderId.isEmpty ||
      projectId.isEmpty ||
      authDomain.isEmpty ||
      storageBucket.isEmpty) {
    throw Exception(
      'Firebase Web config missing. Pass FIREBASE_WEB_API_KEY, FIREBASE_WEB_APP_ID, '
      'FIREBASE_WEB_MESSAGING_SENDER_ID, FIREBASE_WEB_PROJECT_ID, FIREBASE_WEB_AUTH_DOMAIN, '
      'and FIREBASE_WEB_STORAGE_BUCKET via --dart-define.',
    );
  }

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: apiKey,
      appId: appId,
      messagingSenderId: messagingSenderId,
      projectId: projectId,
      authDomain: authDomain,
      storageBucket: storageBucket,
    ),
  );
}

/// Paste in: lib/main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeFirebase();
  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    throw Exception(
      'Supabase config missing. Pass --dart-define=SUPABASE_URL and --dart-define=SUPABASE_ANON_KEY.',
    );
  }

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
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
      initialRoute: AppRoutes.splash,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}
