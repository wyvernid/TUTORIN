import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/kelas_service.dart';
import '../../models/kelas_model.dart';
import '../../models/booking_model.dart';
import '../shared/report_screen.dart';
import 'tutor_tambah_kelas_screen.dart';
import 'tutor_detail_kelas_screen.dart';

class TutorKelasScreen extends StatefulWidget {
  const TutorKelasScreen({super.key});
  @override
  State<TutorKelasScreen> createState() => _State();
}

class _State extends State<TutorKelasScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;
  final _service = KelasService();
  late final String _uid;

  @override
  void initState() { super.initState(); _tab = TabController(length: 2, vsync: this); _uid = FirebaseAuth.instance.currentUser!.uid; }
  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF5F7FA),
    appBar: AppBar(title: const Text('Kelola Kelas'), automaticallyImplyLeading: false,
      actions: [IconButton(icon: const Icon(Icons.add_circle_rounded), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TutorTambahKelasScreen())))],
      bottom: TabBar(controller: _tab, labelColor: Colors.white, unselectedLabelColor: Colors.white60, indicatorColor: Colors.white,
        tabs: const [Tab(text: 'Kelas Aktif'), Tab(text: 'Selesai')])),
    body: TabBarView(controller: _tab, children: [
      StreamBuilder<List<KelasModel>>(stream: _service.streamKelasTutor(_uid), builder: (_, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final aktif = snap.data!.where((k) => k.isActive).toList();
        if (aktif.isEmpty) return _empty('Belum ada kelas aktif. Tambah kelas baru!');
        return ListView.builder(padding: const EdgeInsets.all(14), itemCount: aktif.length, itemBuilder: (_, i) => _KelasCard(kelas: aktif[i], tutorUid: _uid, service: _service));
      }),
      StreamBuilder<List<KelasModel>>(stream: _service.streamKelasTutor(_uid), builder: (_, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final done = snap.data!.where((k) => !k.isActive).toList();
        if (done.isEmpty) return _empty('Belum ada kelas selesai.');
        return ListView.builder(padding: const EdgeInsets.all(14), itemCount: done.length, itemBuilder: (_, i) {
          final k = done[i];
          return GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TutorDetailKelasScreen(kelas: k, service: _service))),
            child: Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 5)]),
              child: Row(children: [Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 22)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(k.judul, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)), Text('${k.kuotaTerisi} murid', style: TextStyle(fontSize: 11, color: Colors.grey[600]))])),
                Row(children: [const Icon(Icons.star_rounded, size: 13, color: Color(0xFFFFC107)), const SizedBox(width: 3), Text(k.rating.toStringAsFixed(1), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))]),
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right_rounded, color: Color(0xFF78909C), size: 18),
              ])),
          );
        });
      }),
    ]));

  Widget _empty(String msg) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.inbox_rounded, size: 48, color: Colors.grey[300]), const SizedBox(height: 8), Text(msg, style: TextStyle(color: Colors.grey[400]), textAlign: TextAlign.center)]));
}

class _KelasCard extends StatefulWidget {
  final KelasModel kelas; final String tutorUid; final KelasService service;
  const _KelasCard({required this.kelas, required this.tutorUid, required this.service});
  @override
  State<_KelasCard> createState() => _KelasCardState();
}

class _KelasCardState extends State<_KelasCard> {
  bool _expanded = false;

  void _tandaiSelesaiBooking(BookingModel b) {
    showDialog(context: context, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Tandai Sesi Selesai', style: TextStyle(fontWeight: FontWeight.w700)),
      content: Text('Tandai sesi ${b.studentNama} (${b.jadwalDipilih} · ${b.jamDipilih}) sebagai selesai? Murid akan bisa memberi rating & ulasan, dan tetap bisa booking ulang kapan saja.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          onPressed: () async {
            Navigator.pop(context);
            await widget.service.selesaikanBooking(b.id);
          },
          child: const Text('Ya, Selesai'),
        ),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final k = widget.kelas;
    final prog = k.kuota > 0 ? k.kuotaTerisi / k.kuota : 0.0;
    return Container(margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        InkWell(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TutorDetailKelasScreen(kelas: k, service: widget.service))),
          child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(k.judul, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1565C0)))),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF78909C)),
            ]),
            const SizedBox(height: 6),
            Row(children: [_chip(k.kategori), const SizedBox(width: 6), Text('Rp${(k.harga/1000).toStringAsFixed(0)}.000/sesi', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1565C0)))]),
            const SizedBox(height: 6),
            Row(children: [const Icon(Icons.calendar_today_rounded, size: 12, color: Color(0xFF1565C0)), const SizedBox(width: 4),
              Text(k.pakaiJadwalSesi ? '${k.jadwalSesi.length} tanggal · ${k.totalSesi} sesi' : '${k.jadwal.join(", ")} · ${k.jamMulai} WIB', style: TextStyle(fontSize: 11, color: Colors.grey[600]))]),
            const SizedBox(height: 10),
            Row(children: [Text('${k.kuotaTerisi}/${k.kuota} slot terisi', style: TextStyle(fontSize: 11, color: Colors.grey[600])), const Spacer(),
              Text('${k.sisaSlot} sisa', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: k.sisaSlot <= 3 ? Colors.red : Colors.green))]),
            const SizedBox(height: 6),
            ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: prog, minHeight: 6, backgroundColor: Colors.grey[200], color: prog >= 0.9 ? Colors.red : const Color(0xFF1565C0))),
          ])),
        ),
        GestureDetector(onTap: () => setState(() => _expanded = !_expanded),
          child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(color: const Color(0xFFF5F7FA), borderRadius: BorderRadius.vertical(bottom: _expanded ? Radius.zero : const Radius.circular(16))),
            child: Row(children: [const Text('Daftar Murid', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1565C0))), const Spacer(),
              Icon(_expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: const Color(0xFF1565C0))]))),
        if (_expanded) StreamBuilder<List<BookingModel>>(
          stream: widget.service.streamBookingTutor(widget.tutorUid),
          builder: (_, snap) {
            if (!snap.hasData) return const Padding(padding: EdgeInsets.all(10), child: Center(child: CircularProgressIndicator()));
            final murid = snap.data!.where((b) => b.kelasId == k.id && b.status != 'rejected' && b.status != 'waiting_payment').toList();
            if (murid.isEmpty) return Padding(padding: const EdgeInsets.all(12), child: Text('Belum ada murid', style: TextStyle(fontSize: 12, color: Colors.grey[500])));
            return Column(children: murid.map((b) => Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFEEEEEE)))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(width: 30, height: 30, decoration: BoxDecoration(color: const Color(0xFF1565C0).withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.person_rounded, color: Color(0xFF1565C0), size: 16)),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(b.studentNama, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)), Text('${b.jadwalDipilih} · ${b.jamDipilih}', style: TextStyle(fontSize: 10, color: Colors.grey[500]))])),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3), decoration: BoxDecoration(
                      color: b.status == 'confirmed' ? Colors.green[50] : b.status == 'completed' ? Colors.grey[100] : Colors.orange[50],
                      borderRadius: BorderRadius.circular(20)),
                    child: Text(b.status == 'confirmed' ? 'Confirmed' : b.status == 'completed' ? 'Selesai' : 'Pending',
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
                        color: b.status == 'confirmed' ? Colors.green[700] : b.status == 'completed' ? Colors.grey[600] : Colors.orange[700]))),
                  const SizedBox(width: 6),
                  GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReportScreen(targetUid: b.studentId, targetNama: b.studentNama, targetRole: 'student', myRole: 'tutor'))),
                    child: Container(width: 26, height: 26, decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.flag_outlined, color: Colors.red, size: 13))),
                ]),
                if (b.status == 'confirmed') ...[
                  const SizedBox(height: 6),
                  Align(alignment: Alignment.centerRight,
                    child: OutlinedButton(
                      onPressed: () => _tandaiSelesaiBooking(b),
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.green), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), minimumSize: Size.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      child: const Text('Tandai Selesai', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.green)))),
                ],
              ]))).toList());
          }),
      ]));
  }
  Widget _chip(String l) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: const Color(0xFF1565C0).withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: Text(l, style: const TextStyle(fontSize: 10, color: Color(0xFF1565C0), fontWeight: FontWeight.w600)));
}