import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../tutor/tutor_home_screen.dart';
import 'login_screen.dart';

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

  void _daftar() async {
    if (_keahlian.isEmpty) { setState(() => _error = 'Tambahkan minimal 1 keahlian'); return; }
    setState(() { _loading = true; _error = null; });
    try {
      await _auth.register(email: _email.text.trim(), password: _pass.text, nama: _nama.text.trim(),
        role: 'tutor', usia: int.tryParse(_umur.text), keahlian: _keahlian, pengalaman: _pengalaman);
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TutorHomeScreen()));
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
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
          const Text('Keahlian', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Row(children: [
            Expanded(child: TextField(controller: _keahlianCtrl, style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(hintText: 'Tambah keahlian', hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
                filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)))),
            const SizedBox(width: 8),
            GestureDetector(onTap: () { if (_keahlianCtrl.text.trim().isNotEmpty) { setState(() { _keahlian.add(_keahlianCtrl.text.trim()); _keahlianCtrl.clear(); }); }},
              child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.add, color: Color(0xFF1565C0)))),
          ]),
          if (_keahlian.isNotEmpty) ...[const SizedBox(height: 8),
            Wrap(spacing: 6, runSpacing: 4, children: _keahlian.map((k) => Chip(
              label: Text(k, style: const TextStyle(fontSize: 11, color: Colors.white)),
              backgroundColor: Colors.white24, deleteIconColor: Colors.white70, onDeleted: () => setState(() => _keahlian.remove(k)),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap)).toList())],
          const SizedBox(height: 14),
          const Text('Pengalaman', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Row(children: [
            Expanded(child: TextField(controller: _expCtrl, style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(hintText: 'Tambah pengalaman', hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
                filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)))),
            const SizedBox(width: 8),
            GestureDetector(onTap: () { if (_expCtrl.text.trim().isNotEmpty) { setState(() { _pengalaman.add(_expCtrl.text.trim()); _expCtrl.clear(); }); }},
              child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.add, color: Color(0xFF1565C0)))),
          ]),
          if (_error != null) ...[const SizedBox(height: 10), Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 12))],
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