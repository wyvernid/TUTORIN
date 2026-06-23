import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../student/student_home_screen.dart';
import '../tutor/tutor_home_screen.dart';
import '../admin/admin_home_screen.dart';
import 'login_screen.dart';
import 'tutor_pending_screen.dart';
import 'verify_email_screen.dart';

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

    // Sudah login tapi belum verifikasi email
    try {
      final verified = await AuthService().reloadDanCekEmailVerified();
      if (!mounted) return;
      if (!verified) {
        _goTo(VerifyEmailScreen(email: user.email ?? ''));
        return;
      }
    } catch (e) {
      debugPrint('SplashScreen email verify check error: $e');
    }

    // Sudah login & terverifikasi 
    try {
      final data = await AuthService().getUserData(user.uid);
      if (!mounted) return;

      if (data?.isSuspended == true) {
        await AuthService().logout();
        if (!mounted) return;
        _goTo(const LoginScreen(suspendedMessage:
            'Akun kamu disuspend oleh admin.'));
        return;
      }

      switch (data?.role) {
        case 'tutor':
          if (data?.isVerified == true) {
            _goTo(const TutorHomeScreen());
          } else {
            _goTo(const TutorPendingScreen());
          }
          break;
        case 'admin':
          _goTo(const AdminHomeScreen());
          break;
        default:
          _goTo(const StudentHomeScreen());
      }
    } catch (e) {
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
                Image.asset(
                  'assets/images/splash.png',
                  width: 180,
                  height: 180,
                  fit: BoxFit.contain,
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
