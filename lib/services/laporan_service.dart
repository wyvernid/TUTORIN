import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/laporan_model.dart';

class LaporanService {
  final _db = FirebaseFirestore.instance;

  Future<String> kirim(LaporanModel l) async {
    final ref = await _db.collection('laporan').add(l.toMap());
    return ref.id;
  }

  Stream<List<LaporanModel>> streamAktif() => _db.collection('laporan')
      .where('status', isEqualTo: 'open').orderBy('createdAt', descending: true)
      .snapshots().map((s) => s.docs.map((d) => LaporanModel.fromMap(d.data(), d.id)).toList());

  Stream<List<LaporanModel>> streamSelesai() => _db.collection('laporan')
      .where('status', whereIn: ['resolved', 'dismissed']).orderBy('createdAt', descending: true)
      .snapshots().map((s) => s.docs.map((d) => LaporanModel.fromMap(d.data(), d.id)).toList());

  Future<void> selesaikan(String id, String catatan) =>
      _db.collection('laporan').doc(id).update({'status': 'resolved', 'catatanAdmin': catatan});

  Future<void> abaikan(String id, String catatan) =>
      _db.collection('laporan').doc(id).update({'status': 'dismissed', 'catatanAdmin': catatan});
}