// notification_service.dart
// Service untuk mengelola notifikasi lokal dan Firebase Cloud Messaging (FCM).
// Notifikasi: tugas baru, deadline mendekat (H-1).

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import '../core/constants/app_strings.dart';
import '../features/student/models/assignment_model.dart';

class NotificationService {
  // Instansi plugin notifikasi lokal
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // ========================
  // INISIALISASI
  // ========================

  /// Inisialisasi notifikasi lokal dan FCM.
  /// Dipanggil sekali di main.dart saat aplikasi pertama dibuka.
  Future<void> initialize() async {
    // Konfigurasi untuk Android
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // Konfigurasi untuk iOS
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Inisialisasi plugin
    await _localNotifications.initialize(
      initSettings,
      // Handle saat notifikasi ditekan (app berjalan)
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Minta izin notifikasi dari user
    await _requestPermissions();

    // Setup FCM untuk push notification dari server
    await _setupFCM();

    // Inisialisasi Timezone untuk notifikasi terjadwal
    await _configureLocalTimeZone();
  }

  /// Konfigurasi zona waktu lokal untuk penjadwalan notifikasi.
  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  /// Minta izin notifikasi (wajib di iOS, opsional di Android 13+).
  Future<void> _requestPermissions() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  // ========================
  // SETUP FIREBASE MESSAGING
  // ========================

  /// Setup handler untuk pesan FCM dari server.
  Future<void> _setupFCM() async {
    // Handle pesan saat app di foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        // Tampilkan notifikasi lokal saat app sedang dibuka
        showLocalNotification(
          title: message.notification!.title ?? '',
          body: message.notification!.body ?? '',
          payload: message.data['route'], // Route untuk navigasi
        );
      }
    });
  }

  // ========================
  // TAMPILKAN NOTIFIKASI LOKAL
  // ========================

  /// Tampilkan notifikasi lokal dengan judul dan pesan.
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload, // Data tambahan untuk navigasi
    int id = 0,
  }) async {
    // Detail notifikasi untuk Android
    const androidDetails = AndroidNotificationDetails(
      'trimbo_channel',    // Channel ID
      'Trimbo',            // Channel name
      channelDescription: 'Notifikasi dari Trimbo',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    // Detail notifikasi untuk iOS
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Tampilkan notifikasi
    await _localNotifications.show(id, title, body, details, payload: payload);
  }

  // ========================
  // NOTIFIKASI SPESIFIK
  // ========================

  /// Notifikasi saat ada tugas baru diterbitkan guru.
  Future<void> showNewAssignmentNotification(String assignmentTitle) async {
    await showLocalNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: AppStrings.notifNewAssignment,
      body: '"$assignmentTitle" ${AppStrings.notifNewAssignmentBody}',
      payload: '/student/assignments',
    );
  }

  /// Notifikasi saat deadline tugas tinggal 1 hari lagi.
  Future<void> showDeadlineReminderNotification(String assignmentTitle) async {
    await showLocalNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: AppStrings.notifDeadlineTomorrow,
      body: '${AppStrings.notifDeadlineBody} "$assignmentTitle"',
      payload: '/student/assignments',
    );
  }

  /// Jadwalkan notifikasi peringatan 1 jam sebelum deadline.
  Future<void> scheduleDeadlineReminder(AssignmentModel assignment) async {
    final deadline = assignment.deadline;
    final scheduledDate = deadline.subtract(const Duration(hours: 1));

    // Jangan jadwalkan jika waktu sudah lewat
    if (scheduledDate.isBefore(DateTime.now())) return;

    // Gunakan hash dari assignment ID sebagai ID notifikasi agar unik tapi konsisten
    final int notificationId = assignment.id.hashCode.abs();

    const androidDetails = AndroidNotificationDetails(
      'deadline_reminders',
      'Pengingat Deadline',
      channelDescription: 'Pengingat 1 jam sebelum deadline tugas',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.zonedSchedule(
      notificationId,
      '⏳ Deadline Mendekat!',
      'Tugas "${assignment.title}" harus dikumpulkan dalam 1 jam lagi!',
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: '/student/assignments',
    );
  }

  /// Batalkan notifikasi terjadwal (misal jika sudah mengerjakan).
  Future<void> cancelNotification(String assignmentId) async {
    final int notificationId = assignmentId.hashCode.abs();
    await _localNotifications.cancel(notificationId);
  }

  // ========================
  // HANDLE TAP NOTIFIKASI
  // ========================

  /// Dipanggil saat user menekan notifikasi.
  void _onNotificationTapped(NotificationResponse response) {
    // Navigasi ke halaman sesuai payload
    // Implementasi navigasi menggunakan GetX
    if (response.payload != null) {
      // Get.toNamed(response.payload!); // Uncomment setelah setup GetX
    }
  }

  /// Ambil FCM token untuk dikirim ke server (untuk push notification).
  Future<String?> getFCMToken() async {
    return await _messaging.getToken();
  }
}
