import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/laporan_model.dart';
import '../models/notifikasi_model.dart';
import 'notifikasi_service.dart';

class LaporanService {
  final _db = FirebaseFirestore.instance;
  final _notif = NotifikasiService();

  Future<String> kirim(LaporanModel l) async {
    final ref = await _db.collection('laporan').add(l.toMap());

    // ── BARU: kabari semua admin ada laporan baru yang perlu ditinjau ──
    try {
      await _notif.kirimKeSemuaAdmin(
        tipe: NotifikasiTipe.laporanBaru,
        judul: 'Laporan baru',
        pesan: '${l.fromNama} melaporkan ${l.againstNama} (${l.kategori})',
        refId: ref.id,
        refType: 'laporan',
      );
    } catch (e) {
      print('Gagal kirim notifikasi laporan baru: $e');
    }

    return ref.id;
  }

  Stream<List<LaporanModel>> streamAktif() => _db.collection('laporan')
      .where('status', isEqualTo: 'open').orderBy('createdAt', descending: true)
      .snapshots().map((s) => s.docs.map((d) => LaporanModel.fromMap(d.data(), d.id)).toList());

  Stream<List<LaporanModel>> streamSelesai() => _db.collection('laporan')
      .where('status', whereIn: ['resolved', 'dismissed']).orderBy('createdAt', descending: true)
      .snapshots().map((s) => s.docs.map((d) => LaporanModel.fromMap(d.data(), d.id)).toList());

  Future<void> selesaikan(String id, String catatan) async {
    await _db.collection('laporan').doc(id).update({'status': 'resolved', 'catatanAdmin': catatan});

    // ── BARU: kabari pelapor laporannya sudah diproses ──
    try {
      final doc = await _db.collection('laporan').doc(id).get();
      final l = doc.data();
      if (l != null) {
        await _notif.kirim(
          uid: l['fromUid'] ?? '',
          role: l['fromRole'] ?? '',
          tipe: NotifikasiTipe.laporanSelesai,
          judul: 'Laporan diselesaikan',
          pesan: 'Laporanmu terhadap ${l['againstNama'] ?? ''} sudah ditindak admin.',
          refId: id,
          refType: 'laporan',
        );
      }
    } catch (e) {
      print('Gagal kirim notifikasi laporan diselesaikan: $e');
    }
  }

  Future<void> abaikan(String id, String catatan) async {
    await _db.collection('laporan').doc(id).update({'status': 'dismissed', 'catatanAdmin': catatan});

    // ── BARU: kabari pelapor laporannya sudah ditinjau (meski diabaikan) ──
    try {
      final doc = await _db.collection('laporan').doc(id).get();
      final l = doc.data();
      if (l != null) {
        await _notif.kirim(
          uid: l['fromUid'] ?? '',
          role: l['fromRole'] ?? '',
          tipe: NotifikasiTipe.laporanSelesai,
          judul: 'Laporan ditinjau',
          pesan: 'Laporanmu terhadap ${l['againstNama'] ?? ''} sudah ditinjau admin.',
          refId: id,
          refType: 'laporan',
        );
      }
    } catch (e) {
      print('Gagal kirim notifikasi laporan diabaikan: $e');
    }
  }
}