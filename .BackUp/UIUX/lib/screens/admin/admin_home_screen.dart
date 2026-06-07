import 'package:flutter/material.dart';
import 'admin_dashboard_screen.dart';
import 'admin_laporan_screen.dart';
import 'admin_tutor_screen.dart';
import 'admin_user_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _idx = 0;

  final List<Widget> _screens = [
    const AdminDashboardScreen(),
    const AdminLaporanScreen(),
    const AdminTutorScreen(),
    const AdminUserScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _idx, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, -4))],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(index: 0, icon: Icons.dashboard_rounded, label: 'Dashboard', current: _idx, onTap: () => setState(() => _idx = 0)),
                _NavItem(index: 1, icon: Icons.report_rounded, label: 'Laporan', current: _idx, onTap: () => setState(() => _idx = 1)),
                _NavItem(index: 2, icon: Icons.verified_user_rounded, label: 'Tutor', current: _idx, onTap: () => setState(() => _idx = 2)),
                _NavItem(index: 3, icon: Icons.group_rounded, label: 'Pengguna', current: _idx, onTap: () => setState(() => _idx = 3)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final int index, current;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _NavItem({required this.index, required this.current, required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool a = index == current;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: a ? const Color(0xFF1565C0).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: a ? const Color(0xFF1565C0) : const Color(0xFFB0BEC5), size: 24),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 9, fontWeight: a ? FontWeight.w700 : FontWeight.w400,
              color: a ? const Color(0xFF1565C0) : const Color(0xFFB0BEC5))),
        ]),
      ),
    );
  }
}
