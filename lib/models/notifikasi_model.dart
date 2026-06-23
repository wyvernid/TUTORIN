import 'package:cloud_firestore/cloud_firestore.dart';


class NotifikasiModel {
  final String id;
  final String uid;       // UID penerima notifikasi
  final String role;     
  final String tipe;      
  final String judul;
  final String pesan;
  final String? refId;   // ID referensi terkait (misal: bookingId, kelasId, chatId, laporanId, tutorId)
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