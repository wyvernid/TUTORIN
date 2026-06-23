import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'login_screen.dart';
import 'verify_email_screen.dart';

class RegisterStudentScreen extends StatefulWidget {
  const RegisterStudentScreen({super.key});
  @override
  State<RegisterStudentScreen> createState() => _State();
}

class _State extends State<RegisterStudentScreen> {
  final _email   = TextEditingController();
  final _nama    = TextEditingController();
  final _umur    = TextEditingController();
  final _pass    = TextEditingController();
  final _confirm = TextEditingController();
  bool    _op = true, _oc = true, _loading = false;
  String? _error;
  final   _auth = AuthService();

  void _daftar() async {
    // Validasi field kosong
    if (_email.text.trim().isEmpty || _nama.text.trim().isEmpty ||
        _pass.text.isEmpty || _confirm.text.isEmpty) {
      setState(() => _error = 'Semua field wajib diisi');
      return;
    }
    if (_pass.text.length < 6) {
      setState(() => _error = 'Password minimal 6 karakter');
      return;
    }
    if (_pass.text != _confirm.text) {
      setState(() => _error = 'Password tidak sama');
      return;
    }

    setState(() { _loading = true; _error = null; });
    try {
      await _auth.register(
        email:    _email.text.trim(),
        password: _pass.text,
        nama:     _nama.text.trim(),
        role:     'student',
        usia:     int.tryParse(_umur.text),
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => VerifyEmailScreen(email: _email.text.trim())),
      );
    } catch (e) {
      String msg = e.toString();
      if (msg.contains('email-already-in-use')) {
        msg = 'Email sudah terdaftar, coba login';
      } else if (msg.contains('invalid-email')) {
        msg = 'Format email tidak valid';
      } else if (msg.contains('weak-password')) {
        msg = 'Password terlalu lemah, minimal 6 karakter';
      } else if (msg.contains('network-request-failed')) {
        msg = 'Tidak ada koneksi internet';
      } else {
        msg = 'Gagal mendaftar, coba lagi';
      }
      setState(() { _error = msg; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(children: [
          const SizedBox(height: 40),
          const Text('REGISTER\nSTUDENT',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, height: 1.1)),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1565C0),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(
                color: const Color(0xFF1565C0).withOpacity(0.3),
                blurRadius: 20, offset: const Offset(0, 8))]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _field('Email *', _email, hint: 'student@example.com', icon: Icons.email_outlined, type: TextInputType.emailAddress),
              const SizedBox(height: 12),
              _field('Nama Lengkap *', _nama, icon: Icons.person_outline),
              const SizedBox(height: 12),
              _field('Umur', _umur, icon: Icons.cake_outlined, type: TextInputType.number),
              const SizedBox(height: 12),
              _field('Password *', _pass, icon: Icons.lock_outline, obscure: _op,
                toggle: () => setState(() => _op = !_op)),
              const SizedBox(height: 12),
              _field('Konfirmasi Password *', _confirm, icon: Icons.lock_outline, obscure: _oc,
                toggle: () => setState(() => _oc = !_oc)),

              // Error message
              if (_error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8)),
                  child: Row(children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_error!,
                      style: const TextStyle(color: Colors.red, fontSize: 12))),
                  ])),
              ],

              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                child: Text('Sudah punya akun? Login',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85), fontSize: 12,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.white))),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _daftar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1565C0),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: _loading
                      ? const SizedBox(height: 20, width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('DAFTAR',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, letterSpacing: 2)))),
            ])),
          const SizedBox(height: 30),
        ]))));

  Widget _field(String label, TextEditingController ctrl,
      {String? hint, IconData? icon, bool obscure = false,
       VoidCallback? toggle, TextInputType? type}) =>
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
      const SizedBox(height: 6),
      TextField(
        controller: ctrl,
        obscureText: obscure,
        keyboardType: type,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
          filled: true, fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          prefixIcon: icon != null ? Icon(icon, color: const Color(0xFF1565C0), size: 20) : null,
          suffixIcon: toggle != null
              ? IconButton(
                  icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: Colors.grey[500], size: 20),
                  onPressed: toggle)
              : null)),
    ]);
}