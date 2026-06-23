import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';


class OneSignalService {
  static String get _appId => dotenv.env['ONESIGNAL_APP_ID'] ?? '';
  static String get _appApiKey => dotenv.env['ONESIGNAL_APP_API_KEY'] ?? '';

  // Base URL API OneSignal yang baru (yang lama, /api/v1/, sudah deprecated).
  static const String _baseUrl = 'https://api.onesignal.com';

  static Future<void> init() async {
    OneSignal.Debug.setLogLevel(OSLogLevel.error);
    OneSignal.initialize(_appId);
    await OneSignal.Notifications.requestPermission(true);
  }

  /// Panggil tiap kali user login / register sukses
  static Future<void> loginUser(String uid) async {
    await OneSignal.login(uid);
  }

  /// Panggil tiap kali user logout
  static Future<void> logoutUser() async {
    await OneSignal.logout();
  }

  /// Kirim push notification ke 1 user (lewat uid yang sudah di-`login()`
  static Future<void> kirimPush({
    required String targetUid,
    required String judul,
    required String pesan,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/notifications'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Key $_appApiKey',
        },
        body: jsonEncode({
          'app_id': _appId,
          'include_aliases': {'external_id': [targetUid]},
          'target_channel': 'push',
          'headings': {'en': judul},
          'contents': {'en': pesan},
        }),
      );

      if (response.statusCode >= 400) {
        // ignore: avoid_print
        print('Gagal kirim push OneSignal (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      print('Gagal kirim push OneSignal: $e');
    }
  }

  /// Kirim push ke SEMUA admin sekaligus 
  static Future<void> kirimPushKeSemuaAdmin({
    required String judul,
    required String pesan,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/notifications'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Key $_appApiKey',
        },
        body: jsonEncode({
          'app_id': _appId,
          'included_segments': ['Subscribed Users'],
          'headings': {'en': judul},
          'contents': {'en': pesan},
        }),
      );

      if (response.statusCode >= 400) {
        print('Gagal kirim push ke semua admin (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      print('Gagal kirim push ke semua admin: $e');
    }
  }
}