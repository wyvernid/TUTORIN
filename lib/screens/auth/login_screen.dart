// import 'package:flutter/material.dart';
// import '../../services/auth_service.dart';
// import '../student/student_home_screen.dart';
// import '../tutor/tutor_home_screen.dart';
// import '../admin/admin_home_screen.dart';
// import 'register_select_screen.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _emailCtrl = TextEditingController();
//   final _passCtrl = TextEditingController();
//   final _auth = AuthService();
//   bool _obscure = true, _loading = false;
//   String? _error;

//   void _login() async {
//     if (_emailCtrl.text.isEmpty || _passCtrl.text.isEmpty) { setState(() => _error = 'Email dan password wajib diisi'); return; }
//     setState(() { _loading = true; _error = null; });
//     try {
//       final user = await _auth.login(email: _emailCtrl.text.trim(), password: _passCtrl.text);
//       if (!mounted) return;
//       Widget next;
//       switch (user?.role) {
//         case 'tutor': next = const TutorHomeScreen(); break;
//         case 'admin': next = const AdminHomeScreen(); break;
//         default: next = const StudentHomeScreen();
//       }
//       Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => next));
//     } catch (e) {
//       setState(() { _error = 'Email atau password salah'; _loading = false; });
//     }
//   }

//   @override
//   Widget build(BuildContext context) => Scaffold(
//     backgroundColor: Colors.white,
//     body: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.symmetric(horizontal: 28), child: Column(children: [
//       const SizedBox(height: 60),
//       const Text('TUTORIN', style: TextStyle(fontSize: 38, fontWeight: FontWeight.w900, color: Color(0xFF1565C0), letterSpacing: 3)),
//       const SizedBox(height: 6),
//       const Text('Selamat datang kembali!', style: TextStyle(fontSize: 14, color: Color(0xFF78909C))),
//       const SizedBox(height: 40),
//       Container(padding: const EdgeInsets.all(24),
//         decoration: BoxDecoration(color: const Color(0xFF1565C0), borderRadius: BorderRadius.circular(24),
//           boxShadow: [BoxShadow(color: const Color(0xFF1565C0).withOpacity(0.3), blurRadius: 20, offset: const Offset(0,8))]),
//         child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           const Text('Email', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
//           const SizedBox(height: 8),
//           TextField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress, style: const TextStyle(fontSize: 14),
//             decoration: InputDecoration(hintText: 'student@example.com', hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
//               filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
//               prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF1565C0), size: 20))),
//           const SizedBox(height: 16),
//           const Text('Password', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
//           const SizedBox(height: 8),
//           TextField(controller: _passCtrl, obscureText: _obscure, style: const TextStyle(fontSize: 14),
//             decoration: InputDecoration(filled: true, fillColor: Colors.white,
//               border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
//               prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF1565C0), size: 20),
//               suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey[500], size: 20),
//                 onPressed: () => setState(() => _obscure = !_obscure)))),
//           if (_error != null) ...[const SizedBox(height: 10), Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 12))],
//           const SizedBox(height: 20),
//           SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _loading ? null : _login,
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF1565C0), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
//             child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
//                 : const Text('LOGIN', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, letterSpacing: 2)))),
//         ])),
//       const SizedBox(height: 28),
//       GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterSelectScreen())),
//         child: const Text('Belum punya akun? Daftar sekarang', style: TextStyle(color: Color(0xFF1565C0), fontSize: 13, fontWeight: FontWeight.w600))),
//     ]))),
//   );
// }

// ------------------------------------------------

import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../student/student_home_screen.dart';
import '../tutor/tutor_home_screen.dart';
import '../admin/admin_home_screen.dart';
import 'register_select_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  final _auth      = AuthService();
  bool    _obscure = true, _loading = false;
  String? _error;

  void _login() async {
    if (_emailCtrl.text.trim().isEmpty || _passCtrl.text.isEmpty) {
      setState(() => _error = 'Email dan password wajib diisi');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final user = await _auth.login(
        email:    _emailCtrl.text.trim(),
        password: _passCtrl.text);

      if (!mounted) return;

      Widget next;
      switch (user?.role) {
        case 'tutor': next = const TutorHomeScreen(); break;
        case 'admin': next = const AdminHomeScreen();  break;
        default:      next = const StudentHomeScreen();
      }
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => next));
    } catch (e) {
      String msg = e.toString();
      if (msg.contains('user-not-found') || msg.contains('wrong-password') ||
          msg.contains('invalid-credential')) {
        msg = 'Email atau password salah';
      } else if (msg.contains('user-disabled')) {
        msg = 'Akun dinonaktifkan, hubungi admin';
      } else if (msg.contains('network-request-failed')) {
        msg = 'Tidak ada koneksi internet';
      } else if (msg.contains('too-many-requests')) {
        msg = 'Terlalu banyak percobaan, coba lagi nanti';
      } else {
        msg = 'Login gagal, coba lagi';
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
          const SizedBox(height: 60),
          const Text('TUTORIN',
            style: TextStyle(fontSize: 38, fontWeight: FontWeight.w900,
              color: Color(0xFF1565C0), letterSpacing: 3)),
          const SizedBox(height: 6),
          const Text('Selamat datang kembali!',
            style: TextStyle(fontSize: 14, color: Color(0xFF78909C))),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1565C0),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(
                color: const Color(0xFF1565C0).withOpacity(0.3),
                blurRadius: 20, offset: const Offset(0, 8))]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Email',
                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'email@example.com',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                  filled: true, fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF1565C0), size: 20))),
              const SizedBox(height: 16),
              const Text('Password',
                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _passCtrl,
                obscureText: _obscure,
                style: const TextStyle(fontSize: 14),
                onSubmitted: (_) => _login(),
                decoration: InputDecoration(
                  filled: true, fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF1565C0), size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: Colors.grey[500], size: 20),
                    onPressed: () => setState(() => _obscure = !_obscure)))),

              // Error
              if (_error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red[50], borderRadius: BorderRadius.circular(8)),
                  child: Row(children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_error!,
                      style: const TextStyle(color: Colors.red, fontSize: 12))),
                  ])),
              ],

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1565C0),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: _loading
                      ? const SizedBox(height: 20, width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('LOGIN',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, letterSpacing: 2)))),
            ])),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const RegisterSelectScreen())),
            child: const Text('Belum punya akun? Daftar sekarang',
              style: TextStyle(color: Color(0xFF1565C0), fontSize: 13, fontWeight: FontWeight.w600))),
          const SizedBox(height: 30),
        ]))));
}
