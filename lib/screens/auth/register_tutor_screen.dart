import 'dart:io';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import 'login_screen.dart';
import 'verify_email_screen.dart';

class RegisterTutorScreen extends StatefulWidget {
  const RegisterTutorScreen({super.key});
  @override
  State<RegisterTutorScreen> createState() => _State();
}

class _State extends State<RegisterTutorScreen> {
  final _email = TextEditingController(), _nama = TextEditingController();
  final _umur = TextEditingController(), _pass = TextEditingController();
  final _keahlianCtrl = TextEditingController(), _expCtrl = TextEditingController();
  bool _op = true, _loading = false;
  String? _error;
  final List<String> _keahlian = [], _pengalaman = [];
  final _auth = AuthService();
  final _storage = StorageService();

  File? _cvFile;
  File? _portofolioFile;
  bool _pickingCv = false, _pickingPortofolio = false;

  Future<void> _pilihCv() async {
    setState(() => _pickingCv = true);
    final file = await _storage.ambilFilePdf();
    setState(() {
      _pickingCv = false;
      if (file != null) _cvFile = file;
    });
  }

  Future<void> _pilihPortofolio() async {
    setState(() => _pickingPortofolio = true);
    final file = await _storage.ambilFilePdf();
    setState(() {
      _pickingPortofolio = false;
      if (file != null) _portofolioFile = file;
    });
  }

  void _daftar() async {
    if (_keahlian.isEmpty) { setState(() => _error = 'Tambahkan minimal 1 keahlian'); return; }
    if (_pengalaman.isEmpty) { setState(() => _error = 'Tambahkan minimal 1 pengalaman'); return; }
    if (_cvFile == null) { setState(() => _error = 'CV (PDF) wajib diupload'); return; }
    if (_portofolioFile == null) { setState(() => _error = 'Portofolio (PDF) wajib diupload'); return; }

    setState(() { _loading = true; _error = null; });
    try {
      final user = await _auth.register(email: _email.text.trim(), password: _pass.text, nama: _nama.text.trim(),
        role: 'tutor', usia: int.tryParse(_umur.text), keahlian: _keahlian, pengalaman: _pengalaman);

      // Upload CV & Portofolio setelah akun & dokumen Firestore-nya dibuat
      // (butuh uid dari hasil register), lalu simpan URL-nya.
      final uid = user!.uid;
      final cvUrl = await _storage.uploadCvPdf(
          uid, 'cv_${DateTime.now().millisecondsSinceEpoch}.pdf', _cvFile!);
      final portofolioUrl = await _storage.uploadPortofolioPdf(
          uid, 'portofolio_${DateTime.now().millisecondsSinceEpoch}.pdf', _portofolioFile!);
      await _auth.updateProfil(uid, {'cvUrl': cvUrl, 'portofolioUrl': portofolioUrl});

      if (!mounted) return;
      // AuthService.register() sudah mengirim email verifikasi & TIDAK
      // logout user. Tutor baru harus verifikasi email DULU sebelum bisa
      // melihat status verifikasi admin (TutorPendingScreen), jadi arahkan
      // ke VerifyEmailScreen, bukan langsung ke TutorPendingScreen.
      Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => VerifyEmailScreen(email: _email.text.trim())));
    } catch (e) {
      setState(() { _error = 'Gagal mendaftar: $e'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(backgroundColor: Colors.white,
    body: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.symmetric(horizontal: 24), child: Column(children: [
      const SizedBox(height: 40),
      const Text('REGISTER\nTUTOR', textAlign: TextAlign.center,
        style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, height: 1.1)),
      const SizedBox(height: 24),
      Container(padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: const Color(0xFF1565C0), borderRadius: BorderRadius.circular(20)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _wf('Email', _email, hint: 'tutor@example.com', icon: Icons.email_outlined),
          const SizedBox(height: 10),
          _wf('Nama Lengkap', _nama, icon: Icons.person_outline),
          const SizedBox(height: 10),
          _wf('Umur', _umur, icon: Icons.cake_outlined, type: TextInputType.number),
          const SizedBox(height: 10),
          _wf('Password', _pass, icon: Icons.lock_outline, obscure: _op, toggle: () => setState(() => _op = !_op)),

          const SizedBox(height: 14),
          const Text('Keahlian *', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text('Boleh diisi lebih dari satu', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11)),
          const SizedBox(height: 6),
          Row(children: [
            Expanded(child: TextField(controller: _keahlianCtrl, style: const TextStyle(fontSize: 13),
              onSubmitted: (_) => _tambahKeahlian(),
              decoration: InputDecoration(hintText: 'Contoh: Matematika', hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
                filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)))),
            const SizedBox(width: 8),
            GestureDetector(onTap: _tambahKeahlian,
              child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.add, color: Color(0xFF1565C0)))),
          ]),
          if (_keahlian.isNotEmpty) ...[const SizedBox(height: 10),
            Wrap(spacing: 6, runSpacing: 6, children: _keahlian.map((k) => _chip(k, () => setState(() => _keahlian.remove(k)))).toList())],

          const SizedBox(height: 18),
          const Text('Pengalaman *', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text('Boleh diisi lebih dari satu', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11)),
          const SizedBox(height: 6),
          Row(children: [
            Expanded(child: TextField(controller: _expCtrl, style: const TextStyle(fontSize: 13),
              onSubmitted: (_) => _tambahPengalaman(),
              decoration: InputDecoration(hintText: 'Contoh: Mengajar privat 2 tahun', hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
                filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)))),
            const SizedBox(width: 8),
            GestureDetector(onTap: _tambahPengalaman,
              child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.add, color: Color(0xFF1565C0)))),
          ]),
          if (_pengalaman.isNotEmpty) ...[const SizedBox(height: 10),
            Wrap(spacing: 6, runSpacing: 6, children: _pengalaman.map((p) => _chip(p, () => setState(() => _pengalaman.remove(p)))).toList())],

          const SizedBox(height: 18),
          const Text('CV (PDF) *', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text('Wajib diupload, jadi pertimbangan admin saat verifikasi', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11)),
          const SizedBox(height: 6),
          _filePickerBox(
            file: _cvFile,
            loading: _pickingCv,
            placeholder: 'Pilih file CV (.pdf)',
            onPick: _pilihCv,
            onClear: () => setState(() => _cvFile = null),
          ),

          const SizedBox(height: 18),
          const Text('Portofolio (PDF) *', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text('Wajib diupload, jadi pertimbangan admin saat verifikasi', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11)),
          const SizedBox(height: 6),
          _filePickerBox(
            file: _portofolioFile,
            loading: _pickingPortofolio,
            placeholder: 'Pilih file Portofolio (.pdf)',
            onPick: _pilihPortofolio,
            onClear: () => setState(() => _portofolioFile = null),
          ),

          if (_error != null) ...[const SizedBox(height: 14), Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)),
            child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 12)))],

          const SizedBox(height: 20),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _loading ? null : _daftar,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF1565C0),
              padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('DAFTAR SEBAGAI TUTOR', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 1)))),
          const SizedBox(height: 10),
          Center(child: GestureDetector(onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
            child: Text('Sudah punya akun? Login', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12, decoration: TextDecoration.underline, decorationColor: Colors.white)))),
        ])),
      const SizedBox(height: 30),
    ]))));

  void _tambahKeahlian() {
    if (_keahlianCtrl.text.trim().isNotEmpty) {
      setState(() { _keahlian.add(_keahlianCtrl.text.trim()); _keahlianCtrl.clear(); });
    }
  }

  void _tambahPengalaman() {
    if (_expCtrl.text.trim().isNotEmpty) {
      setState(() { _pengalaman.add(_expCtrl.text.trim()); _expCtrl.clear(); });
    }
  }

  // Chip custom — background putih solid + teks biru tua, dijamin kontras
  // dan kelihatan di atas card biru (beda dengan Chip() Material3 bawaan
  // yang sebelumnya bikin teks putih nyaris tak kelihatan di atas white24).
  Widget _chip(String label, VoidCallback onDelete) => Container(
    padding: const EdgeInsets.only(left: 10, right: 4, top: 5, bottom: 5),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 180),
        child: Text(label, overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 11.5, color: Color(0xFF1565C0), fontWeight: FontWeight.w600)),
      ),
      const SizedBox(width: 2),
      GestureDetector(onTap: onDelete,
        child: const Padding(padding: EdgeInsets.all(3),
          child: Icon(Icons.close_rounded, size: 14, color: Color(0xFF1565C0)))),
    ]),
  );

  Widget _filePickerBox({
    required File? file,
    required bool loading,
    required String placeholder,
    required VoidCallback onPick,
    required VoidCallback onClear,
  }) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
    child: Row(children: [
      Icon(Icons.picture_as_pdf_rounded, color: file != null ? Colors.red[400] : Colors.grey[400], size: 20),
      const SizedBox(width: 10),
      Expanded(child: Text(
        file != null ? file.path.split('/').last : placeholder,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 12.5, color: file != null ? Colors.black87 : Colors.grey[400],
          fontWeight: file != null ? FontWeight.w600 : FontWeight.normal),
      )),
      if (loading)
        const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
      else if (file != null)
        GestureDetector(onTap: onClear, child: Icon(Icons.close_rounded, size: 18, color: Colors.grey[500]))
      else
        GestureDetector(onTap: onPick,
          child: const Text('Pilih', style: TextStyle(fontSize: 12, color: Color(0xFF1565C0), fontWeight: FontWeight.w700))),
    ]),
  );

  Widget _wf(String label, TextEditingController ctrl, {String? hint, IconData? icon, bool obscure = false, VoidCallback? toggle, TextInputType? type}) =>
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
      const SizedBox(height: 5),
      TextField(controller: ctrl, obscureText: obscure, keyboardType: type, style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
          filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          prefixIcon: icon != null ? Icon(icon, color: const Color(0xFF1565C0), size: 18) : null,
          suffixIcon: toggle != null ? IconButton(icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey[500], size: 18), onPressed: toggle) : null)),
    ]);
}