import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import '../../data/datasources/firebase_auth_datasource.dart';
import '../../data/datasources/firebase_driver_datasource.dart';
import '../../presentation/controllers/auth_controller.dart';

/// Handles FCM and local reminders. Schedule checks (morning/evening) can be done via Cloud Functions.
/// Paste in: lib/core/services/notification_service.dart
class NotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    await _requestPermission();
    if (!kIsWeb) {
      await _initLocalNotifications();
    }
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_onOpenApp);
    try {
      final token = await _fcm.getToken();
      _saveTokenIfLoggedIn(token);
      _fcm.onTokenRefresh.listen(_saveTokenIfLoggedIn);
    } catch (_) {
      // Web FCM token generation can fail if service worker or browser setup is incomplete.
    }
  }

  static void updateTokenForUser(String uid) async {
    final token = await _fcm.getToken();
    if (token != null) FirebaseAuthDatasource().updateFcmToken(uid, token);
  }

  static Future<void> _requestPermission() async {
    await _fcm.requestPermission(alert: true, badge: true, sound: true);
  }

  static Future<void> _initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _local.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (_) {},
    );
  }

  static void _saveTokenIfLoggedIn(String? token) {
    if (token == null) return;
    try {
      final uid = Get.find<AuthController>().currentUser.value?.uid;
      if (uid != null) FirebaseAuthDatasource().updateFcmToken(uid, token);
    } catch (_) {}
  }

  static void _onForegroundMessage(RemoteMessage m) {
    final title = m.notification?.title ?? 'Reminder';
    final body = m.notification?.body ?? '';
    if (kIsWeb) return;
    _showLocal(title: title, body: body);
  }

  static void _onOpenApp(RemoteMessage m) {}

  static Future<void> _showLocal({required String title, required String body}) async {
    const android = AndroidNotificationDetails(
      'adil_taxi_channel',
      'Adil Taxi',
      channelDescription: 'Driver DMS notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const ios = DarwinNotificationDetails();
    await _local.show(
      0,
      title,
      body,
      const NotificationDetails(android: android, iOS: ios),
    );
  }

  /// Call from Cloud Function or scheduled task: get drivers who haven't filled mandatory fields today.
  static Future<List<String>> getDriversWithMissingEntry(DateTime date) async {
    final entries = await FirebaseDriverDatasource().getEntriesWithMissingMandatoryFields(date);
    return entries.map((e) => e.driverName).where((n) => n.isNotEmpty).toSet().toList();
  }
}
