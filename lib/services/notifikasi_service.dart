import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notifikasi_model.dart';
import 'onesignal_service.dart';


class NotifikasiService {
  final _db = FirebaseFirestore.instance;

  /// Kirim 1 notifikasi ke 1 user spesifik.
  Future<void> kirim({
    required String uid,
    required String role,
    required String tipe,
    required String judul,
    required String pesan,
    String? refId,
    String? refType,
  }) async {
    await _db.collection('notifikasi').add(
          NotifikasiModel(
            id: '',
            uid: uid,
            role: role,
            tipe: tipe,
            judul: judul,
            pesan: pesan,
            refId: refId,
            refType: refType,
            createdAt: DateTime.now(),
          ).toMap(),
        );

    // Push notification asli — dipanggil "fire and forget" (tidak di-await
    // dengan blocking), supaya kalau OneSignal lambat/gagal, proses utama
    // (booking, approve, dll) tetap selesai duluan tanpa nunggu push.
    OneSignalService.kirimPush(targetUid: uid, judul: judul, pesan: pesan);
  }

  /// Kirim notifikasi yang sama ke SEMUA admin sekaligus (mis. laporan baru).
  /// Dibuat 1 dokumen terpisah per admin supaya status baca tiap admin independen.
  Future<void> kirimKeSemuaAdmin({
    required String tipe,
    required String judul,
    required String pesan,
    String? refId,
    String? refType,
  }) async {
    final admins = await _db.collection('users').where('role', isEqualTo: 'admin').get();
    if (admins.docs.isEmpty) return;
    final batch = _db.batch();
    for (final d in admins.docs) {
      batch.set(
        _db.collection('notifikasi').doc(),
        NotifikasiModel(
          id: '',
          uid: d.id,
          role: 'admin',
          tipe: tipe,
          judul: judul,
          pesan: pesan,
          refId: refId,
          refType: refType,
          createdAt: DateTime.now(),
        ).toMap(),
      );
    }
    await batch.commit();

    OneSignalService.kirimPushKeSemuaAdmin(judul: judul, pesan: pesan);
  }

  /// Stream semua notifikasi milik 1 user, terbaru di atas.
  Stream<List<NotifikasiModel>> streamNotifikasi(String uid) => _db
      .collection('notifikasi')
      .where('uid', isEqualTo: uid)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => NotifikasiModel.fromMap(d.data(), d.id)).toList());

  /// Stream jumlah notifikasi BELUM dibaca → dipakai buat badge angka di lonceng.
  Stream<int> streamJumlahBelumDibaca(String uid) => _db
      .collection('notifikasi')
      .where('uid', isEqualTo: uid)
      .where('isRead', isEqualTo: false)
      .snapshots()
      .map((s) => s.docs.length);

  Future<void> tandaiDibaca(String notifId) =>
      _db.collection('notifikasi').doc(notifId).update({'isRead': true});

  /// Tombol "Tandai semua dibaca" di halaman daftar notifikasi.
  Future<void> tandaiSemuaDibaca(String uid) async {
    final belum = await _db
        .collection('notifikasi')
        .where('uid', isEqualTo: uid)
        .where('isRead', isEqualTo: false)
        .get();
    if (belum.docs.isEmpty) return;
    final batch = _db.batch();
    for (final d in belum.docs) {
      batch.update(d.reference, {'isRead': true});
    }
    await batch.commit();
  }

  Future<void> hapus(String notifId) => _db.collection('notifikasi').doc(notifId).delete();
}