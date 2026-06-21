import 'package:cloud_firestore/cloud_firestore.dart';

/// Model 1 dokumen di collection Firestore `notifikasi`.
/// Setiap notifikasi SELALU milik 1 user (field `uid`), termasuk notifikasi
/// admin — kalau perlu broadcast ke semua admin, dibuat 1 dokumen per admin
/// (lihat NotifikasiService.kirimKeSemuaAdmin) supaya status `isRead` tetap
/// independen per orang.
class NotifikasiModel {
  final String id;
  final String uid;       // UID penerima notifikasi
  final String role;      // 'student' | 'tutor' | 'admin'
  final String tipe;      // lihat NotifikasiTipe
  final String judul;
  final String pesan;
  final String? refId;    // id booking/kelas/chat/laporan terkait (buat navigasi)
  final String? refType;  // 'booking' | 'kelas' | 'chat' | 'laporan' | 'tutor'
  final bool isRead;
  final DateTime createdAt;

  NotifikasiModel({
    required this.id,
    required this.uid,
    required this.role,
    required this.tipe,
    required this.judul,
    required this.pesan,
    this.refId,
    this.refType,
    this.isRead = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'role': role,
        'tipe': tipe,
        'judul': judul,
        'pesan': pesan,
        'refId': refId,
        'refType': refType,
        'isRead': isRead,
        'createdAt': FieldValue.serverTimestamp(),
      };

  factory NotifikasiModel.fromMap(Map<String, dynamic> m, String id) => NotifikasiModel(
        id: id,
        uid: m['uid'] ?? '',
        role: m['role'] ?? '',
        tipe: m['tipe'] ?? '',
        judul: m['judul'] ?? '',
        pesan: m['pesan'] ?? '',
        refId: m['refId'],
        refType: m['refType'],
        isRead: m['isRead'] ?? false,
        createdAt: (m['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
}

/// Konstanta tipe notifikasi — dipakai konsisten di service & UI (icon/warna).
class NotifikasiTipe {
  static const bookingBaru = 'booking_baru';               // murid booking kelas → ke tutor
  static const bookingDikonfirmasi = 'booking_dikonfirmasi'; // tutor verifikasi bayar → ke murid
  static const bookingDitolak = 'booking_ditolak';          // tutor tolak bayar → ke murid
  static const reminderKelas = 'reminder_kelas';            // 30 menit sebelum kelas → ke murid (local notif)
  static const chatBaru = 'chat_baru';                      // pesan masuk → ke penerima
  static const tutorDisetujui = 'tutor_disetujui';          // admin approve → ke tutor
  static const tutorDitolak = 'tutor_ditolak';              // admin tolak → ke tutor
  static const laporanBaru = 'laporan_baru';                // ada laporan baru → ke semua admin
  static const laporanSelesai = 'laporan_selesai';          // laporan diproses → ke pelapor
  static const ulasanBaru = 'ulasan_baru';                  // murid kasih review → ke tutor
  static const tutorMendaftar = 'tutor_mendaftar';           // tutor baru register → ke semua admin
}