import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/kelas_model.dart';
import '../models/booking_model.dart';
import '../models/ulasan_model.dart';
import '../models/notifikasi_model.dart';
import 'notifikasi_service.dart';
import 'reminder_service.dart';

class KelasService {
  final _db = FirebaseFirestore.instance;
  final _notif = NotifikasiService();

  Stream<List<KelasModel>> streamKelasAktif({String? kategori}) {
    Query q = _db.collection('kelas').where('isActive', isEqualTo: true);
    if (kategori != null && kategori != 'Semua') q = q.where('kategori', isEqualTo: kategori);
    return q.snapshots().map((s) => s.docs
        .map((d) => KelasModel.fromMap(d.data() as Map<String, dynamic>, d.id)).toList());
  }

  Stream<List<KelasModel>> streamKelasTutor(String tutorId) => _db.collection('kelas')
      .where('tutorId', isEqualTo: tutorId).snapshots()
      .map((s) => s.docs.map((d) => KelasModel.fromMap(d.data(), d.id)).toList());

  Future<String> tambahKelas(KelasModel k) async {
    final ref = await _db.collection('kelas').add(k.toMap());
    return ref.id;
  }

  Future<void> updateKelas(String id, Map<String, dynamic> data) =>
      _db.collection('kelas').doc(id).update(data);

  Future<void> nonaktifkan(String id) => _db.collection('kelas').doc(id).update({'isActive': false});

  /// Tandai SATU booking murid (sesi yang sudah berjalan) sebagai selesai,
  /// tanpa mengubah status kelas. Kelas tetap tampil di katalog murid lain
  /// (atau murid yang sama bisa booking ulang) selama kelas masih aktif.
  Future<void> selesaikanBooking(String bookingId) =>
      _db.collection('bookings').doc(bookingId).update({'status': 'completed'});

  // Booking
  Future<String> buatBooking(BookingModel b) async {
    final ref = await _db.collection('bookings').add(b.toMap());

    // ── BARU: kabari tutor ada booking baru yang perlu diverifikasi ──
    // Dibungkus try-catch supaya kalau pengiriman notif gagal (misalnya
    // Firestore Rules untuk collection 'notifikasi' belum diatur), proses
    // booking TETAP berhasil — notifikasi adalah pelengkap, bukan syarat.
    try {
      await _notif.kirim(
        uid: b.tutorId,
        role: 'tutor',
        tipe: NotifikasiTipe.bookingBaru,
        judul: 'Booking baru',
        pesan: '${b.studentNama} memesan kelas "${b.kelasJudul}"',
        refId: ref.id,
        refType: 'booking',
      );
    } catch (e) {
      print('Gagal kirim notifikasi booking baru: $e');
    }

    return ref.id;
  }

  Future<void> uploadBukti(String bookingId, String url) =>
      _db.collection('bookings').doc(bookingId).update(
          {'buktiBayarUrl': url, 'status': 'waiting_verification'});
  
    Future<void> batalkanBooking(String bookingId) =>
      _db.collection('bookings').doc(bookingId).delete();
      

  Future<void> konfirmasi(String bookingId, String kelasId) async {
    final batch = _db.batch();
    batch.update(_db.collection('bookings').doc(bookingId),
        {'status': 'confirmed', 'confirmedAt': FieldValue.serverTimestamp()});
    batch.update(_db.collection('kelas').doc(kelasId),
        {'kuotaTerisi': FieldValue.increment(1)});
    await batch.commit();

    // ── BARU: kabari student bookingnya dikonfirmasi + jadwalkan reminder ──
    // Dibungkus try-catch: kalau notif/reminder gagal, konfirmasi booking
    // (yang sudah ter-commit di batch di atas) tetap dianggap berhasil.
    try {
      final doc = await _db.collection('bookings').doc(bookingId).get();
      final b = doc.data();
      if (b != null) {
        await _notif.kirim(
          uid: b['studentId'] ?? '',
          role: 'student',
          tipe: NotifikasiTipe.bookingDikonfirmasi,
          judul: 'Booking dikonfirmasi',
          pesan: 'Pembayaranmu untuk "${b['kelasJudul'] ?? ''}" sudah diverifikasi tutor.',
          refId: bookingId,
          refType: 'booking',
        );

        // Jadwalkan reminder lokal 30 menit sebelum kelas dimulai.
        // Kalau format jadwal/jam tidak sesuai dugaan, parseJadwalBooking
        // mengembalikan null dan reminder otomatis di-skip (tidak crash).
        final waktuMulai = ReminderService.parseJadwalBooking(
          b['jadwalDipilih'] ?? '',
          b['jamDipilih'] ?? '',
        );
        if (waktuMulai != null) {
          await ReminderService.jadwalkanReminderKelas(
            bookingId: bookingId,
            judulKelas: b['kelasJudul'] ?? '',
            waktuMulaiKelas: waktuMulai,
          );
        }
      }
    } catch (e) {
      print('Gagal kirim notifikasi/reminder konfirmasi booking: $e');
    }
  }

  

  Future<void> tolak(String bookingId, String alasan) async {
    await _db.collection('bookings').doc(bookingId).update({'status': 'rejected', 'alasanTolak': alasan});

    // ── BARU: kabari student bookingnya ditolak ──
    try {
      final doc = await _db.collection('bookings').doc(bookingId).get();
      final b = doc.data();
      if (b != null) {
        await _notif.kirim(
          uid: b['studentId'] ?? '',
          role: 'student',
          tipe: NotifikasiTipe.bookingDitolak,
          judul: 'Booking ditolak',
          pesan: 'Pembayaranmu untuk "${b['kelasJudul'] ?? ''}" ditolak. Alasan: $alasan',
          refId: bookingId,
          refType: 'booking',
        );
      }
    } catch (e) {
      print('Gagal kirim notifikasi booking ditolak: $e');
    }
  }

  Stream<List<BookingModel>> streamBookingStudent(String studentId) => _db.collection('bookings')
      .where('studentId', isEqualTo: studentId).orderBy('createdAt', descending: true)
      .snapshots().map((s) => s.docs.map((d) => BookingModel.fromMap(d.data(), d.id)).toList());

  Stream<List<BookingModel>> streamBookingPendingTutor(String tutorId) => _db.collection('bookings')
      .where('tutorId', isEqualTo: tutorId).where('status', isEqualTo: 'waiting_verification')
      .snapshots().map((s) => s.docs.map((d) => BookingModel.fromMap(d.data(), d.id)).toList());

  Stream<List<BookingModel>> streamBookingTutor(String tutorId) => _db.collection('bookings')
      .where('tutorId', isEqualTo: tutorId).orderBy('createdAt', descending: true)
      .snapshots().map((s) => s.docs.map((d) => BookingModel.fromMap(d.data(), d.id)).toList());

  /// Hitung ulang rating & jumlahUlasan kelas dari data ulasan yang sudah ada
  /// di Firestore. Berguna untuk sinkronisasi ulang ulasan lama yang gagal
  /// terhitung sebelum security rules diperbaiki.
  Future<void> recalculateRatingKelas(String kelasId) async {
    final snap = await _db.collection('ulasan').where('kelasId', isEqualTo: kelasId).get();
    final avg = snap.docs.isEmpty ? 0.0
        : snap.docs.map((d) => (d.data()['rating'] as num).toDouble()).reduce((a, b) => a + b) / snap.docs.length;
    await _db.collection('kelas').doc(kelasId).update({'rating': avg, 'jumlahUlasan': snap.docs.length});
  }

  /// Stream semua ulasan untuk satu kelas, terbaru lebih dulu.
  Stream<List<UlasanModel>> streamUlasanKelas(String kelasId) => _db.collection('ulasan')
      .where('kelasId', isEqualTo: kelasId).orderBy('createdAt', descending: true)
      .snapshots().map((s) => s.docs.map((d) => UlasanModel.fromMap(d.data(), d.id)).toList());

  Future<void> submitUlasan({required String bookingId, required String kelasId,
      required String tutorId, required int rating, required String komentar, required String studentNama}) async {
    final batch = _db.batch();
    batch.update(_db.collection('bookings').doc(bookingId), {'reviewed': true, 'status': 'completed'});
    batch.set(_db.collection('ulasan').doc(), {
      'kelasId': kelasId, 'tutorId': tutorId, 'studentNama': studentNama,
      'rating': rating, 'komentar': komentar, 'createdAt': FieldValue.serverTimestamp()});
    await batch.commit();

    // Hitung ulang rating & jumlah ulasan KELAS (yang sebelumnya tidak pernah terupdate)
    final kelasUlasan = await _db.collection('ulasan').where('kelasId', isEqualTo: kelasId).get();
    if (kelasUlasan.docs.isNotEmpty) {
      final avgKelas = kelasUlasan.docs.map((d) => (d.data()['rating'] as num).toDouble()).reduce((a, b) => a + b) / kelasUlasan.docs.length;
      await _db.collection('kelas').doc(kelasId).update({'rating': avgKelas, 'jumlahUlasan': kelasUlasan.docs.length});
    }

    // Hitung ulang rating tutor (rata-rata dari seluruh ulasan kelas-kelas tutor tersebut)
    final tutorUlasan = await _db.collection('ulasan').where('tutorId', isEqualTo: tutorId).get();
    if (tutorUlasan.docs.isNotEmpty) {
      final avgTutor = tutorUlasan.docs.map((d) => (d.data()['rating'] as num).toDouble()).reduce((a, b) => a + b) / tutorUlasan.docs.length;
      await _db.collection('users').doc(tutorId).update({'rating': avgTutor, 'jumlahUlasan': tutorUlasan.docs.length});
    }

    // ── BARU: kabari tutor ada ulasan baru ──
    try {
      await _notif.kirim(
        uid: tutorId,
        role: 'tutor',
        tipe: NotifikasiTipe.ulasanBaru,
        judul: 'Ulasan baru',
        pesan: '$studentNama memberi rating $rating★: $komentar',
        refId: kelasId,
        refType: 'kelas',
      );
    } catch (e) {
      print('Gagal kirim notifikasi ulasan baru: $e');
    }
  }

  Future<KelasModel?> getKelasById(String kelasId) async {
    try {
      final doc = await _db.collection('kelas').doc(kelasId).get();
      if (doc.exists && doc.data() != null) {
        // Menggunakan fromMap sesuai dengan struktur model yang Anda miliki
        return KelasModel.fromMap(doc.data()!, doc.id);
      }
    } catch (e) {
      print("Error getKelasById: $e");
    }
    return null; // Mengembalikan null jika kelas tidak ditemukan atau error
  }

}