import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/kelas_service.dart';
import '../../services/auth_service.dart';
import '../../models/booking_model.dart';
import '../../models/user_model.dart';
import 'tutor_verifikasi_pembayaran_screen.dart';
import '../shared/notifikasi_badged_icon.dart';

class TutorBerandaScreen extends StatefulWidget {
  const TutorBerandaScreen({super.key});
  @override
  State<TutorBerandaScreen> createState() => _State();
}

class _State extends State<TutorBerandaScreen> {
  final _kelas = KelasService(); 
  final _auth = AuthService();
  UserModel? _user;
  late final String _uid;
  
  // Variabel untuk menyimpan pendapatan khusus bulan ini
  int _pendapatanBulanIni = 0;

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser!.uid;
    _syncAndLoadStats();
  }

  // FUNGSI SINKRONISASI STATISTIK TUTOR
  Future<void> _syncAndLoadStats() async {
    try {
      final db = FirebaseFirestore.instance;
      
      // 1. Ambil semua booking yang confirmed atau completed
      final bookings = await db.collection('bookings')
          .where('tutorId', isEqualTo: _uid)
          .where('status', whereIn: ['confirmed', 'completed'])
          .get();
      
      final uniqueStudents = <String>{};
      int tempPendapatan = 0;
      final now = DateTime.now();

      for (var doc in bookings.docs) {
        final data = doc.data();
        
        // A. Hitung total murid aktif (ID murid unik)
        final sid = data['studentId'] as String?;
        if (sid != null) uniqueStudents.add(sid);

        // B. Hitung pendapatan bulan ini
        // Menggunakan waktu konfirmasi, atau mundur ke waktu pembuatan booking
        final ts = data['confirmedAt'] ?? data['createdAt'];
        if (ts != null && ts is Timestamp) {
          final date = ts.toDate();
          if (date.month == now.month && date.year == now.year) {
            tempPendapatan += (data['nominal'] as num?)?.toInt() ?? 0;
          }
        }
      }

      // 2. Hitung Rating Tutor (rata-rata dari semua ulasan kelas milik tutor ini)
      final ulasan = await db.collection('ulasan')
          .where('tutorId', isEqualTo: _uid)
          .get();
      
      double avgRating = 0.0;
      if (ulasan.docs.isNotEmpty) {
        double total = 0;
        for (var doc in ulasan.docs) {
          total += (doc.data()['rating'] as num?)?.toDouble() ?? 0.0;
        }
        avgRating = total / ulasan.docs.length;
      }

      // 3. Update ke Firestore Profil Tutor
      await db.collection('users').doc(_uid).update({
        'totalMurid': uniqueStudents.length,
        'rating': avgRating,
      });

      // Update UI dengan data yang baru dihitung
      if (mounted) {
        setState(() {
          _pendapatanBulanIni = tempPendapatan;
        });
      }
    } catch (e) {
      debugPrint('Gagal sync stats beranda: $e');
    }

    // Load data profil terbaru (termasuk update yang baru disimpan ke Firestore)
    final u = await _auth.getUserData(_uid);
    if (mounted) setState(() => _user = u);
  }

  // Helper mengubah nominal int jadi format Rupiah yang rapi
  String _formatRp(int nominal) {
    if (nominal == 0) return 'Rp0';
    String s = nominal.toString();
    String result = '';
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      if (count != 0 && count % 3 == 0) result = '.$result';
      result = s[i] + result;
      count++;
    }
    return 'Rp$result';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF5F7FA),
    body: CustomScrollView(slivers: [
      SliverToBoxAdapter(child: _buildHeader()),
      SliverToBoxAdapter(child: _buildStats()),
      SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(16,16,16,8),
        child: Row(children: [
          Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          const Text('Menunggu Verifikasi Pembayaran', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        ]))),
      StreamBuilder<List<BookingModel>>(
        stream: _kelas.streamBookingPendingTutor(_uid),
        builder: (_, snap) {
          if (!snap.hasData) return const SliverToBoxAdapter(child: SizedBox());
          final items = snap.data!;
          if (items.isEmpty) return SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(16,0,16,8),
            child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Row(children: [const Icon(Icons.check_circle_rounded, color: Colors.green, size: 18), const SizedBox(width: 8), Text('Tidak ada yang menunggu verifikasi', style: TextStyle(fontSize: 12, color: Colors.grey[600]))]))));
          return SliverList(delegate: SliverChildBuilderDelegate((_, i) => _PayCard(booking: items[i]), childCount: items.length));
        }),
      SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(16,8,16,8), child: const Text('Kelas Mendatang', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)))),
      StreamBuilder<List<BookingModel>>(
        stream: _kelas.streamBookingTutor(_uid),
        builder: (_, snap) {
          if (!snap.hasData) return const SliverToBoxAdapter(child: SizedBox());
          final confirmed = snap.data!.where((b) => b.status == 'confirmed').take(5).toList();
          return SliverList(delegate: SliverChildBuilderDelegate((_, i) {
            final b = confirmed[i];
            return Container(margin: const EdgeInsets.fromLTRB(16,0,16,8), padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 5)]),
              child: Row(children: [
                Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFF1565C0).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.class_rounded, color: Color(0xFF1565C0), size: 20)),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(b.kelasJudul, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text('Murid: ${b.studentNama}', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(b.jadwalDipilih, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                  Text(b.jamDipilih, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF1565C0))),
                ]),
              ]));
          }, childCount: confirmed.length));
        }),
      const SliverToBoxAdapter(child: SizedBox(height: 20)),
    ]));

  Widget _buildHeader() => Container(
    padding: const EdgeInsets.fromLTRB(20,56,20,20),
    decoration: const BoxDecoration(color: Color(0xFF1565C0), borderRadius: BorderRadius.vertical(bottom: Radius.circular(28))),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [Text('Hi Tutor ', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)), Text('🎓', style: TextStyle(fontSize: 20))]),
        const Text('Dashboard Pengajar', style: TextStyle(color: Colors.white70, fontSize: 13)),
      ])),
      NotifikasiBadgeIcon(uid: _uid, role: 'tutor', circleBackground: true),
    ]));

  Widget _buildStats() {
    final u = _user;
    return Padding(padding: const EdgeInsets.fromLTRB(16,14,16,0), child: Row(children: [
      _stat(_formatRp(_pendapatanBulanIni), 'Pendapatan Bulan Ini', Icons.account_balance_wallet_rounded, Colors.green),
      const SizedBox(width: 10),
      _stat('${u?.totalMurid ?? 0}', 'Murid Aktif', Icons.people_rounded, const Color(0xFF1565C0)),
      const SizedBox(width: 10),
      _stat(u != null && u.rating > 0 ? u.rating.toStringAsFixed(1) : '-', 'Rating', Icons.star_rounded, Colors.amber),
    ]));
  }

  Widget _stat(String v, String l, IconData icon, Color c) => Expanded(child: Container(padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 5)]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: c, size: 18), 
      const SizedBox(height: 6), 
      Text(v, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800), maxLines: 1, overflow: TextOverflow.ellipsis), 
      Text(l, style: TextStyle(fontSize: 9, color: Colors.grey[500]), maxLines: 2)
    ])));
}

class _PayCard extends StatelessWidget {
  final BookingModel booking;
  const _PayCard({required this.booking});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TutorVerifikasiPembayaranScreen(booking: booking))),
    child: Container(margin: const EdgeInsets.fromLTRB(16,0,16,8), padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.orange[200]!),
        boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.06), blurRadius: 6)]),
      child: Row(children: [
        Container(width: 42, height: 42, decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(10)),
          child: Icon(Icons.receipt_long_rounded, color: Colors.orange[700], size: 20)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(booking.studentNama, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          Text(booking.kelasJudul, style: TextStyle(fontSize: 11, color: Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text('${booking.jadwalDipilih} · ${booking.jamDipilih}', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('Rp${(booking.nominal/1000).toStringAsFixed(0)}.000', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF1565C0))),
          const SizedBox(height: 4),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(20)),
            child: const Text('Verifikasi', style: TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.w700))),
        ]),
      ])));
}