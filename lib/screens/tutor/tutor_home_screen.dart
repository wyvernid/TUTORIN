import 'package:flutter/material.dart';
import 'tutor_beranda_screen.dart';
import 'tutor_kelas_screen.dart';
import 'tutor_chat_list_screen.dart';
import 'tutor_profil_screen.dart';

class TutorHomeScreen extends StatefulWidget {
  const TutorHomeScreen({super.key});
  @override
  State<TutorHomeScreen> createState() => _State();
}

class _State extends State<TutorHomeScreen> {
  int _idx = 0;
  final _screens = const [TutorBerandaScreen(), TutorKelasScreen(), TutorChatListScreen(), TutorProfilScreen()];
  @override
  Widget build(BuildContext context) => Scaffold(
    body: IndexedStack(index: _idx, children: _screens),
    bottomNavigationBar: Container(
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0,-4))]),
      child: SafeArea(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _Nav(0, Icons.dashboard_rounded, 'Beranda', _idx, () => setState(() => _idx = 0)),
          _Nav(1, Icons.class_rounded, 'Kelas', _idx, () => setState(() => _idx = 1)),
          _Nav(2, Icons.chat_bubble_rounded, 'Chat', _idx, () => setState(() => _idx = 2)),
          _Nav(3, Icons.person_rounded, 'Profil', _idx, () => setState(() => _idx = 3)),
        ])))));
}

class _Nav extends StatelessWidget {
  final int index, current; final IconData icon; final String label; final VoidCallback onTap;
  const _Nav(this.index, this.icon, this.label, this.current, this.onTap);
  @override
  Widget build(BuildContext context) {
    final a = index == current;
    return GestureDetector(onTap: onTap, child: AnimatedContainer(duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: a ? const Color(0xFF1565C0).withOpacity(0.1) : Colors.transparent, borderRadius: BorderRadius.circular(14)),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: a ? const Color(0xFF1565C0) : const Color(0xFFB0BEC5), size: 24),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 10, fontWeight: a ? FontWeight.w700 : FontWeight.w400, color: a ? const Color(0xFF1565C0) : const Color(0xFFB0BEC5))),
      ])));
  }
}