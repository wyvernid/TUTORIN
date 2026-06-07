import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../models/kelas_model.dart';
import '../shared/peta_lokasi_screen.dart';
import 'student_booking_screen.dart';

class StudentDetailKelasScreen extends StatelessWidget {
  final KelasModel kelas;
  const StudentDetailKelasScreen({super.key, required this.kelas});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF5F7FA),
    appBar: AppBar(
      title: const Text('Detail Pembelajaran'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () => Navigator.pop(context))),
    bottomNavigationBar: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: ElevatedButton(
          onPressed: kelas.isFull
              ? null
              : () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => StudentBookingScreen(kelas: kelas))),
          child: Text(
            kelas.isFull ? 'Kelas Penuh' : 'Booking Kelas',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700))))),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(kelas.judul,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          if (kelas.deskripsi.isNotEmpty)
            Text(kelas.deskripsi,
              style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.5)),
          const SizedBox(height: 14),
          _row(Icons.people_rounded,
            '${kelas.kuota} kuota total  ·  ${kelas.sisaSlot} slot tersisa',
            color: kelas.isFull ? Colors.red : Colors.green),
          const SizedBox(height: 6),
          _row(Icons.schedule_rounded, 'Durasi: ${kelas.durasi}'),
          const SizedBox(height: 6),
          _row(Icons.attach_money_rounded, '${kelas.hargaFormatted} / sesi'),
          const SizedBox(height: 6),
          _row(Icons.calendar_today_rounded,
            '${kelas.jadwal.join(', ')}  ·  ${kelas.jamMulai} WIB'),
          const SizedBox(height: 6),
          _row(Icons.wifi_rounded,
            kelas.mode == 'online' ? 'Online'
                : kelas.mode == 'keduanya' ? 'Online & Offline'
                : 'Offline'),
        ])),
        const SizedBox(height: 12),

        _card(title: 'Profil Tutor', child: Row(children: [
          Container(width: 66, height: 66,
            decoration: BoxDecoration(
              color: const Color(0xFF1565C0).withOpacity(0.1),
              shape: BoxShape.circle),
            child: kelas.tutorFotoUrl.isNotEmpty
                ? ClipOval(child: Image.network(kelas.tutorFotoUrl, fit: BoxFit.cover))
                : const Icon(Icons.person_rounded, color: Color(0xFF1565C0), size: 38)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(kelas.tutorNama,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFC107)),
              const SizedBox(width: 3),
              Text('${kelas.rating.toStringAsFixed(1)} (${kelas.jumlahUlasan} ulasan)',
                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ]),
            const SizedBox(height: 6),
            if (kelas.tags.isNotEmpty)
              Wrap(spacing: 4, runSpacing: 4,
                children: kelas.tags.map((t) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1565C0),
                    borderRadius: BorderRadius.circular(20)),
                  child: Text(t, style: const TextStyle(
                    color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)))).toList()),
          ])),
        ])),
        const SizedBox(height: 12),

        if (kelas.mode != 'online')
          _card(title: 'Lokasi', child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (kelas.lokasi.isNotEmpty)
                _row(Icons.location_on_rounded, kelas.lokasi),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => PetaLokasiScreen(
                    initialPosition: LatLng(kelas.latitude, kelas.longitude),
                    judulKelas: kelas.judul))),
                child: Container(
                  height: 120, width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF1565C0).withOpacity(0.2))),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.map_rounded, color: Color(0xFF1565C0), size: 36),
                    const SizedBox(height: 6),
                    const Text('Lihat di Peta OpenStreetMap',
                      style: TextStyle(color: Color(0xFF1565C0), fontSize: 12, fontWeight: FontWeight.w600)),
                  ]))),
            ])),

        const SizedBox(height: 80),
      ])));

  Widget _card({String? title, required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (title != null) ...[
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12)],
      child]));

  Widget _row(IconData icon, String text, {Color? color}) => Row(children: [
    Icon(icon, size: 15, color: color ?? const Color(0xFF1565C0)),
    const SizedBox(width: 8),
    Expanded(child: Text(text,
      style: TextStyle(fontSize: 12, color: color ?? Colors.grey[700]))),
  ]);
}