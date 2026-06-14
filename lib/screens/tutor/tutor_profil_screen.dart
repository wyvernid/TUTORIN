import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import '../../models/user_model.dart';
import '../auth/login_screen.dart';

class TutorProfilScreen extends StatefulWidget {
  const TutorProfilScreen({super.key});
  @override
  State<TutorProfilScreen> createState() => _State();
}

class _State extends State<TutorProfilScreen> {
  final _auth = AuthService(); final _storage = StorageService();
  UserModel? _user; bool _loadingFoto = false;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async { final u = await _auth.getUserData(FirebaseAuth.instance.currentUser!.uid); if (mounted) setState(() => _user = u); }

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

  @override
  Widget build(BuildContext context) {
    final u = _user;
    return Scaffold(backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(title: const Text('Profil Tutor'), automaticallyImplyLeading: false, actions: [IconButton(icon: const Icon(Icons.edit_rounded), onPressed: () => _showEdit())]),
      body: u == null ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(child: Column(children: [
        Container(width: double.infinity, padding: const EdgeInsets.fromLTRB(20,28,20,24),
          decoration: const BoxDecoration(color: Color(0xFF1565C0), borderRadius: BorderRadius.vertical(bottom: Radius.circular(28))),
          child: Column(children: [
            GestureDetector(onTap: () => _showFotoOptions(),
              child: Stack(children: [
                _loadingFoto ? const SizedBox(width: 88, height: 88, child: Center(child: CircularProgressIndicator(color: Colors.white)))
                    : Container(width: 88, height: 88, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3)),
                        child: u.fotoUrl != null ? ClipOval(child: Image.network(u.fotoUrl!, fit: BoxFit.cover)) : const CircleAvatar(backgroundColor: Colors.white24, child: Icon(Icons.person_rounded, color: Colors.white, size: 50))),
                Positioned(right: 0, bottom: 0, child: Container(width: 26, height: 26, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const Icon(Icons.edit_rounded, color: Color(0xFF1565C0), size: 13))),
              ])),
            const SizedBox(height: 10),
            Text(u.nama, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
            Text(u.email, style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 12)),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)), child: const Text('Tutor', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600))),
              const SizedBox(width: 8),
              if (u.isVerified) Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: Colors.green.withOpacity(0.3), borderRadius: BorderRadius.circular(20)),
                child: Row(children: [Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle)), const SizedBox(width: 4), const Text('Terverifikasi', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600))])),
              if (!u.isVerified) Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: Colors.orange.withOpacity(0.3), borderRadius: BorderRadius.circular(20)),
                child: const Text('Menunggu Verifikasi', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600))),
            ]),
          ])),
        Padding(padding: const EdgeInsets.fromLTRB(16,14,16,0), child: Row(children: [
          _stat('${u.totalMurid}', 'Murid', Icons.people_rounded, const Color(0xFF1565C0)),
          const SizedBox(width: 10),
          _stat(u.rating > 0 ? u.rating.toStringAsFixed(1) : '-', 'Rating', Icons.star_rounded, Colors.amber),
        ])),
        const SizedBox(height: 12),
        if (u.keahlian.isNotEmpty) Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 5)]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Keahlian', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)), const SizedBox(height: 8),
            Wrap(spacing: 6, runSpacing: 6, children: u.keahlian.map((k) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: const Color(0xFF1565C0), borderRadius: BorderRadius.circular(20)), child: Text(k, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)))).toList())]))),
        const SizedBox(height: 12),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 5)]),
          child: Column(children: [
            _menu(Icons.upload_file_rounded, 'Upload Portofolio', () {}),
            const Divider(height: 0, indent: 52),
            _menu(Icons.history_rounded, 'Riwayat Pembayaran', () {}),
            const Divider(height: 0, indent: 52),
            _menu(Icons.logout_rounded, 'Keluar', () async { await _auth.logout(); if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())); }, color: Colors.red),
          ]))),
        const SizedBox(height: 30),
      ])));
  }

  Widget _stat(String v, String l, IconData icon, Color c) => Expanded(child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 5)]),
    child: Row(children: [Container(width: 36, height: 36, decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: c, size: 18)), const SizedBox(width: 10), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(v, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)), Text(l, style: TextStyle(fontSize: 10, color: Colors.grey[500]))])])));

  Widget _menu(IconData icon, String label, VoidCallback onTap, {Color? color}) {
    final c = color ?? const Color(0xFF455A64);
    return ListTile(onTap: onTap, leading: Container(width: 34, height: 34, decoration: BoxDecoration(color: (color ?? const Color(0xFF1565C0)).withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: c, size: 17)),
      title: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: c)), trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey[300], size: 18));
  }

  void _showFotoOptions() => showModalBottomSheet(context: context, builder: (_) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 40, height: 4, margin: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
    const Text('Foto Profil', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)), const SizedBox(height: 14),
    Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      _fotoOpt(Icons.camera_alt_rounded, 'Kamera', () { Navigator.pop(context); _updateFoto(ImageSource.camera); }),
      _fotoOpt(Icons.photo_library_rounded, 'Galeri', () { Navigator.pop(context); _updateFoto(ImageSource.gallery); }),
    ]), const SizedBox(height: 14)])));

  Widget _fotoOpt(IconData icon, String label, VoidCallback onTap) => GestureDetector(onTap: onTap, child: Column(children: [Container(width: 56, height: 56, decoration: BoxDecoration(color: const Color(0xFFF5F7FA), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: const Color(0xFF1565C0), size: 26)), const SizedBox(height: 6), Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[700]))]));

  void _showEdit() {
    final n = TextEditingController(text: _user?.nama), t = TextEditingController(text: _user?.noTelepon);
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom), child: Container(padding: const EdgeInsets.all(22), decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))), child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Text('Edit Profil', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)), const SizedBox(height: 14),
      TextField(controller: n, decoration: const InputDecoration(labelText: 'Nama Lengkap', prefixIcon: Icon(Icons.person_outline))), const SizedBox(height: 10),
      TextField(controller: t, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Nomor Telepon', prefixIcon: Icon(Icons.phone_outlined))), const SizedBox(height: 16),
      SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () async {
        await _auth.updateProfil(FirebaseAuth.instance.currentUser!.uid, {'nama': n.text.trim(), 'noTelepon': t.text.trim()});
        await _load(); if (mounted) Navigator.pop(context);
      }, child: const Text('Simpan'))),
    ]))));
  }
}