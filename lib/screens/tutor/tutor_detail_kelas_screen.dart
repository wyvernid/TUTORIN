import 'package:flutter/material.dart';
import '../../models/kelas_model.dart';
import '../../models/booking_model.dart';
import '../../services/kelas_service.dart';
import 'tutor_tambah_kelas_screen.dart';

class TutorDetailKelasScreen extends StatefulWidget {
  final KelasModel kelas;
  final KelasService service;
  const TutorDetailKelasScreen({super.key, required this.kelas, required this.service});
  @override
  State<TutorDetailKelasScreen> createState() => _State();
}

class _State extends State<TutorDetailKelasScreen> {
  bool _loading = false;

  void _edit() async {
    final updated = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => TutorTambahKelasScreen(kelas: widget.kelas)));
    if (updated == true && mounted) Navigator.pop(context);
  }

  void _hentikanKelas() {
    showDialog(context: context, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Hentikan Kelas', style: TextStyle(fontWeight: FontWeight.w700)),
      content: const Text('Kelas ini akan disembunyikan dari katalog murid dan tidak menerima booking baru. Riwayat booking murid yang sudah ada tidak berubah. Lanjutkan?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () async {
            Navigator.pop(context);
            setState(() => _loading = true);
            try {
              await widget.service.nonaktifkan(widget.kelas.id);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kelas disembunyikan dari katalog'), backgroundColor: Colors.green));
              Navigator.pop(context);
            } finally { if (mounted) setState(() => _loading = false); }
          },
          child: const Text('Ya, Hentikan'),
        ),
      ],
    ));
  }

  void _aktifkanKembali() async {
    setState(() => _loading = true);
    try {
      await widget.service.updateKelas(widget.kelas.id, {'isActive': true});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kelas tampil lagi di katalog'), backgroundColor: Colors.green));
      Navigator.pop(context);
    } finally { if (mounted) setState(() => _loading = false); }
  }

  void _tandaiSelesaiBooking(BookingModel b) {
    showDialog(context: context, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Tandai Sesi Selesai', style: TextStyle(fontWeight: FontWeight.w700)),
      content: Text('Tandai sesi ${b.studentNama} (${b.jadwalDipilih} · ${b.jamDipilih}) sebagai selesai? Murid akan bisa memberi rating & ulasan untuk kelas ini, dan tetap bisa booking ulang kapan saja.'),
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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(title: const Text('Detail Kelas'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(icon: const Icon(Icons.edit_rounded), onPressed: _loading ? null : _edit, tooltip: 'Edit Kelas'),
        ]),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(k.judul, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1565C0)))),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: k.isActive ? Colors.green[50] : Colors.grey[200], borderRadius: BorderRadius.circular(20)),
              child: Text(k.isActive ? 'Tampil di Katalog' : 'Tersembunyi', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: k.isActive ? Colors.green[700] : Colors.grey[600]))),
          ]),
          const SizedBox(height: 8),
          Row(children: [_chip(k.kategori), const SizedBox(width: 6), Text('${k.hargaFormatted}/sesi', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1565C0)))]),
          if (k.deskripsi.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(k.deskripsi, style: TextStyle(fontSize: 12, color: Colors.grey[700], height: 1.4)),
          ],
          if (k.tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(spacing: 6, runSpacing: 6, children: k.tags.map((t) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(20)),
              child: Text(t, style: TextStyle(fontSize: 10, color: Colors.grey[700])))).toList()),
          ],
        ])),
        const SizedBox(height: 12),
        _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Jadwal & Lokasi', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          _row(Icons.calendar_today_rounded, 'Hari', k.jadwal.join(', ')),
          const SizedBox(height: 8),
          _row(Icons.access_time_rounded, 'Jam', '${k.jamMulai} WIB · ${k.durasi}'),
          const SizedBox(height: 8),
          _row(Icons.cast_for_education_rounded, 'Mode', k.mode == 'offline' ? 'Offline' : k.mode == 'online' ? 'Online' : 'Offline & Online'),
          if (k.lokasi.isNotEmpty) ...[const SizedBox(height: 8), _row(Icons.location_on_rounded, 'Lokasi', k.lokasi)],
        ])),
        const SizedBox(height: 12),
        _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Statistik Kelas', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          _row(Icons.people_rounded, 'Murid', '${k.kuotaTerisi}/${k.kuota} terisi (${k.sisaSlot} sisa)'),
          const SizedBox(height: 8),
          _row(Icons.star_rounded, 'Rating', '${k.rating.toStringAsFixed(1)} dari ${k.jumlahUlasan} ulasan'),
          const SizedBox(height: 8),
          _row(Icons.event_rounded, 'Dibuat', '${k.createdAt.day}/${k.createdAt.month}/${k.createdAt.year}'),
        ])),
        const SizedBox(height: 12),
        _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Daftar Murid', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Tandai sesi per murid sebagai selesai sesuai jadwalnya masing-masing.', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
          const SizedBox(height: 10),
          StreamBuilder<List<BookingModel>>(
            stream: widget.service.streamBookingTutor(k.tutorId),
            builder: (_, snap) {
              if (!snap.hasData) return const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Center(child: CircularProgressIndicator()));
              final murid = snap.data!.where((b) => b.kelasId == k.id && b.status != 'rejected' && b.status != 'waiting_payment').toList();
              if (murid.isEmpty) return Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text('Belum ada murid pada kelas ini', style: TextStyle(fontSize: 12, color: Colors.grey[500])));
              return Column(children: murid.map((b) => Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFEEEEEE)))),
                child: Row(children: [
                  Container(width: 32, height: 32, decoration: BoxDecoration(color: const Color(0xFF1565C0).withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.person_rounded, color: Color(0xFF1565C0), size: 16)),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(b.studentNama, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    Text('${b.jadwalDipilih} · ${b.jamDipilih}', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                  ])),
                  if (b.status == 'confirmed')
                    OutlinedButton(
                      onPressed: () => _tandaiSelesaiBooking(b),
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.green), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), minimumSize: Size.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      child: const Text('Tandai Selesai', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.green)))
                  else if (b.status == 'completed')
                    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(20)),
                      child: Text('Selesai', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.grey[600])))
                  else
                    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(20)),
                      child: Text('Menunggu Verifikasi', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.orange[700]))),
                ]))).toList());
            }),
        ])),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(child: OutlinedButton.icon(onPressed: _loading ? null : _edit,
            icon: const Icon(Icons.edit_rounded, size: 17, color: Color(0xFF1565C0)),
            label: const Text('Edit Kelas', style: TextStyle(color: Color(0xFF1565C0))),
            style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF1565C0)), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
          const SizedBox(width: 12),
          Expanded(child: k.isActive
            ? OutlinedButton.icon(onPressed: _loading ? null : _hentikanKelas,
                icon: _loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.red, strokeWidth: 2)) : const Icon(Icons.visibility_off_rounded, size: 17, color: Colors.red),
                label: const Text('Hentikan Kelas', style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))
            : ElevatedButton.icon(onPressed: _loading ? null : _aktifkanKembali,
                icon: _loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.visibility_rounded, size: 18),
                label: const Text('Tampilkan Lagi'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1565C0), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
        ]),
      ])),
    );
  }

  Widget _card({required Widget child}) => Container(width: double.infinity, padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
    child: child);

  Widget _row(IconData icon, String label, String value) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Icon(icon, size: 15, color: const Color(0xFF1565C0)), const SizedBox(width: 8),
    SizedBox(width: 65, child: Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500]))),
    Expanded(child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
  ]);

  Widget _chip(String l) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: const Color(0xFF1565C0).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
    child: Text(l, style: const TextStyle(fontSize: 10, color: Color(0xFF1565C0), fontWeight: FontWeight.w600)));
}