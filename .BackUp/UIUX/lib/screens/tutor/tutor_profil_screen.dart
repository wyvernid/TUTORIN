import 'package:flutter/material.dart';
import '../auth/login_screen.dart';

class TutorProfilScreen extends StatefulWidget {
  const TutorProfilScreen({super.key});

  @override
  State<TutorProfilScreen> createState() => _TutorProfilScreenState();
}

class _TutorProfilScreenState extends State<TutorProfilScreen> {
  bool _showPhotoOptions = false;

  final List<String> _skills = ['Machine Learning', 'AI', 'Python', 'Deep Learning', 'NLP'];
  final List<String> _experiences = ['S1 Fasilkom Unej', 'S2 Harvard University', 'Proyek ML Space X', 'Proyek Nuklir Korut'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Profil Tutor'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(icon: const Icon(Icons.edit_rounded), onPressed: () => _showEditSheet(context)),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(),
                _buildStats(),
                const SizedBox(height: 12),
                _buildSkills(),
                const SizedBox(height: 12),
                _buildExperiences(),
                const SizedBox(height: 12),
                _buildMenu(),
                const SizedBox(height: 30),
              ],
            ),
          ),
          if (_showPhotoOptions) _buildPhotoOverlay(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF1565C0),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _showPhotoOptions = true),
            child: Stack(
              children: [
                Container(
                  width: 90, height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    color: Colors.white.withOpacity(0.2),
                  ),
                  child: const Icon(Icons.person_rounded, color: Colors.white, size: 52),
                ),
                Positioned(right: 0, bottom: 0,
                  child: Container(
                    width: 28, height: 28,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.edit_rounded, color: Color(0xFF1565C0), size: 15),
                  )),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text('Bintang Ivanna Cholida',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text('bintang@example.com', style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 13)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Tutor', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.3), borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                    const Text('Terverifikasi', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          _statCard('48', 'Total Murid', Icons.people_rounded, const Color(0xFF1565C0)),
          const SizedBox(width: 10),
          _statCard('Rp2.1jt', 'Total Pendapatan', Icons.account_balance_wallet_rounded, Colors.green),
          const SizedBox(width: 10),
          _statCard('4.8', 'Rating', Icons.star_rounded, Colors.amber),
        ],
      ),
    );
  }

  Widget _statCard(String v, String l, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
        child: Column(children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(v, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
          Text(l, textAlign: TextAlign.center, style: TextStyle(fontSize: 9, color: Colors.grey[500])),
        ]),
      ),
    );
  }

  Widget _buildSkills() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Keahlian', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6, runSpacing: 6,
              children: _skills.map((s) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF1565C0), borderRadius: BorderRadius.circular(20),
                ),
                child: Text(s, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExperiences() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pengalaman', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            ..._experiences.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const Icon(Icons.fiber_manual_record, size: 8, color: Color(0xFF1565C0)),
                  const SizedBox(width: 8),
                  Text(e, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildMenu() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
        child: Column(
          children: [
            _menuItem(Icons.upload_file_rounded, 'Upload Portofolio', () {}),
            const Divider(height: 0, indent: 56),
            _menuItem(Icons.history_rounded, 'Riwayat Pembayaran', () {}),
            const Divider(height: 0, indent: 56),
            _menuItem(Icons.notifications_outlined, 'Notifikasi', () {}),
            const Divider(height: 0, indent: 56),
            _menuItem(Icons.logout_rounded, 'Keluar', () => Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const LoginScreen())), color: Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(IconData icon, String label, VoidCallback onTap, {Color? color}) {
    final c = color ?? const Color(0xFF455A64);
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(color: (color ?? const Color(0xFF1565C0)).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: c, size: 18),
      ),
      title: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c)),
      trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey[300], size: 20),
    );
  }

  Widget _buildPhotoOverlay() {
    return GestureDetector(
      onTap: () => setState(() => _showPhotoOptions = false),
      child: Container(
        color: Colors.black45,
        alignment: Alignment.bottomCenter,
        child: GestureDetector(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 20),
                const Text('Foto Profil', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 20),
                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                  _photoOption(Icons.camera_alt_rounded, 'Open Kamera', () => setState(() => _showPhotoOptions = false)),
                  _photoOption(Icons.photo_library_rounded, 'Pilih dari Galeri', () => setState(() => _showPhotoOptions = false)),
                ]),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _photoOption(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Container(
          width: 60, height: 60,
          decoration: BoxDecoration(color: const Color(0xFFF5F7FA), borderRadius: BorderRadius.circular(16)),
          child: Icon(icon, color: const Color(0xFF1565C0), size: 28),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
      ]),
    );
  }

  void _showEditSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Edit Profil', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              const TextField(decoration: InputDecoration(labelText: 'Nama Lengkap', prefixIcon: Icon(Icons.person_outline))),
              const SizedBox(height: 10),
              const TextField(keyboardType: TextInputType.phone, decoration: InputDecoration(labelText: 'Nomor Telepon', prefixIcon: Icon(Icons.phone_outlined))),
              const SizedBox(height: 10),
              const TextField(maxLines: 2, decoration: InputDecoration(labelText: 'Bio Singkat', prefixIcon: Icon(Icons.info_outline))),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Simpan Perubahan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
