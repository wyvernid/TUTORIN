import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import 'login_screen.dart';
import '../student/student_home_screen.dart';
import '../tutor/tutor_home_screen.dart';
import '../auth/tutor_pending_screen.dart';


class VerifyEmailScreen extends StatefulWidget {
  final String email;
  const VerifyEmailScreen({super.key, required this.email});
  @override
  State<VerifyEmailScreen> createState() => _State();
}

class _State extends State<VerifyEmailScreen> {
  final _auth = AuthService();
  bool _checking = false;
  bool _resending = false;
  int _cooldown = 0;
  Timer? _cooldownTimer;
  Timer? _autoCheckTimer;

  @override
  void initState() {
    super.initState();
    _autoCheckTimer = Timer.periodic(const Duration(seconds: 4), (_) => _cekStatus(silent: true));
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _autoCheckTimer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    setState(() => _cooldown = 60);
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_cooldown <= 1) { t.cancel(); setState(() => _cooldown = 0); }
      else setState(() => _cooldown--);
    });
  }

  Future<void> _kirimUlang() async {
    setState(() => _resending = true);
    try {
      await _auth.kirimUlangVerifikasi();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email verifikasi dikirim ulang!'), backgroundColor: Colors.green));
      _startCooldown();
    } catch (e) {
      if (!mounted) return;
      String msg = 'Gagal mengirim ulang email';
      if (e.toString().contains('too-many-requests')) {
        msg = 'Terlalu sering, tunggu sebentar lalu coba lagi';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  Future<void> _cekStatus({bool silent = false}) async {
    if (!silent) setState(() => _checking = true);
    try {
      final verified = await _auth.reloadDanCekEmailVerified();
      if (!mounted) return;
      if (verified) {
        _autoCheckTimer?.cancel();
        await _lanjutSetelahVerified();
      } else if (!silent) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email belum diverifikasi. Cek inbox/spam kamu.')));
      }
    } finally {
      if (mounted && !silent) setState(() => _checking = false);
    }
  }

  Future<void> _lanjutSetelahVerified() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final data = await _auth.getUserData(user.uid);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Email terverifikasi!'), backgroundColor: Colors.green));

    Widget next;
    switch (data?.role) {
      case 'tutor':
        next = (data?.isVerified == true) ? const TutorHomeScreen() : const TutorPendingScreen();
        break;
      default:
        next = const StudentHomeScreen();
    }
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => next), (route) => false);
  }

  void _gantiAkun() async {
    await _auth.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 90, height: 90,
          decoration: BoxDecoration(color: const Color(0xFF1565C0).withOpacity(0.1), shape: BoxShape.circle),
          child: const Icon(Icons.mark_email_unread_rounded, size: 46, color: Color(0xFF1565C0))),
        const SizedBox(height: 24),
        const Text('Verifikasi Email Kamu',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        Text('Kami sudah mengirim link verifikasi ke:',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(widget.email,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1565C0))),
        const SizedBox(height: 8),
        Text('Buka email kamu, klik link verifikasinya, lalu kembali ke sini.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.grey[500], height: 1.5)),
        const SizedBox(height: 32),
        SizedBox(width: double.infinity,
          child: ElevatedButton(
            onPressed: _checking ? null : () => _cekStatus(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: _checking
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Saya Sudah Verifikasi', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)))),
        const SizedBox(height: 12),
        SizedBox(width: double.infinity,
          child: OutlinedButton(
            onPressed: (_resending || _cooldown > 0) ? null : _kirimUlang,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF1565C0)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: _resending
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(_cooldown > 0 ? 'Kirim Ulang ($_cooldown detik)' : 'Kirim Ulang Email',
                    style: const TextStyle(color: Color(0xFF1565C0), fontWeight: FontWeight.w700, fontSize: 14)))),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: _gantiAkun,
          child: Text('Salah akun? Logout & daftar/login ulang',
            style: TextStyle(fontSize: 12, color: Colors.grey[500], decoration: TextDecoration.underline))),
      ]))));
}