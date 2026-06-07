import 'package:flutter/material.dart';
import 'student_beranda_screen.dart';
import 'student_kelas_screen.dart';
import 'student_chat_list_screen.dart';
import 'student_profil_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const StudentBerandaScreen(),
    const StudentKelasScreen(),
    const StudentChatListScreen(),
    const StudentProfilScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(index: 0, icon: Icons.home_rounded, label: 'Beranda', current: _currentIndex,
                    onTap: () => setState(() => _currentIndex = 0)),
                _NavItem(index: 1, icon: Icons.bookmark_rounded, label: 'Kelas', current: _currentIndex,
                    onTap: () => setState(() => _currentIndex = 1)),
                _NavItem(index: 2, icon: Icons.chat_bubble_rounded, label: 'Chat', current: _currentIndex,
                    onTap: () => setState(() => _currentIndex = 2)),
                _NavItem(index: 3, icon: Icons.person_rounded, label: 'Profil', current: _currentIndex,
                    onTap: () => setState(() => _currentIndex = 3)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final int index;
  final int current;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _NavItem({
    required this.index,
    required this.current,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = index == current;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF1565C0).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? const Color(0xFF1565C0) : const Color(0xFFB0BEC5),
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                color: isActive ? const Color(0xFF1565C0) : const Color(0xFFB0BEC5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
