// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../../services/auth_service.dart';
// import '../student/student_home_screen.dart';
// import '../tutor/tutor_home_screen.dart';
// import '../admin/admin_home_screen.dart';
// import 'login_screen.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});
//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
//   late AnimationController _ctrl;
//   late Animation<double> _fade, _scale;

//   @override
//   void initState() {
//     super.initState();
//     _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
//     _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
//     _scale = Tween(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
//     _ctrl.forward();
//     Timer(const Duration(seconds: 3), _navigate);
//   }

//   Future<void> _navigate() async {
//     if (!mounted) return;
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) { Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())); return; }
//     final data = await AuthService().getUserData(user.uid);
//     if (!mounted) return;
//     Widget next;
//     switch (data?.role) {
//       case 'tutor': next = const TutorHomeScreen(); break;
//       case 'admin': next = const AdminHomeScreen(); break;
//       default: next = const StudentHomeScreen();
//     }
//     Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => next));
//   }

//   @override
//   void dispose() { _ctrl.dispose(); super.dispose(); }

//   @override
//   Widget build(BuildContext context) => Scaffold(
//     backgroundColor: const Color(0xFF1565C0),
//     body: Center(child: FadeTransition(opacity: _fade, child: ScaleTransition(scale: _scale,
//       child: Column(mainAxisSize: MainAxisSize.min, children: [
//         Container(width: 100, height: 100,
//           decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28),
//             boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 24, offset: const Offset(0,8))]),
//           child: const Icon(Icons.school_rounded, size: 56, color: Color(0xFF1565C0))),
//         const SizedBox(height: 24),
//         const Text('TUTORIN', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: 4)),
//         const SizedBox(height: 8),
//         Text('Belajar Lebih Mudah', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
//       ])))),
//   );
// }




// --------------------------------------
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../student/student_home_screen.dart';
import '../tutor/tutor_home_screen.dart';
import '../admin/admin_home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade, _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _scale = Tween(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _ctrl.forward();
    Timer(const Duration(seconds: 3), _navigate);
  }

  Future<void> _navigate() async {
    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser;

    // Belum login → ke halaman login
    if (user == null) {
      _goTo(const LoginScreen());
      return;
    }

    // Sudah login → cek role dari Firestore
    // Dibungkus try-catch supaya permission-denied tidak crash
    try {
      final data = await AuthService().getUserData(user.uid);
      if (!mounted) return;

      switch (data?.role) {
        case 'tutor':
          _goTo(const TutorHomeScreen());
          break;
        case 'admin':
          _goTo(const AdminHomeScreen());
          break;
        default:
          _goTo(const StudentHomeScreen());
      }
    } catch (e) {
      // Firestore rules belum aktif / permission denied
      // → tetap arahkan ke login supaya tidak stuck
      debugPrint('SplashScreen navigate error: $e');
      if (!mounted) return;
      _goTo(const LoginScreen());
    }
  }

  void _goTo(Widget screen) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFF1565C0),
        body: Center(
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black26,
                          blurRadius: 24,
                          offset: Offset(0, 8))
                    ],
                  ),
                  child: const Icon(Icons.school_rounded,
                      size: 56, color: Color(0xFF1565C0)),
                ),
                const SizedBox(height: 24),
                const Text('TUTORIN',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4)),
                const SizedBox(height: 8),
                Text('Belajar Lebih Mudah',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.8), fontSize: 14)),
              ]),
            ),
          ),
        ),
      );
}
