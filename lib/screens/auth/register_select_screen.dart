import 'package:flutter/material.dart';
import 'register_student_screen.dart';
import 'register_tutor_screen.dart';

class RegisterSelectScreen extends StatelessWidget {
  const RegisterSelectScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(backgroundColor: Colors.white,
    body: SafeArea(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 28), child: Column(children: [
      const SizedBox(height: 80),
      const Text('CREATE\nACCOUNT', textAlign: TextAlign.center,
        style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, height: 1.1, letterSpacing: 1)),
      const SizedBox(height: 12),
      const Text('Kamu ingin mendaftar sebagai apa?', style: TextStyle(color: Color(0xFF78909C), fontSize: 14)),
      const SizedBox(height: 56),
      Row(children: [
        _RoleCard(title: 'STUDENT', icon: Icons.school_rounded,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterStudentScreen()))),
        const SizedBox(width: 16),
        _RoleCard(title: 'TUTOR', icon: Icons.cast_for_education_rounded,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterTutorScreen()))),
      ]),
    ]))));
}

class _RoleCard extends StatelessWidget {
  final String title; final IconData icon; final VoidCallback onTap;
  const _RoleCard({required this.title, required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => Expanded(child: GestureDetector(onTap: onTap,
    child: Container(height: 140,
      decoration: BoxDecoration(color: const Color(0xFF1565C0), borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: const Color(0xFF1565C0).withOpacity(0.35), blurRadius: 16, offset: const Offset(0,6))]),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: Colors.white, size: 44),
        const SizedBox(height: 10),
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
      ]))));
}