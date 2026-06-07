import 'package:flutter/material.dart';
import 'tutor_verifikasi_pembayaran_screen.dart';

class TutorBerandaScreen extends StatelessWidget {
  const TutorBerandaScreen({super.key});

  static final List<Map<String, dynamic>> _pendingPayments = [
    {
      'student': 'Nafisa Nurin',
      'kelas': 'Deep Learning Bert Algorithm',
      'jadwal': 'Senin, 5 Mei 2026 · 18.00',
      'nominal': 45000,
      'uploadedAt': '30 Apr 2026, 09:12',
    },
    {
      'student': 'Budi Santoso',
      'kelas': 'Deep Learning Bert Algorithm',
      'jadwal': 'Rabu, 7 Mei 2026 · 18.00',
      'nominal': 45000,
      'uploadedAt': '30 Apr 2026, 11:45',
    },
  ];

  static final List<Map<String, dynamic>> _upcomingClasses = [
    {'title': 'Deep Learning Bert Algorithm', 'student': 'Nafisa Nurin', 'date': 'Senin, 5 Mei 2026', 'time': '18.00'},
    {'title': 'Deep Learning Bert Algorithm', 'student': 'Rafi Maulana', 'date': 'Senin, 5 Mei 2026', 'time': '18.00'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader()),
          SliverToBoxAdapter(child: _buildStats()),
          if (_pendingPayments.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Container(
                      width: 8, height: 8,
                      decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    const Text('Menunggu Verifikasi Pembayaran',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('${_pendingPayments.length}',
                          style: TextStyle(fontSize: 11, color: Colors.orange[800], fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => _PendingPaymentCard(data: _pendingPayments[i]),
                childCount: _pendingPayments.length,
              ),
            ),
          ],
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: const Text('Kelas Mendatang', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => _UpcomingCard(data: _upcomingClasses[i]),
              childCount: _upcomingClasses.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF1565C0),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Text('Hi Tutor ', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                  const Text('🎓', style: TextStyle(fontSize: 20)),
                ]),
                const Text('Dashboard Pengajar', style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
            child: const Icon(Icons.notifications_rounded, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          _statCard('Rp540K', 'Pendapatan\nBulan Ini', Icons.account_balance_wallet_rounded, Colors.green),
          const SizedBox(width: 10),
          _statCard('12', 'Total\nMurid Aktif', Icons.people_rounded, const Color(0xFF1565C0)),
          const SizedBox(width: 10),
          _statCard('4.8', 'Rating\nKamu', Icons.star_rounded, Colors.amber),
        ],
      ),
    );
  }

  Widget _statCard(String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 9, color: Colors.grey[500]), maxLines: 2),
          ],
        ),
      ),
    );
  }
}

class _PendingPaymentCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _PendingPaymentCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TutorVerifikasiPembayaranScreen(data: data)),
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.orange[200]!),
          boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.06), blurRadius: 8)],
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.receipt_long_rounded, color: Colors.orange[700], size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data['student'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                  Text(data['kelas'], style: TextStyle(fontSize: 11, color: Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(data['jadwal'], style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Rp${_fmt(data['nominal'])}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF1565C0))),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(20)),
                  child: const Text('Verifikasi', style: TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(int v) => v >= 1000 ? '${(v / 1000).toStringAsFixed(0)}.000' : '$v';
}

class _UpcomingCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _UpcomingCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF1565C0).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.class_rounded, color: Color(0xFF1565C0), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data['title'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                Text('Murid: ${data['student']}', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(data['date'], style: TextStyle(fontSize: 10, color: Colors.grey[500])),
              Text(data['time'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1565C0))),
            ],
          ),
        ],
      ),
    );
  }
}
