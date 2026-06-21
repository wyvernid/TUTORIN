import 'package:cloud_firestore/cloud_firestore.dart';
import 'notifikasi_service.dart';
import '../models/notifikasi_model.dart';

class AdminService {
  final _db = FirebaseFirestore.instance;
  final _notif = NotifikasiService();

  // Tutor pending = belum verified DAN belum ditolak (kalau sudah ditolak,
  // dia harus "Daftar Ulang" dulu lewat TutorPendingScreen sebelum balik
  // muncul di tab ini lagi).
  Stream<List<Map<String,dynamic>>> streamTutorPending() => _db.collection('users')
      .where('role', isEqualTo: 'tutor').where('isVerified', isEqualTo: false)
      .snapshots().map((s) => s.docs
          .map((d) => {...d.data(), 'uid': d.id})
          .where((u) => u['isRejected'] != true)
          .toList());

  Stream<List<Map<String,dynamic>>> streamTutorVerified() => _db.collection('users')
      .where('role', isEqualTo: 'tutor').where('isVerified', isEqualTo: true)
      .snapshots().map((s) => s.docs.map((d) => {...d.data(), 'uid': d.id}).toList());

  Stream<List<Map<String,dynamic>>> streamStudent() => _db.collection('users')
      .where('role', isEqualTo: 'student')
      .snapshots().map((s) => s.docs.map((d) => {...d.data(), 'uid': d.id}).toList());

  Future<void> verifikasiTutor(String uid) async {
    await _db.collection('users').doc(uid)
        .update({'isVerified': true, 'isRejected': false, 'alasanTolak': null});

    // ── BARU: kabari tutor akunnya sudah diverifikasi ──
    try {
      await _notif.kirim(
        uid: uid,
        role: 'tutor',
        tipe: NotifikasiTipe.tutorDisetujui,
        judul: 'Akun tutor disetujui',
        pesan: 'Selamat! Akunmu sudah diverifikasi admin. Kamu sekarang bisa membuka kelas.',
        refId: uid,
        refType: 'tutor',
      );
    } catch (e) {
      print('Gagal kirim notifikasi tutor disetujui: $e');
    }
  }


  Future<void> tolakTutor(String uid, {String? alasan}) async {
    await _db.collection('users').doc(uid)
        .update({'isVerified': false, 'isRejected': true, 'alasanTolak': alasan});

    // ── BARU: kabari tutor pendaftarannya ditolak ──
    try {
      await _notif.kirim(
        uid: uid,
        role: 'tutor',
        tipe: NotifikasiTipe.tutorDitolak,
        judul: 'Pendaftaran tutor ditolak',
        pesan: alasan != null && alasan.isNotEmpty
            ? 'Pendaftaranmu ditolak admin. Alasan: $alasan'
            : 'Pendaftaranmu ditolak admin.',
        refId: uid,
        refType: 'tutor',
      );
    } catch (e) {
      print('Gagal kirim notifikasi tutor ditolak: $e');
    }
  }

  Future<void> suspendUser(String uid) => _db.collection('users').doc(uid).update({'isSuspended': true});
  Future<void> aktifkanUser(String uid) => _db.collection('users').doc(uid).update({'isSuspended': false});

  // ── BARU: dipanggil saat pull-to-refresh di Dashboard Admin ──
  // Memaksa Firestore mengambil data TERBARU dari server (bypass cache lokal
  // yang bisa jadi basi kalau device sempat offline / data berubah saat app
  // belum sempat sinkron). Stream .snapshots() yang sedang berjalan akan
  // otomatis menerima dorongan data baru ini, tanpa perlu setState manual.
  Future<void> refreshDariServer() async {
    try {
      await Future.wait([
        _db.collection('users')
            .where('role', isEqualTo: 'student')
            .get(const GetOptions(source: Source.server)),
        _db.collection('users')
            .where('role', isEqualTo: 'tutor')
            .get(const GetOptions(source: Source.server)),
      ]);
    } catch (e) {
      // Kalau device benar-benar offline, biarkan saja -- stream tetap
      // jalan dengan data cache terakhir, tidak perlu melempar error ke UI.
      print('refreshDariServer (AdminService) gagal: $e');
    }
  }
}