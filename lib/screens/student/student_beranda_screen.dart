import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/kelas_service.dart';
import '../../services/auth_service.dart';
import '../../models/kelas_model.dart';
import 'student_detail_kelas_screen.dart';

class StudentBerandaScreen extends StatefulWidget {
  const StudentBerandaScreen({super.key});
  @override
  State<StudentBerandaScreen> createState() => _State();
}

class _State extends State<StudentBerandaScreen> {
  final _kelasService = KelasService();
  final _authService  = AuthService();
  String _kategori = 'Semua';
  String _search   = '';
  String _namaUser = '';

  final _cats = [
    'Semua', 'Algoritma', 'Basda', 'Jarkom',
    'PBO', 'Machine Learning', 'Mobile Dev',
  ];

  @override
  void initState() {
    super.initState();
    _loadNama();
  }

  Future<void> _loadNama() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final user = await _authService.getUserData(uid);
    if (mounted) setState(() => _namaUser = user?.nama ?? '');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF5F7FA),
    body: CustomScrollView(slivers: [
      SliverToBoxAdapter(child: _buildHeader()),
      SliverToBoxAdapter(child: _buildCategories()),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Text('Tutor dan Pembelajaran Tersedia',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.grey[800])))),
      StreamBuilder<List<KelasModel>>(
        stream: _kelasService.streamKelasAktif(
            kategori: _kategori == 'Semua' ? null : _kategori),
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting)
            return const SliverToBoxAdapter(
              child: Center(child: Padding(padding: EdgeInsets.all(40),
                child: CircularProgressIndicator())));

          final list = (snap.data ?? []).where((k) =>
            _search.isEmpty ||
            k.judul.toLowerCase().contains(_search.toLowerCase()) ||
            k.tutorNama.toLowerCase().contains(_search.toLowerCase())
          ).toList();

          if (list.isEmpty)
            return SliverToBoxAdapter(
              child: Center(child: Padding(padding: const EdgeInsets.all(40),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.search_off_rounded, size: 56, color: Colors.grey[300]),
                  const SizedBox(height: 10),
                  Text('Belum ada kelas tersedia',
                      style: TextStyle(color: Colors.grey[400], fontSize: 14)),
                ]))));

          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) => _KelasCard(kelas: list[i]),
              childCount: list.length));
        }),
      const SliverToBoxAdapter(child: SizedBox(height: 24)),
    ]));

  Widget _buildHeader() => Container(
    padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
    decoration: const BoxDecoration(
      color: Color(0xFF1565C0),
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(28))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(
              _namaUser.isNotEmpty ? 'Hi, $_namaUser 👋' : 'Hi Murid 👋',
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
          ]),
          const Text('Lets Start Learning',
              style: TextStyle(color: Colors.white70, fontSize: 13)),
        ])),
        Container(width: 44, height: 44,
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
          child: const Icon(Icons.notifications_rounded, color: Colors.white, size: 24)),
      ]),
      const SizedBox(height: 16),
      Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)]),
        child: TextField(
          style: const TextStyle(fontSize: 14),
          onChanged: (v) => setState(() => _search = v),
          decoration: InputDecoration(
            hintText: 'Cari tutor atau mata pelajaran...',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
            prefixIcon: const Icon(Icons.search, color: Color(0xFF1565C0)),
            suffixIcon: _search.isNotEmpty
                ? IconButton(icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                    onPressed: () => setState(() => _search = ''))
                : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            filled: true, fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 12)))),
    ]));

  Widget _buildCategories() => SizedBox(
    height: 52,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: _cats.length,
      itemBuilder: (_, i) {
        final sel = _kategori == _cats[i];
        return Container(
          margin: const EdgeInsets.only(right: 8),
          child: FilterChip(
            label: Text(_cats[i]),
            selected: sel,
            onSelected: (_) => setState(() => _kategori = _cats[i]),
            selectedColor: const Color(0xFF1565C0),
            backgroundColor: Colors.white,
            labelStyle: TextStyle(
              color: sel ? Colors.white : Colors.grey[700],
              fontSize: 12, fontWeight: FontWeight.w600),
            side: BorderSide.none,
            padding: const EdgeInsets.symmetric(horizontal: 4)));
      }));
} // ← penutup class _State

class _KelasCard extends StatelessWidget {
  final KelasModel kelas;
  const _KelasCard({required this.kelas});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: kelas.isFull
        ? null
        : () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => StudentDetailKelasScreen(kelas: kelas))),
    child: Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 64, height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFF1565C0).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12)),
          child: kelas.tutorFotoUrl.isNotEmpty
              ? ClipRRect(borderRadius: BorderRadius.circular(12),
                  child: Image.network(kelas.tutorFotoUrl, fit: BoxFit.cover))
              : const Icon(Icons.person_rounded, color: Color(0xFF1565C0), size: 36)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(kelas.judul,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1565C0)),
            maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text('Tutor: ${kelas.tutorNama}',
            style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          const SizedBox(height: 6),
          Row(children: [
            ...kelas.jadwal.take(3).map((s) => Container(
              margin: const EdgeInsets.only(right: 4),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF1565C0).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6)),
              child: Text(s, style: const TextStyle(
                fontSize: 9, fontWeight: FontWeight.w600, color: Color(0xFF1565C0))))),
            if (kelas.jadwal.length > 3)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(6)),
                child: Text('+${kelas.jadwal.length - 3}',
                    style: TextStyle(fontSize: 9, color: Colors.grey[600]))),
          ]),
          const SizedBox(height: 5),
          if (kelas.lokasi.isNotEmpty)
            Row(children: [
              const Icon(Icons.location_on_rounded, size: 11, color: Color(0xFF1565C0)),
              const SizedBox(width: 3),
              Expanded(child: Text(kelas.lokasi,
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                maxLines: 1, overflow: TextOverflow.ellipsis))]),
          const SizedBox(height: 6),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(kelas.hargaFormatted,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF1565C0))),
              Text(kelas.isFull ? 'Penuh' : '${kelas.sisaSlot} slot tersisa',
                style: TextStyle(fontSize: 10,
                  color: kelas.isFull ? Colors.red : Colors.grey[500],
                  fontWeight: kelas.isFull ? FontWeight.w700 : FontWeight.w400)),
            ]),
            Row(children: [
              const Icon(Icons.star_rounded, size: 13, color: Color(0xFFFFC107)),
              const SizedBox(width: 2),
              Text('${kelas.rating.toStringAsFixed(1)} (${kelas.jumlahUlasan})',
                style: TextStyle(fontSize: 10, color: Colors.grey[600])),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: kelas.isFull ? Colors.grey[300] : const Color(0xFF1565C0),
                  borderRadius: BorderRadius.circular(8)),
                child: Text(kelas.isFull ? 'Penuh' : 'Detail',
                  style: TextStyle(
                    color: kelas.isFull ? Colors.grey[600] : Colors.white,
                    fontSize: 10, fontWeight: FontWeight.w700))),
            ]),
          ]),
        ])),
      ])));
}