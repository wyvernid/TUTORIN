import 'package:flutter/material.dart';

class AdminTutorScreen extends StatefulWidget {
  const AdminTutorScreen({super.key});

  @override
  State<AdminTutorScreen> createState() => _AdminTutorScreenState();
}

class _AdminTutorScreenState extends State<AdminTutorScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;

  final List<Map<String, dynamic>> _pending = [
    {'name': 'Rizki Pratama', 'email': 'rizki@example.com', 'skills': ['Network', 'Cisco'], 'exp': 'S1 Teknik Informatika', 'date': '29 Apr 2026'},
    {'name': 'Dewi Kusuma', 'email': 'dewi@example.com', 'skills': ['Java', 'OOP', 'Spring'], 'exp': 'S1 Ilmu Komputer', 'date': '28 Apr 2026'},
  ];

  final List<Map<String, dynamic>> _verified = [
    {'name': 'Bintang Ivanna Cholida', 'email': 'bintang@example.com', 'rating': 4.8, 'classes': 3, 'students': 12},
    {'name': 'Ahmad Fauzi', 'email': 'ahmad@example.com', 'rating': 4.6, 'classes': 2, 'students': 8},
    {'name': 'Siti Rahmawati', 'email': 'siti@example.com', 'rating': 4.5, 'classes': 1, 'students': 5},
  ];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Kelola Tutor'),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tab,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: 'Menunggu Verifikasi (${_pending.length})'),
            Tab(text: 'Terverifikasi (${_verified.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [_buildPending(), _buildVerified()],
      ),
    );
  }

  Widget _buildPending() {
    if (_pending.isEmpty) return const Center(child: Text('Tidak ada tutor yang menunggu verifikasi', style: TextStyle(color: Colors.grey)));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _pending.length,
      itemBuilder: (ctx, i) {
        final t = _pending[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.orange[100]!),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 50, height: 50,
                      decoration: BoxDecoration(color: Colors.orange[50], shape: BoxShape.circle),
                      child: Icon(Icons.person_rounded, color: Colors.orange[700], size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(t['name'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                        Text(t['email'], style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                        const SizedBox(height: 4),
                        Text(t['exp'], style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                        const SizedBox(height: 6),
                        Wrap(spacing: 4, runSpacing: 4,
                          children: (t['skills'] as List).map((s) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: const Color(0xFF1565C0).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                            child: Text(s, style: const TextStyle(fontSize: 10, color: Color(0xFF1565C0), fontWeight: FontWeight.w600)),
                          )).toList(),
                        ),
                        const SizedBox(height: 4),
                        Text('Daftar: ${t['date']}', style: TextStyle(fontSize: 10, color: Colors.grey[400])),
                      ]),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    Expanded(child: TextButton.icon(
                      onPressed: () => setState(() => _pending.removeAt(i)),
                      icon: const Icon(Icons.close_rounded, size: 16, color: Colors.red),
                      label: const Text('Tolak', style: TextStyle(color: Colors.red)),
                    )),
                    Container(width: 0.5, height: 40, color: Colors.grey[200]),
                    Expanded(child: TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.visibility_rounded, size: 16, color: Color(0xFF1565C0)),
                      label: const Text('Lihat Portofolio', style: TextStyle(color: Color(0xFF1565C0), fontSize: 12)),
                    )),
                    Container(width: 0.5, height: 40, color: Colors.grey[200]),
                    Expanded(child: TextButton.icon(
                      onPressed: () => setState(() {
                        _verified.add({'name': t['name'], 'email': t['email'], 'rating': 0.0, 'classes': 0, 'students': 0});
                        _pending.removeAt(i);
                      }),
                      icon: const Icon(Icons.verified_user_rounded, size: 16, color: Colors.green),
                      label: const Text('Setujui', style: TextStyle(color: Colors.green)),
                    )),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVerified() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _verified.length,
      itemBuilder: (ctx, i) {
        final t = _verified[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
          ),
          child: Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(color: Colors.green[50], shape: BoxShape.circle),
                child: const Icon(Icons.person_rounded, color: Colors.green, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text(t['name'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 6),
                    const Icon(Icons.verified_rounded, color: Colors.blue, size: 14),
                  ]),
                  Text(t['email'], style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                  const SizedBox(height: 4),
                  Row(children: [
                    _mini('${t['classes']} kelas', Icons.class_rounded),
                    const SizedBox(width: 8),
                    _mini('${t['students']} murid', Icons.people_rounded),
                    if ((t['rating'] as double) > 0) ...[
                      const SizedBox(width: 8),
                      _mini('${t['rating']}', Icons.star_rounded, color: Colors.amber),
                    ],
                  ]),
                ]),
              ),
              PopupMenuButton<String>(
                onSelected: (v) {},
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'suspend', child: Text('Suspend Akun')),
                  const PopupMenuItem(value: 'detail', child: Text('Lihat Detail')),
                ],
                child: const Icon(Icons.more_vert_rounded, color: Color(0xFF78909C)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _mini(String text, IconData icon, {Color? color}) {
    return Row(children: [
      Icon(icon, size: 12, color: color ?? Colors.grey[500]),
      const SizedBox(width: 3),
      Text(text, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
    ]);
  }
}
