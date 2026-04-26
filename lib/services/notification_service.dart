import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

/// Service untuk mengelola notifikasi lokal
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  /// Inisialisasi notification plugin
  Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(initSettings);

    // Request notification permission for Android 13+
    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// Menampilkan notifikasi instant
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'parking_finder_channel',
      'Parking Finder',
      channelDescription: 'Notifikasi dari Parking Finder',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const details = NotificationDetails(android: androidDetails);
    await _notifications.show(id, title, body, details);
  }

  /// Menjadwalkan notifikasi harian jam 08:00
  Future<void> scheduleDailyNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'parking_finder_daily',
      'Pengingat Harian',
      channelDescription: 'Pengingat harian untuk cek parkiran',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifications.zonedSchedule(
      0,
      'Mau pergi?',
      'Cek parkiran tersedia di sekitarmu!',
      _nextInstanceOfEightAM(),
      details,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Mendapatkan waktu jam 08:00 berikutnya
  tz.TZDateTime _nextInstanceOfEightAM() {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      8,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  /// Menampilkan notifikasi sukses menambah parkiran
  Future<void> showParkingAddedNotification() async {
    await showNotification(
      id: 1,
      title: 'Parkiran berhasil ditambahkan!',
      body: 'Terima kasih kontribusinya!',
    );
  }
}
