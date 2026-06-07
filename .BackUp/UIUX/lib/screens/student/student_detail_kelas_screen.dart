import 'package:flutter/material.dart';
import 'student_booking_screen.dart';

class StudentDetailKelasScreen extends StatelessWidget {
  final Map<String, dynamic> data;
  const StudentDetailKelasScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Detail Pembelajaran'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => StudentBookingScreen(data: data)),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Booking Kelas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _section(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['title'],
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Pembelajaran ini membahas terkait ${data['title']}. Akan diajarkan tata cara penggunaan algoritma dalam membangun sebuah sistem. Benefit yang didapat diantaranya materi pembelajaran, contoh source code, dan file instalasi.',
                    style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.5),
                  ),
                  const SizedBox(height: 12),
                  _infoRow(Icons.people_rounded, '${data['slots']} kuota total · ${data['slots'] - data['slotsUsed']} slot tersisa'),
                  const SizedBox(height: 6),
                  _infoRow(Icons.schedule_rounded, 'Durasi: ${data['duration']}'),
                  const SizedBox(height: 6),
                  _infoRow(Icons.attach_money_rounded, 'Rp${_formatPrice(data['price'])} / pertemuan'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _section(
              title: 'Jadwal Pembelajaran',
              child: Column(
                children: [
                  _infoRow(Icons.calendar_today_rounded, 'Tersedia setiap: ${(data['schedules'] as List).join(', ')}'),
                  const SizedBox(height: 6),
                  _infoRow(Icons.access_time_rounded, 'Jam: ${data['time']} WIB'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1565C0).withOpacity(0.06),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF1565C0).withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Color(0xFF1565C0), size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Kamu bisa memilih tanggal spesifik saat booking. Kuota langsung terkonfirmasi otomatis setelah pembayaran diverifikasi.',
                            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _section(
              title: 'Profil Tutor',
              child: Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1565C0).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_rounded, color: Color(0xFF1565C0), size: 40),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['tutor'],
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFC107)),
                            const SizedBox(width: 2),
                            Text('${data['rating']} (${data['reviews']} ulasan)',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: (data['tags'] as List)
                              .map((tag) => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1565C0),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(tag,
                                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _section(
              title: 'Pengalaman',
              child: Column(
                children: [
                  _expItem('S1 Fasilkom Unej'),
                  _expItem('S2 Harvard University'),
                  _expItem('Membuat Proyek Machine Learning Space X'),
                  _expItem('Membuat Proyek Nuklir Korut'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _section(
              title: 'Kontak & Sosial Media',
              child: Column(
                children: [
                  _contactRow(Icons.language_rounded, 'Portfolio / Website'),
                  _contactRow(Icons.work_rounded, 'LinkedIn'),
                  _contactRow(Icons.photo_camera_rounded, 'Instagram'),
                  _contactRow(Icons.code_rounded, 'GitHub'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _section(
              title: 'Lokasi',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoRow(Icons.location_on_rounded, data['address']),
                  const SizedBox(height: 10),
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.map_rounded, color: Colors.grey[400], size: 40),
                          const SizedBox(height: 4),
                          Text('Google Maps', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _section({String? title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF1565C0)),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: TextStyle(fontSize: 13, color: Colors.grey[700]))),
      ],
    );
  }

  Widget _expItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(Icons.fiber_manual_record, size: 8, color: Color(0xFF1565C0)),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(fontSize: 13, color: Colors.grey[700]))),
        ],
      ),
    );
  }

  Widget _contactRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF1565C0).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: const Color(0xFF1565C0)),
          ),
          const SizedBox(width: 10),
          Text(text, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
        ],
      ),
    );
  }

  String _formatPrice(int price) {
    if (price >= 1000) return '${(price / 1000).toStringAsFixed(0)}.000';
    return price.toString();
  }
}
