import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader()),
          SliverToBoxAdapter(child: _buildStatCards()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: const Text('Aktivitas Terbaru', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            ),
          ),
          SliverList(delegate: SliverChildBuilderDelegate((ctx, i) => _ActivityTile(item: _activities[i]), childCount: _activities.length)),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  static final List<Map<String, dynamic>> _activities = [
    {'icon': Icons.flag_rounded, 'color': Colors.red, 'text': 'Laporan baru dari Nafisa Nurin terhadap Tutor Budi', 'time': '5 menit lalu'},
    {'icon': Icons.person_add_rounded, 'color': Colors.green, 'text': 'Tutor baru mendaftar: Rizki Pratama', 'time': '1 jam lalu'},
    {'icon': Icons.payment_rounded, 'color': const Color(0xFF1565C0), 'text': 'Transaksi baru Rp45.000 - Nafisa → Bintang', 'time': '2 jam lalu'},
    {'icon': Icons.report_problem_rounded, 'color': Colors.orange, 'text': 'Laporan baru dari Tutor Ahmad terhadap Student Budi', 'time': '3 jam lalu'},
    {'icon': Icons.star_rounded, 'color': Colors.amber, 'text': 'Review 5 bintang untuk Tutor Bintang Ivanna', 'time': '5 jam lalu'},
  ];

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF1565C0), borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Text('Dashboard Admin ', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                const Text('⚙️', style: TextStyle(fontSize: 18)),
              ]),
              const Text('TutorIn Admin Panel', style: TextStyle(color: Colors.white70, fontSize: 12)),
            ]),
          ),
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
            child: const Icon(Icons.notifications_rounded, color: Colors.white, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          Row(
            children: [
              _statCard('248', 'Total Student', Icons.school_rounded, const Color(0xFF1565C0)),
              const SizedBox(width: 10),
              _statCard('36', 'Total Tutor', Icons.cast_for_education_rounded, Colors.green),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _statCard('Rp12jt', 'Transaksi Bulan Ini', Icons.account_balance_wallet_rounded, Colors.purple),
              const SizedBox(width: 10),
              _statCard('7', 'Laporan Aktif', Icons.flag_rounded, Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCard(String v, String l, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
        child: Row(
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(v, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              Text(l, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
            ]),
          ],
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final Map<String, dynamic> item;
  const _ActivityTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4)]),
      child: Row(
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(color: (item['color'] as Color).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(item['icon'] as IconData, color: item['color'] as Color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item['text'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500), maxLines: 2),
              const SizedBox(height: 2),
              Text(item['time'], style: TextStyle(fontSize: 10, color: Colors.grey[400])),
            ],
          )),
        ],
      ),
    );
  }
}
