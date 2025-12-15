import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:typed_data';
import 'dart:io';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('🔔 Background message received: ${message.messageId}');
  print('   Title: ${message.notification?.title}');
  print('   Body: ${message.notification?.body}');
}

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  String? _fcmToken;
  bool _isInitialized = false;

  // ========== INITIALIZATION ==========

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      print('🔔 Initializing notification service...');

      // 1. Initialize timezone
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

      // 2. Request permissions
      await _requestPermissions();

      // 3. Initialize local notifications
      await _initializeLocalNotifications();

      // 4. Initialize Firebase Messaging
      await _initializeFirebaseMessaging();

      _isInitialized = true;
      print('✅ Notification service initialized successfully');
    } catch (e) {
      print('❌ Error initializing notifications: $e');
      rethrow;
    }
  }

  // ========== PERMISSIONS ==========

  Future<void> _requestPermissions() async {
    print('📱 Requesting notification permissions...');

    if (Platform.isAndroid) {
      if (await Permission.notification.isDenied) {
        final status = await Permission.notification.request();
        print('   Android notification permission: $status');
      }

      // Android 13+ exact alarm permission
      if (await Permission.scheduleExactAlarm.isDenied) {
        final status = await Permission.scheduleExactAlarm.request();
        print('   Exact alarm permission: $status');
      }
    } else if (Platform.isIOS) {
      final settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
      );
      print('   iOS notification permission: ${settings.authorizationStatus}');
    }
  }

  // ========== LOCAL NOTIFICATIONS SETUP ==========

  Future<void> _initializeLocalNotifications() async {
    print('🔔 Setting up local notifications...');

    // Android settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channels for Android
    await _createNotificationChannels();

    print('✅ Local notifications initialized');
  }

  Future<void> _createNotificationChannels() async {
    if (!Platform.isAndroid) return;

    print('📱 Creating Android notification channels...');

    // HIGH IMPORTANCE CHANNEL (with custom sound)
    final highImportanceChannel = AndroidNotificationChannel(
      'conatus_high_importance',
      'High Importance Notifications',
      description: 'For important notifications like quiz completion',
      importance: Importance.high,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('quiz_complete'),
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
    );

    // REMINDER CHANNEL (with custom sound)
    final reminderChannel = AndroidNotificationChannel(
      'conatus_reminders',
      'Study Reminders',
      description: 'Daily study reminder notifications',
      importance: Importance.high,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('study_reminder'),
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 300, 100, 300, 100, 300]),
    );


    await _localNotifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(highImportanceChannel);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(reminderChannel);

    print('✅ Notification channels created');
  }

  // ========== FIREBASE MESSAGING SETUP ==========

  Future<void> _initializeFirebaseMessaging() async {
    print('🔥 Setting up Firebase Messaging...');

    // Set background message handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Get FCM token
    _fcmToken = await _fcm.getToken();
    print('📱 FCM Token: $_fcmToken');

    // Listen to token refresh
    _fcm.onTokenRefresh.listen((newToken) {
      _fcmToken = newToken;
      print('🔄 FCM Token refreshed: $newToken');
      // TODO: Send to your backend server
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Check if app was opened from terminated state
    RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

    print('✅ Firebase Messaging initialized');
  }

  void _handleForegroundMessage(RemoteMessage message) {
    print('🔔 Foreground message received');
    print('   Title: ${message.notification?.title}');
    print('   Body: ${message.notification?.body}');
    print('   Data: ${message.data}');

    // Show local notification when app is in foreground
    _showLocalNotification(
      title: message.notification?.title ?? 'Conatus Academy',
      body: message.notification?.body ?? '',
      payload: message.data.toString(),
    );
  }

  void _handleNotificationTap(RemoteMessage message) {
    print('👆 Notification tapped: ${message.messageId}');
    print('   Data: ${message.data}');

    // Navigate based on notification data
    // TODO: Add navigation logic here
  }

  void _onNotificationTapped(NotificationResponse response) {
    print('👆 Local notification tapped: ${response.payload}');
    // TODO: Add navigation logic here
  }

  // ========== SHOW LOCAL NOTIFICATIONS ==========

  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
    String channelId = 'conatus_high_importance',
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'conatus_high_importance',
      'High Importance Notifications',
      channelDescription: 'Important notifications',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('quiz_complete'),
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFF087E8B),
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'quiz_complete.aiff',
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch,
      title,
      body,
      details,
      payload: payload,
    );
  }


  // ========== QUIZ COMPLETION NOTIFICATION ==========

  Future<void> showQuizCompletionNotification({
    required int score,
    required int total,
    required String courseName,
  }) async {
    final percentage = ((score / total) * 100).toInt();
    final emoji = percentage >= 80
        ? '🎉'
        : percentage >= 60
        ? '👏'
        : '💪';

    await _showLocalNotification(
      title: '$emoji Quiz Selesai!',
      body: 'Skor Anda: $score/$total ($percentage%) - $courseName',
      payload: 'quiz_completed',
      channelId: 'conatus_high_importance',
    );

    print('✅ Quiz completion notification sent');
  }

  // ========== DAILY STUDY REMINDER ==========

  Future<void> scheduleDailyReminder({
    required TimeOfDay time,
  }) async {
    print('⏰ Scheduling daily reminder at ${time.hour}:${time.minute}');

    // Cancel existing reminders first
    await _localNotifications.cancel(999);

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // If time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final androidDetails = AndroidNotificationDetails(
      'conatus_reminders',
      'Study Reminders',
      channelDescription: 'Daily study reminders',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('study_reminder'),
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 300, 100, 300, 100, 300]),
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFF087E8B),
      styleInformation: const BigTextStyleInformation(
        'Sudah waktunya belajar! Jangan lupa selesaikan quiz hari ini. Konsistensi adalah kunci sukses! 📚',
      ),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'study_reminder.aiff',
    );

    await _localNotifications.zonedSchedule(
      999, // Notification ID for daily reminder
      '📚 Waktunya Belajar!',
      'Jangan lupa selesaikan quiz hari ini. Ayo tingkatkan skill English-mu!',
      scheduledDate,
       NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
    );

    // Save to preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('reminder_hour', time.hour);
    await prefs.setInt('reminder_minute', time.minute);
    await prefs.setBool('reminder_enabled', true);

    print('✅ Daily reminder scheduled successfully');
  }

  Future<void> cancelDailyReminder() async {
    await _localNotifications.cancel(999);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reminder_enabled', false);

    print('🔕 Daily reminder cancelled');
  }

  Future<TimeOfDay?> getSavedReminderTime() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('reminder_enabled') ?? false;

    if (!enabled) return null;

    final hour = prefs.getInt('reminder_hour') ?? 20;
    final minute = prefs.getInt('reminder_minute') ?? 0;

    return TimeOfDay(hour: hour, minute: minute);
  }

  // ========== GETTERS ==========

  String? get fcmToken => _fcmToken;
  bool get isInitialized => _isInitialized;
}