import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import '../../models/user_model.dart';
import '../auth/login_screen.dart';

class StudentProfilScreen extends StatefulWidget {
  const StudentProfilScreen({super.key});
  @override
  State<StudentProfilScreen> createState() => _State();
}

class _State extends State<StudentProfilScreen> {
  final _auth = AuthService(); final _storage = StorageService();
  UserModel? _user; bool _loadingFoto = false;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final u = await _auth.getUserData(FirebaseAuth.instance.currentUser!.uid);
    if (mounted) setState(() => _user = u);
  }

  Future<void> _updateFoto(ImageSource src) async {
    setState(() => _loadingFoto = true);
    try {
      final f = src == ImageSource.camera ? await _storage.ambilDariKamera() : await _storage.ambilDariGaleri();
      if (f == null) return;
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final url = await _storage.uploadFotoProfil(uid, f);
      await _auth.updateProfil(uid, {'fotoUrl': url});
      await _load();
    } finally { if (mounted) setState(() => _loadingFoto = false); }
  }

  void _showFotoOptions() => showModalBottomSheet(context: context, builder: (_) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 40, height: 4, margin: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
    const Text('Foto Profil', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
    const SizedBox(height: 16),
    Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      _fotoOpt(Icons.camera_alt_rounded, 'Kamera', () { Navigator.pop(context); _updateFoto(ImageSource.camera); }),
      _fotoOpt(Icons.photo_library_rounded, 'Galeri', () { Navigator.pop(context); _updateFoto(ImageSource.gallery); }),
    ]),
    const SizedBox(height: 16),
  ])));

  Widget _fotoOpt(IconData icon, String label, VoidCallback onTap) => GestureDetector(onTap: onTap,
    child: Column(children: [Container(width: 60, height: 60, decoration: BoxDecoration(color: const Color(0xFFF5F7FA), borderRadius: BorderRadius.circular(16)), child: Icon(icon, color: const Color(0xFF1565C0), size: 28)), const SizedBox(height: 8), Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700]))]));

  void _showEditSheet() {
    final n = TextEditingController(text: _user?.nama), t = TextEditingController(text: _user?.noTelepon), s = TextEditingController(text: _user?.sosialMedia);
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Edit Profil', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          TextField(controller: n, decoration: const InputDecoration(labelText: 'Nama Lengkap', prefixIcon: Icon(Icons.person_outline))),
          const SizedBox(height: 10),
          TextField(controller: t, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Nomor Telepon', prefixIcon: Icon(Icons.phone_outlined))),
          const SizedBox(height: 10),
          TextField(controller: s, decoration: const InputDecoration(labelText: 'Sosial Media', prefixIcon: Icon(Icons.link_rounded))),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () async {
            await _auth.updateProfil(FirebaseAuth.instance.currentUser!.uid, {'nama': n.text.trim(), 'noTelepon': t.text.trim(), 'sosialMedia': s.text.trim()});
            await _load(); if (mounted) Navigator.pop(context);
          }, child: const Text('Simpan'))),
        ]))));
  }

  @override
  Widget build(BuildContext context) {
    final u = _user;
    return Scaffold(backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(title: const Text('Profil'), automaticallyImplyLeading: false, actions: [IconButton(icon: const Icon(Icons.edit_rounded), onPressed: _showEditSheet)]),
      body: u == null ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(child: Column(children: [
        Container(width: double.infinity, padding: const EdgeInsets.fromLTRB(20,28,20,24),
          decoration: const BoxDecoration(color: Color(0xFF1565C0), borderRadius: BorderRadius.vertical(bottom: Radius.circular(28))),
          child: Column(children: [
            GestureDetector(onTap: _showFotoOptions, child: Stack(children: [
              _loadingFoto ? const SizedBox(width: 90, height: 90, child: Center(child: CircularProgressIndicator(color: Colors.white)))
                  : Container(width: 90, height: 90, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3)),
                      child: u.fotoUrl != null ? ClipOval(child: Image.network(u.fotoUrl!, fit: BoxFit.cover))
                          : const CircleAvatar(backgroundColor: Colors.white24, child: Icon(Icons.person_rounded, color: Colors.white, size: 52))),
              Positioned(right: 0, bottom: 0, child: Container(width: 28, height: 28, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const Icon(Icons.edit_rounded, color: Color(0xFF1565C0), size: 15))),
            ])),
            const SizedBox(height: 12),
            Text(u.nama, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(u.email, style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 13)),
            const SizedBox(height: 8),
            Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
              child: const Text('Student', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600))),
          ])),
        Padding(padding: const EdgeInsets.fromLTRB(16,16,16,0), child: Row(children: [
          _stat('${u.totalKelasSelesai}', 'Kelas Selesai', Icons.check_circle_rounded, Colors.green),
          const SizedBox(width: 10),
          _stat(u.usia != null ? '${u.usia} Thn' : '-', 'Usia', Icons.cake_outlined, const Color(0xFF1565C0)),
          const SizedBox(width: 10),
          _stat(u.rating > 0 ? u.rating.toStringAsFixed(1) : '-', 'Rating', Icons.star_rounded, Colors.amber),
        ])),
        const SizedBox(height: 12),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Container(padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Informasi Akun', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            _info(Icons.person_outline, 'Nama', u.nama), const Divider(height: 20),
            _info(Icons.email_outlined, 'Email', u.email), const Divider(height: 20),
            _info(Icons.phone_outlined, 'Telepon', u.noTelepon ?? 'Belum diisi'), const Divider(height: 20),
            _info(Icons.share_outlined, 'Sosial Media', u.sosialMedia ?? 'Belum diisi'),
          ]))),
        const SizedBox(height: 12),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
          child: Column(children: [
            _menu(Icons.history_rounded, 'Riwayat Booking', () {}),
            const Divider(height: 0, indent: 56),
            _menu(Icons.logout_rounded, 'Keluar', () async { await _auth.logout(); if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())); }, color: Colors.red),
          ]))),
        const SizedBox(height: 30),
      ])));
  }

  Widget _stat(String v, String l, IconData icon, Color c) => Expanded(child: Container(padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
    child: Column(children: [Icon(icon, color: c, size: 20), const SizedBox(height: 6), Text(v, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)), Text(l, textAlign: TextAlign.center, style: TextStyle(fontSize: 9, color: Colors.grey[500]))])));

  Widget _info(IconData icon, String label, String value) => Row(children: [
    Icon(icon, size: 18, color: const Color(0xFF1565C0)), const SizedBox(width: 12),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500])), const SizedBox(height: 2), Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))])),
  ]);

  Widget _menu(IconData icon, String label, VoidCallback onTap, {Color? color}) {
    final c = color ?? const Color(0xFF455A64);
    return ListTile(onTap: onTap,
      leading: Container(width: 36, height: 36, decoration: BoxDecoration(color: (color ?? const Color(0xFF1565C0)).withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: c, size: 18)),
      title: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c)),
      trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey[300], size: 20));
  }
}