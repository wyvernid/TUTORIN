import 'package:flutter/material.dart';
import '../../services/admin_service.dart';
import '../../services/laporan_service.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final adminService = AdminService();
    final laporanService = LaporanService();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(slivers: [
        SliverToBoxAdapter(child: _buildHeader(context)),
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: const Text('Ringkasan Platform', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)))),
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(children: [
            Row(children: [
              _StreamStatCard(label: 'Total Student', icon: Icons.school_rounded, color: const Color(0xFF1565C0),
                stream: adminService.streamStudent().map((l) => l.length.toString())),
              const SizedBox(width: 10),
              _StreamStatCard(label: 'Tutor Aktif', icon: Icons.cast_for_education_rounded, color: Colors.green,
                stream: adminService.streamTutorVerified().map((l) => l.length.toString())),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              _StreamStatCard(label: 'Tutor Pending', icon: Icons.pending_rounded, color: Colors.orange,
                stream: adminService.streamTutorPending().map((l) => l.length.toString())),
              const SizedBox(width: 10),
              _StreamStatCard(label: 'Laporan Aktif', icon: Icons.flag_rounded, color: Colors.red,
                stream: laporanService.streamAktif().map((l) => l.length.toString())),
            ]),
          ]))),
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: const Text('Laporan Terbaru', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)))),
        StreamBuilder(
          stream: laporanService.streamAktif(),
          builder: (_, snap) {
            if (!snap.hasData) return const SliverToBoxAdapter(child: SizedBox());
            final items = snap.data!.take(5).toList();
            return SliverList(delegate: SliverChildBuilderDelegate((_, i) {
              final l = items[i];
              return Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4)]),
                child: Row(children: [
                  Container(width: 36, height: 36, decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(10)),
                    child: Icon(Icons.flag_rounded, color: Colors.red[600], size: 18)),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(l.kategori, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text('${l.fromNama} → ${l.againstNama}', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                  ])),
                  Text('${l.createdAt.day}/${l.createdAt.month}', style: TextStyle(fontSize: 10, color: Colors.grey[400])),
                ]));
            }, childCount: items.length));
          }),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ]));
  }

  Widget _buildHeader(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
    decoration: const BoxDecoration(color: Color(0xFF1565C0), borderRadius: BorderRadius.vertical(bottom: Radius.circular(28))),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [Text('Dashboard Admin ', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)), Text('⚙️', style: TextStyle(fontSize: 18))]),
        const Text('TutorIn Admin Panel', style: TextStyle(color: Colors.white70, fontSize: 12)),
      ])),
      Container(width: 42, height: 42, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
        child: const Icon(Icons.notifications_rounded, color: Colors.white, size: 22)),
      const SizedBox(width: 10),
      GestureDetector(
        onTap: () => _confirmLogout(context),
        child: Container(width: 42, height: 42, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
          child: const Icon(Icons.logout_rounded, color: Colors.white, size: 22)),
      ),
    ]));

  void _confirmLogout(BuildContext context) {
    showDialog(context: context, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Keluar', style: TextStyle(fontWeight: FontWeight.w700)),
      content: const Text('Apakah Anda yakin ingin keluar dari akun admin?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () async {
            Navigator.pop(context);
            await AuthService().logout();
            if (context.mounted) {
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
            }
          },
          child: const Text('Keluar')),
      ]));
  }
}

class _StreamStatCard extends StatelessWidget {
  final String label; final IconData icon; final Color color; final Stream<String> stream;
  const _StreamStatCard({required this.label, required this.icon, required this.color, required this.stream});
  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
    child: Row(children: [
      Container(width: 40, height: 40, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: color, size: 20)),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        StreamBuilder<String>(stream: stream, builder: (_, snap) => Text(snap.data ?? '...', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
        Text(label, style: TextStyle(fontSize: 9, color: Colors.grey[500])),
      ])),
    ])));
}