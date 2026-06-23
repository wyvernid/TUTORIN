import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

class ReminderService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta')); // sesuaikan kalau target di luar WIB

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    await _plugin.initialize(
      settings: const InitializationSettings(android: androidInit, iOS: iosInit),
    );

    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static int _idDari(String bookingId) => bookingId.hashCode & 0x7fffffff;

  /// Jadwalkan reminder 30 menit sebelum [waktuMulaiKelas].
  static Future<void> jadwalkanReminderKelas({
    required String bookingId,
    required String judulKelas,
    required DateTime waktuMulaiKelas,
  }) async {
    final waktuReminder = waktuMulaiKelas.subtract(const Duration(minutes: 30));
    if (waktuReminder.isBefore(DateTime.now())) return;

    final jam = waktuMulaiKelas.hour.toString().padLeft(2, '0');
    final menit = waktuMulaiKelas.minute.toString().padLeft(2, '0');

    await _plugin.zonedSchedule(
      id: _idDari(bookingId),
      title: 'Kelas akan dimulai 30 menit lagi',
      body: '$judulKelas akan mulai pukul $jam:$menit',
      scheduledDate: tz.TZDateTime.from(waktuReminder, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminder_kelas',
          'Reminder Kelas',
          channelDescription: 'Pengingat kelas yang akan segera dimulai',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static Future<void> batalkanReminder(String bookingId) => _plugin.cancel(id: _idDari(bookingId));

  static DateTime? parseJadwalBooking(String jadwalDipilih, String jamDipilih) {
    const bulan = {
      'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'Mei': 5, 'Jun': 6,
      'Jul': 7, 'Agu': 8, 'Sep': 9, 'Okt': 10, 'Nov': 11, 'Des': 12,
    };
    try {
      final tgl = jadwalDipilih.trim().split(' '); // ['15', 'Jan', '2025']
      final jam = jamDipilih.trim().split(':');    // ['14', '00']
      return DateTime(
        int.parse(tgl[2]),
        bulan[tgl[1]]!,
        int.parse(tgl[0]),
        int.parse(jam[0]),
        int.parse(jam[1]),
      );
    } catch (_) {
      return null; 
    }
  }
}