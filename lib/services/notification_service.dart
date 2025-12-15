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
}

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  String? _fcmToken;
  bool _isInitialized = false;

  // Definisi Pola Getaran
  static final Int64List _vibHigh = Int64List.fromList([0, 500, 200, 500]);
  static final Int64List _vibReminder =
      Int64List.fromList([0, 300, 100, 300, 100, 300]);

  // ========== INITIALIZATION ==========

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      print('🔔 Initializing notification service...');

      // 1. Initialize timezone
      tz.initializeTimeZones();
      try {
        tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
      } catch (e) {
        tz.setLocalLocation(tz.UTC); // Fallback
      }

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
    if (Platform.isAndroid) {
      await Permission.notification.request();
      await Permission.scheduleExactAlarm.request();
    } else if (Platform.isIOS) {
      await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  // ========== LOCAL NOTIFICATIONS SETUP ==========

  Future<void> _initializeLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

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

    await _createNotificationChannels();
  }

  Future<void> _createNotificationChannels() async {
    if (!Platform.isAndroid) return;

    print('📱 Creating Android notification channels...');

    // Channel 1: High Importance (Quiz Selesai)
    final highImportanceChannel = AndroidNotificationChannel(
      'conatus_high_importance',
      'High Importance Notifications',
      description: 'For important notifications like quiz completion',
      importance: Importance.high,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('quiz_complete'),
      enableVibration: true,
      vibrationPattern: _vibHigh,
    );

    // Channel 2: Reminder (Jadwal Belajar)
    final reminderChannel = AndroidNotificationChannel(
      'conatus_reminders',
      'Study Reminders',
      description: 'Daily study reminder notifications',
      importance: Importance.high,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('study_reminder'),
      enableVibration: true,
      vibrationPattern: _vibReminder,
    );

    final plugin = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await plugin?.createNotificationChannel(highImportanceChannel);
    await plugin?.createNotificationChannel(reminderChannel);
  }

  // ========== FIREBASE MESSAGING SETUP ==========

  Future<void> _initializeFirebaseMessaging() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    _fcmToken = await _fcm.getToken();
    print('📱 FCM Token: $_fcmToken');

    _fcm.onTokenRefresh.listen((newToken) {
      _fcmToken = newToken;
    });

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    _showLocalNotification(
      title: message.notification?.title ?? 'Conatus Academy',
      body: message.notification?.body ?? '',
      payload: message.data.toString(),
      // Default ke high importance jika dari FCM
      channelId: 'conatus_high_importance',
    );
  }

  void _handleNotificationTap(RemoteMessage message) {
    print('👆 Notification tapped: ${message.data}');
  }

  void _onNotificationTapped(NotificationResponse response) {
    print('👆 Local notification tapped: ${response.payload}');
  }

  // ========== SHOW LOCAL NOTIFICATIONS (LOGIC FIX DISINI) ==========

  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
    String channelId = 'conatus_high_importance',
  }) async {
    // Logic untuk menentukan properti berdasarkan channelId
    final isReminder = channelId == 'conatus_reminders';

    // Tentukan nama channel, sound, dan vibration sesuai ID
    final channelName =
        isReminder ? 'Study Reminders' : 'High Importance Notifications';
    final soundName = isReminder ? 'study_reminder' : 'quiz_complete';
    final vibration = isReminder ? _vibReminder : _vibHigh;

    final androidDetails = AndroidNotificationDetails(
      channelId, // Gunakan variabel channelId
      channelName, // Gunakan nama yang sesuai
      channelDescription: 'Conatus notifications',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      // Pastikan file mp3 ada di android/app/src/main/res/raw/
      sound: RawResourceAndroidNotificationSound(soundName),
      enableVibration: true,
      vibrationPattern: vibration,
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFF087E8B),
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: '$soundName.aiff', // iOS butuh format aiff/caf/wav
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Gunakan ID unik berdasarkan waktu agar notifikasi tidak saling menimpa
    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    await _localNotifications.show(
      id,
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
      channelId: 'conatus_high_importance', // Menggunakan channel Quiz
    );
  }

  // ========== DAILY STUDY REMINDER ==========

  Future<void> scheduleDailyReminder({
    required TimeOfDay time,
  }) async {
    print('⏰ Scheduling daily reminder at ${time.hour}:${time.minute}');

    await _localNotifications.cancel(999); // Cancel ID khusus reminder (999)

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

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
      vibrationPattern: _vibReminder,
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFF087E8B),
      styleInformation: const BigTextStyleInformation(
        'Sudah waktunya belajar! Jangan lupa selesaikan quiz hari ini.',
      ),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'study_reminder.aiff',
    );

    await _localNotifications.zonedSchedule(
      999, // ID Tetap 999 untuk reminder
      '📚 Waktunya Belajar!',
      'Jangan lupa selesaikan quiz hari ini. Ayo tingkatkan skill English-mu!',
      scheduledDate,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

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

  String? get fcmToken => _fcmToken;
  bool get isInitialized => _isInitialized;
}
