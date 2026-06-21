import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/kelas_model.dart';
import '../../models/booking_model.dart';
import '../../models/user_model.dart';
import '../../services/kelas_service.dart';
import '../../services/auth_service.dart';
import '../shared/ulasan_section.dart';
import '../shared/peta_lokasi_screen.dart';
import '../shared/pdf_viewer_screen.dart';
import 'student_booking_screen.dart';

class StudentDetailKelasScreen extends StatefulWidget {
  final KelasModel kelas;
  final BookingModel? booking;

  const StudentDetailKelasScreen({super.key, required this.kelas, this.booking});

  @override
  State<StudentDetailKelasScreen> createState() => _State();
}

class _State extends State<StudentDetailKelasScreen> {
  final _authService = AuthService();

  // BARU: data tutor (untuk ambil portofolioUrl & cvUrl) — tidak ikut
  // didenormalisasi ke KelasModel, jadi harus diambil terpisah dari users/{tutorId}.
  UserModel? _tutorData;
  bool _loadingTutor = true;

  KelasModel get kelas => widget.kelas;
  BookingModel? get booking => widget.booking;

  @override
  void initState() {
    super.initState();
    _loadTutorData();
  }

  Future<void> _loadTutorData() async {
    try {
      final data = await _authService.getUserData(kelas.tutorId);
      if (mounted) setState(() => _tutorData = data);
    } finally {
      if (mounted) setState(() => _loadingTutor = false);
    }
  }

  void _lihatPdf(String? url, String title) {
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title belum diupload tutor ini')));
      return;
    }
    Navigator.push(context, MaterialPageRoute(
        builder: (_) => PdfViewerScreen(pdfUrl: url, title: title)));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
          title: const Text('Detail Pembelajaran'),
          leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Navigator.pop(context))),
      bottomNavigationBar: booking != null
          ? null
          : SafeArea(
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: ElevatedButton(
                      onPressed: kelas.isFull
                          ? null
                          : () => Navigator.push(context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      StudentBookingScreen(kelas: kelas))),
                      child: Text(
                          kelas.isFull ? 'Kelas Penuh' : 'Booking Kelas',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700))))),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // Tampilkan Sesi info jika diakses dari Kelas Saya
            if (booking != null) ...[
              _card(
                title: 'Sesi Kelas Anda',
                child: Column(
                  children: [
                    _row(Icons.calendar_today_rounded, 'Tanggal: ${booking!.jadwalDipilih}'),
                    const SizedBox(height: 6),
                    _row(Icons.access_time_rounded, 'Jam Sesi: ${booking!.jamDipilih} WIB'),
                    const SizedBox(height: 6),
                    _row(Icons.check_circle_rounded, 'Status Kelas: Terverifikasi Tutor', color: Colors.green),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Card judul & deskripsi kelas
            _card(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
              Text(kelas.judul,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w800)),
              if (kelas.deskripsi.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(kelas.deskripsi,
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        height: 1.5)),
              ],
            ])),
            const SizedBox(height: 12),

            // Card info kelas (kuota, durasi, harga, jadwal, mode)
            _card(
                title: 'Info Kelas',
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
              _row(Icons.people_rounded,
                  '${kelas.kuota} kuota total  ·  ${kelas.sisaSlot} slot tersisa',
                  color: kelas.isFull ? Colors.red : Colors.green),
              const SizedBox(height: 6),
              _row(Icons.schedule_rounded, 'Durasi: ${kelas.durasi}'),
              const SizedBox(height: 6),
              _row(Icons.attach_money_rounded, '${kelas.hargaFormatted} / sesi'),
              const SizedBox(height: 6),
              _row(
                  Icons.calendar_today_rounded,
                  kelas.pakaiJadwalSesi
                      ? '${kelas.jadwalSesi.length} tanggal  ·  ${kelas.totalSesi} sesi tersedia'
                      : '${kelas.jadwal.join(', ')}  ·  ${kelas.jamMulai} WIB'),
              if (kelas.pakaiJadwalSesi) ...[
                const SizedBox(height: 8),
                Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(10)),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: kelas.jadwalSesi
                            .map((j) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 3),
                                child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  Expanded(
                                      flex: 2,
                                      child: Text(j.tanggalFormatted,
                                          style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600))),
                                  Expanded(
                                      flex: 3,
                                      child: Text(
                                          j.jamList
                                              .map((t) => '$t WIB')
                                              .join(', '),
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey[600]))),
                                ])))
                            .toList())),
              ],
              const SizedBox(height: 6),
              _row(
                  Icons.wifi_rounded,
                  kelas.mode == 'online'
                      ? 'Online'
                      : kelas.mode == 'keduanya'
                          ? 'Online & Offline'
                          : 'Offline'),
            ])),
            const SizedBox(height: 12),

            // Link Zoom HANYA muncul jika diakses lewat kelas terverifikasi student
            if (booking != null && kelas.zoomLink != null && kelas.zoomLink!.isNotEmpty) ...[
              _card(
                  title: 'Link Kelas Online',
                  child: _buildZoomLink(context, kelas.zoomLink!)),
              const SizedBox(height: 12),
            ],

            // Card Profil Tutor
            _card(
                title: 'Profil Tutor',
                child: Row(children: [
                  Container(
                      width: 66,
                      height: 66,
                      decoration: BoxDecoration(
                          color: const Color(0xFF1565C0).withOpacity(0.1),
                          shape: BoxShape.circle),
                      child: kelas.tutorFotoUrl.isNotEmpty
                          ? ClipOval(
                              child: Image.network(kelas.tutorFotoUrl,
                                  fit: BoxFit.cover))
                          : const Icon(Icons.person_rounded,
                              color: Color(0xFF1565C0), size: 38)),
                  const SizedBox(width: 14),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                    Text(kelas.tutorNama,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.star_rounded,
                          size: 14, color: Color(0xFFFFC107)),
                      const SizedBox(width: 3),
                      Text(
                          '${kelas.rating.toStringAsFixed(1)} (${kelas.jumlahUlasan} ulasan)',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey[600])),
                    ]),
                    const SizedBox(height: 6),
                    if (kelas.tags.isNotEmpty)
                      Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: kelas.tags
                              .map((t) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                      color: const Color(0xFF1565C0),
                                      borderRadius:
                                          BorderRadius.circular(20)),
                                  child: Text(t,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600))))
                              .toList()),
                  ])),
                ])),
            const SizedBox(height: 12),

            // BARU: Card Portofolio Tutor
            _card(
                title: 'Portofolio Tutor',
                child: _loadingTutor
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Center(
                            child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2))))
                    : _dokumenRow(
                        Icons.folder_open_outlined,
                        'Portofolio',
                        _tutorData?.portofolioUrl,
                        () => _lihatPdf(
                            _tutorData?.portofolioUrl, 'Portofolio Tutor'))),
            const SizedBox(height: 12),

            // Card Lokasi (Map)
            if (kelas.mode != 'online')
              _card(
                  title: 'Lokasi',
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    if (kelas.lokasi.isNotEmpty)
                      _row(Icons.location_on_rounded, kelas.lokasi),
                    const SizedBox(height: 10),
                    GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => PetaLokasiScreen(
                                    initialPosition: LatLng(
                                        kelas.latitude, kelas.longitude),
                                    judulKelas: kelas.judul))),
                        child: Container(
                            height: 120,
                            width: double.infinity,
                            decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: const Color(0xFF1565C0)
                                        .withOpacity(0.2))),
                            child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                              const Icon(Icons.map_rounded,
                                  color: Color(0xFF1565C0), size: 36),
                              const SizedBox(height: 6),
                              const Text(
                                  'Lihat di Peta OpenStreetMap',
                                  style: TextStyle(
                                      color: Color(0xFF1565C0),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600)),
                            ]))),
                  ])),
            if (kelas.mode != 'online') const SizedBox(height: 12),

            UlasanSection(
                kelasId: kelas.id,
                ratingAvg: kelas.rating,
                jumlahUlasan: kelas.jumlahUlasan,
                service: KelasService()),

            const SizedBox(height: 80),
          ])));

  Widget _buildZoomLink(BuildContext context, String link) => InkWell(
      onTap: () async {
        final uri = Uri.tryParse(link);
        if (uri != null && await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          if (context.mounted)
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tidak bisa membuka link')));
        }
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: const Color(0xFF1565C0).withOpacity(0.3))),
          child: Row(children: [
            Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                    color: const Color(0xFF1565C0),
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.video_camera_front_rounded,
                    color: Colors.white, size: 20)),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  const Text('Buka Link Zoom / Meeting',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1565C0))),
                  Text(link,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                ])),
            Icon(Icons.open_in_new_rounded, size: 16, color: Colors.grey[400]),
          ])));

  Widget _card({String? title, required Widget child}) => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)
          ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (title != null) ...[
          Text(title,
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12)
        ],
        child,
      ]));

  Widget _row(IconData icon, String text, {Color? color}) =>
      Row(children: [
        Icon(icon, size: 15, color: color ?? const Color(0xFF1565C0)),
        const SizedBox(width: 8),
        Expanded(
            child: Text(text,
                style: TextStyle(
                    fontSize: 12, color: color ?? Colors.grey[700]))),
      ]);

  // BARU: baris dokumen (Portofolio/CV) dengan status tersedia/belum + tombol Lihat.
  Widget _dokumenRow(IconData icon, String label, String? url, VoidCallback onTap) =>
      Row(children: [
        Icon(icon, size: 20, color: const Color(0xFF1565C0)),
        const SizedBox(width: 10),
        Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600)),
              Text(
                  url != null && url.isNotEmpty ? 'Tersedia' : 'Belum diupload',
                  style: TextStyle(
                      fontSize: 11,
                      color: url != null && url.isNotEmpty
                          ? Colors.green
                          : Colors.grey[400])),
            ])),
        TextButton(onPressed: onTap, child: const Text('Lihat')),
      ]);
}