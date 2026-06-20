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

  String _selectedTag = 'Semua'; // 'Semua' = tidak ada filter tag
  String _search      = '';
  String _namaUser    = '';

  /// Tag populer: 'Semua' + tag yang paling sering muncul di kelas aktif.
  /// Diisi setelah data kelas pertama kali diterima.
  List<String> _popularTags = ['Semua'];

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

  /// Hitung tag populer dari daftar kelas aktif.
  /// Urutkan berdasarkan frekuensi kemunculan di kelas yang paling banyak dibooking
  /// (didekati dengan frekuensi di seluruh kelas aktif).
  List<String> _hitungTagPopuler(List<KelasModel> kelasList) {
    final freq = <String, int>{};
    for (final k in kelasList) {
      for (final tag in k.tags) {
        freq[tag] = (freq[tag] ?? 0) + 1;
      }
    }
    final sorted = freq.keys.toList()
      ..sort((a, b) => (freq[b] ?? 0).compareTo(freq[a] ?? 0));
    // Ambil max 8 tag populer
    return ['Semua', ...sorted.take(8)];
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(slivers: [
        SliverToBoxAdapter(child: _buildHeader()),
        // Chip filter berdasarkan stream kelas — isi chip dinamis dari data
        StreamBuilder<List<KelasModel>>(
          stream: _kelasService.streamKelasAktif(),
          builder: (_, snap) {
            if (snap.hasData) {
              // Update tag populer tiap kali data berubah
              final tags = _hitungTagPopuler(snap.data!);
              if (!listEquals(tags, _popularTags)) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() {
                      _popularTags = tags;
                      // Reset filter jika tag yang dipilih sudah tidak ada
                      if (!_popularTags.contains(_selectedTag)) {
                        _selectedTag = 'Semua';
                      }
                    });
                  }
                });
              }
            }
            return SliverToBoxAdapter(child: _buildTagChips());
          },
        ),
        SliverToBoxAdapter(
            child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Text('Tutor dan Pembelajaran Tersedia',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[800])))),
        // Daftar kelas — difilter berdasarkan tag yang dipilih
        StreamBuilder<List<KelasModel>>(
          stream: _kelasService.streamKelasAktif(),
          builder: (_, snap) {
            if (snap.connectionState == ConnectionState.waiting)
              return const SliverToBoxAdapter(
                  child: Center(
                      child: Padding(
                          padding: EdgeInsets.all(40),
                          child: CircularProgressIndicator())));

            var list = snap.data ?? [];

            // Filter berdasarkan tag yang dipilih
            if (_selectedTag != 'Semua') {
              list = list
                  .where((k) => k.tags.contains(_selectedTag))
                  .toList();
            }

            // Filter berdasarkan search
            if (_search.isNotEmpty) {
              list = list
                  .where((k) =>
                      k.judul
                          .toLowerCase()
                          .contains(_search.toLowerCase()) ||
                      k.tutorNama
                          .toLowerCase()
                          .contains(_search.toLowerCase()) ||
                      k.tags.any((t) =>
                          t.toLowerCase().contains(_search.toLowerCase())))
                  .toList();
            }

            if (list.isEmpty)
              return SliverToBoxAdapter(
                  child: Center(
                      child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.search_off_rounded,
                                size: 56, color: Colors.grey[300]),
                            const SizedBox(height: 10),
                            Text('Belum ada kelas tersedia',
                                style: TextStyle(
                                    color: Colors.grey[400], fontSize: 14)),
                          ]))));

            return SliverList(
                delegate: SliverChildBuilderDelegate(
                    (_, i) => _KelasCard(kelas: list[i]),
                    childCount: list.length));
          },
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ]));

  Widget _buildHeader() => Container(
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
      decoration: const BoxDecoration(
          color: Color(0xFF1565C0),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(28))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Row(children: [
                  Text(
                      _namaUser.isNotEmpty
                          ? 'Hi, $_namaUser 👋'
                          : 'Hi Murid 👋',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800)),
                ]),
                const Text('Lets Start Learning',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
              ])),
          Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle),
              child: const Icon(Icons.notifications_rounded,
                  color: Colors.white, size: 24)),
        ]),
        const SizedBox(height: 16),
        Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.06), blurRadius: 8)
                ]),
            child: TextField(
                style: const TextStyle(fontSize: 14),
                onChanged: (v) => setState(() => _search = v),
                decoration: InputDecoration(
                    hintText: 'Cari tutor, pelajaran, atau tag...',
                    hintStyle:
                        TextStyle(color: Colors.grey[400], fontSize: 13),
                    prefixIcon:
                        const Icon(Icons.search, color: Color(0xFF1565C0)),
                    suffixIcon: _search.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear,
                                size: 18, color: Colors.grey),
                            onPressed: () => setState(() => _search = ''))
                        : null,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 12)))),
      ]));

  Widget _buildTagChips() => SizedBox(
      height: 52,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          itemCount: _popularTags.length,
          itemBuilder: (_, i) {
            final tag = _popularTags[i];
            final sel = _selectedTag == tag;
            return Container(
                margin: const EdgeInsets.only(right: 8),
                child: FilterChip(
                    label: tag == 'Semua'
                        ? const Text('Semua')
                        : Row(mainAxisSize: MainAxisSize.min, children: [
                            Text(tag),
                            // Indikator "populer" untuk tag selain Semua
                            if (i == 1) ...[
                              const SizedBox(width: 4),
                              Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                      color: sel
                                          ? Colors.white70
                                          : Colors.orange,
                                      shape: BoxShape.circle)),
                            ],
                          ]),
                    selected: sel,
                    onSelected: (_) =>
                        setState(() => _selectedTag = tag),
                    selectedColor: const Color(0xFF1565C0),
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                        color: sel ? Colors.white : Colors.grey[700],
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(horizontal: 4)));
          }));
}

// ── Fungsi helper kecil ────────────────────────────────────────────────────

bool listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

class _KelasCard extends StatelessWidget {
  final KelasModel kelas;
  const _KelasCard({required this.kelas});

  String _getNamaHari(DateTime date) {
    const hari = ['', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    return (date.weekday >= 1 && date.weekday <= 7) ? hari[date.weekday] : '';
  }

  @override
  Widget build(BuildContext context) {
    final List<String> hariDariSesi = kelas.jadwalSesi.map((s) => _getNamaHari(s.tanggal)).toSet().toList();
    final List<String> listHariToDisplay = hariDariSesi.isNotEmpty ? hariDariSesi : kelas.jadwal;
    bool isOnline = kelas.mode.toLowerCase() == 'online';
    String teksLokasi = isOnline ? 'Kelas Online' : (kelas.lokasi.isNotEmpty ? kelas.lokasi : 'Lokasi belum ditentukan');
    IconData iconLokasi = isOnline ? Icons.videocam_rounded : Icons.location_on_rounded;

    return GestureDetector(
      onTap: kelas.isFull ? null : () => Navigator.push(context, MaterialPageRoute(builder: (_) => StudentDetailKelasScreen(kelas: kelas))),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12), padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FOTO TUTOR (Tetap di kiri mentok)
            Container(
              width: 70, height: 70,
              decoration: BoxDecoration(color: const Color(0xFF1565C0).withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
              child: kelas.tutorFotoUrl.isNotEmpty
                  ? ClipRRect(borderRadius: BorderRadius.circular(14), child: Image.network(kelas.tutorFotoUrl, fit: BoxFit.cover))
                  : const Icon(Icons.person_rounded, color: Color(0xFF1565C0), size: 34),
            ),
            const SizedBox(width: 14),

            // AREA KONTEN (DIBAGI 2 KOLOM: KIRI & KANAN)
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- KOLOM KIRI (Judul, Tutor, Tag, Hari, Lokasi) ---
                  Expanded(
                    flex: 6, // Porsi kolom kiri sedikit lebih lebar
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(kelas.judul, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF1A237E), height: 1.2), maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 6),
                        Text('Tutor: ${kelas.tutorNama}', style: TextStyle(fontSize: 11, color: Colors.grey[600]), overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 10),
                        
                        // Tag dipisah barisnya
                        if (kelas.tags.isNotEmpty) Wrap(spacing: 6, runSpacing: 6, children: kelas.tags.take(2).map((t) => _pill(t, isTag: true)).toList()),
                        const SizedBox(height: 6),
                        
                        // Hari di bawah Tag (tidak disatukan)
                        if (listHariToDisplay.isNotEmpty) Wrap(spacing: 6, runSpacing: 6, children: [...listHariToDisplay.take(3).map((s) => _pill(s, isTag: false)), if (listHariToDisplay.length > 3) _pill('+${listHariToDisplay.length - 3}', isTag: false)]),
                        const SizedBox(height: 10),
                        
                        // Lokasi/Link di paling bawah
                        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Icon(iconLokasi, size: 14, color: Colors.grey[600]), const SizedBox(width: 4),
                          Expanded(child: Text(teksLokasi, style: TextStyle(fontSize: 11, color: Colors.grey[600]), maxLines: 2, overflow: TextOverflow.ellipsis)),
                        ]),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 12),

                  // --- KOLOM KANAN (Harga, Rating, Slot, Detail) ---
                  Expanded(
                    flex: 4, 
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end, // Rata kanan
                      children: [
                        Text(kelas.hargaFormatted, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF1565C0)), textAlign: TextAlign.right),
                        const SizedBox(height: 6),
                        Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.star_rounded, size: 16, color: Colors.amber), const SizedBox(width: 2), Text('${kelas.rating.toStringAsFixed(1)} (${kelas.jumlahUlasan})', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF212121)))]),
                        const SizedBox(height: 10),
                        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: kelas.isFull ? Colors.red[50] : Colors.green[50], borderRadius: BorderRadius.circular(6)), child: Text(kelas.isFull ? 'Penuh' : '${kelas.sisaSlot} Slot', style: TextStyle(fontSize: 10, color: kelas.isFull ? Colors.red[700] : Colors.green[700], fontWeight: FontWeight.w800))),
                        const SizedBox(height: 24), // Jarak agak jauh agar tombol detail turun ke bawah
                        _buildStatusButton(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(String label, {required bool isTag}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: isTag ? const Color(0xFFE3F2FD) : const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: isTag ? const Color(0xFF1565C0) : const Color(0xFF616161))),
    );
  }

  Widget _buildStatusButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: kelas.isFull ? Colors.grey[300] : const Color(0xFF1565C0), borderRadius: BorderRadius.circular(8)),
      child: Text(kelas.isFull ? 'Penuh' : 'Detail Kelas', style: TextStyle(color: kelas.isFull ? Colors.grey[600] : Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}