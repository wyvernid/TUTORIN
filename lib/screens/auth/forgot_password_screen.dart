import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _State();
}

class _State extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  final _auth = AuthService();
  bool _loading = false;
  bool _terkirim = false;
  String? _error;

  void _kirim() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Masukkan email kamu dulu');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await _auth.kirimResetPassword(email);
      if (!mounted) return;
      setState(() { _terkirim = true; _loading = false; });
    } catch (e) {
      String msg = e.toString();
      if (msg.contains('invalid-email')) {
        msg = 'Format email tidak valid';
      } else if (msg.contains('network-request-failed')) {
        msg = 'Tidak ada koneksi internet';
      } else if (msg.contains('too-many-requests')) {
        msg = 'Terlalu banyak percobaan, coba lagi nanti';
      } else if (msg.contains('user-not-found')) {
        setState(() { _terkirim = true; _loading = false; });
        return;
      } else {
        msg = 'Gagal mengirim email, coba lagi';
      }
      setState(() { _error = msg; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: Color(0xFF1565C0)),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () => Navigator.pop(context))),
    body: SafeArea(child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: _terkirim ? _buildSukses() : _buildForm())));

  Widget _buildForm() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 20),
      Container(width: 70, height: 70,
        decoration: BoxDecoration(color: const Color(0xFF1565C0).withOpacity(0.1), shape: BoxShape.circle),
        child: const Icon(Icons.lock_reset_rounded, size: 36, color: Color(0xFF1565C0))),
      const SizedBox(height: 20),
      const Text('Lupa Password?',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      Text('Masukkan email akun kamu. Kami akan kirim link untuk membuat password baru.',
        style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.5)),
      const SizedBox(height: 28),
      const Text('Email', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      const SizedBox(height: 6),
      TextField(
        controller: _emailCtrl,
        keyboardType: TextInputType.emailAddress,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: 'email@example.com',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
          filled: true, fillColor: const Color(0xFFF5F7FA),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF1565C0), size: 20))),
      if (_error != null) ...[
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)),
          child: Row(children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 16),
            const SizedBox(width: 8),
            Expanded(child: Text(_error!,
              style: const TextStyle(color: Colors.red, fontSize: 12))),
          ])),
      ],
      const SizedBox(height: 24),
      SizedBox(width: double.infinity,
        child: ElevatedButton(
          onPressed: _loading ? null : _kirim,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1565C0),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: _loading
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Kirim Link Reset', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)))),
      const SizedBox(height: 30),
    ]);

  Widget _buildSukses() => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Container(width: 90, height: 90,
        decoration: BoxDecoration(color: Colors.green[50], shape: BoxShape.circle),
        child: const Icon(Icons.mark_email_read_rounded, size: 46, color: Colors.green)),
      const SizedBox(height: 24),
      const Text('Email Terkirim!',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
      const SizedBox(height: 10),
      Text('Kami sudah mengirim link reset password ke:',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 13, color: Colors.grey[600])),
      const SizedBox(height: 4),
      Text(_emailCtrl.text.trim(),
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1565C0))),
      const SizedBox(height: 8),
      Text('Buka email kamu, klik link reset password, buat password baru, lalu login lagi di sini.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12, color: Colors.grey[500], height: 1.5)),
      const SizedBox(height: 32),
      SizedBox(width: double.infinity,
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1565C0),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: const Text('Kembali ke Login', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)))),
      const SizedBox(height: 12),
      TextButton(
        onPressed: () => setState(() => _terkirim = false),
        child: const Text('Tidak menerima email? Kirim ulang',
          style: TextStyle(color: Color(0xFF1565C0), fontSize: 13))),
    ]);
}