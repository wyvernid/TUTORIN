import 'package:flutter/material.dart';
import 'tutor_tambah_kelas_screen.dart';
import '../student/student_report_screen.dart';

class TutorKelasScreen extends StatefulWidget {
  const TutorKelasScreen({super.key});

  @override
  State<TutorKelasScreen> createState() => _TutorKelasScreenState();
}

class _TutorKelasScreenState extends State<TutorKelasScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;

  final List<Map<String, dynamic>> _activeClasses = [
    {
      'title': 'Deep Learning Bert Algorithm',
      'category': 'Machine Learning',
      'price': 45000,
      'slots': 15,
      'slotsUsed': 8,
      'schedules': ['Senin', 'Rabu', 'Jumat'],
      'time': '18.00',
      'students': [
        {'name': 'Nafisa Nurin', 'status': 'confirmed', 'jadwal': 'Senin, 5 Mei'},
        {'name': 'Budi Santoso', 'status': 'confirmed', 'jadwal': 'Rabu, 7 Mei'},
        {'name': 'Rafi Maulana', 'status': 'pending', 'jadwal': 'Jumat, 9 Mei'},
      ],
    },
    {
      'title': 'Python untuk Data Science',
      'category': 'Data Science',
      'price': 50000,
      'slots': 10,
      'slotsUsed': 3,
      'schedules': ['Selasa', 'Kamis'],
      'time': '19.00',
      'students': [
        {'name': 'Sari Dewi', 'status': 'confirmed', 'jadwal': 'Selasa, 6 Mei'},
      ],
    },
  ];

  final List<Map<String, dynamic>> _completedClasses = [
    {'title': 'Intro to Machine Learning', 'totalStudents': 12, 'rating': 4.7},
    {'title': 'Neural Network Basics', 'totalStudents': 8, 'rating': 4.5},
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
        title: const Text('Kelola Kelas'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_rounded),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TutorTambahKelasScreen())),
          ),
        ],
        bottom: TabBar(
          controller: _tab,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          tabs: const [Tab(text: 'Kelas Aktif'), Tab(text: 'Selesai')],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [_buildAktif(), _buildSelesai()],
      ),
    );
  }

  Widget _buildAktif() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _activeClasses.length,
      itemBuilder: (ctx, i) => _ActiveClassCard(data: _activeClasses[i]),
    );
  }

  Widget _buildSelesai() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _completedClasses.length,
      itemBuilder: (ctx, i) {
        final item = _completedClasses[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
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
                decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['title'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                    Text('${item['totalStudents']} murid total',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFC107)),
                  const SizedBox(width: 3),
                  Text('${item['rating']}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ActiveClassCard extends StatefulWidget {
  final Map<String, dynamic> data;
  const _ActiveClassCard({required this.data});

  @override
  State<_ActiveClassCard> createState() => _ActiveClassCardState();
}

class _ActiveClassCardState extends State<_ActiveClassCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final int slotsLeft = widget.data['slots'] - widget.data['slotsUsed'];
    final double progress = widget.data['slotsUsed'] / widget.data['slots'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(widget.data['title'],
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1565C0))),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (v) {
                        if (v == 'edit') Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const TutorTambahKelasScreen()));
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit Kelas')),
                        const PopupMenuItem(value: 'nonaktif', child: Text('Nonaktifkan')),
                      ],
                      child: const Icon(Icons.more_vert_rounded, color: Color(0xFF78909C)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _chip(widget.data['category']),
                    const SizedBox(width: 6),
                    Text('Rp${_fmt(widget.data['price'])} / sesi',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1565C0))),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 13, color: Color(0xFF1565C0)),
                    const SizedBox(width: 4),
                    Text((widget.data['schedules'] as List).join(', ') + ' · ${widget.data['time']} WIB',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text('${widget.data['slotsUsed']}/${widget.data['slots']} slot terisi',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                    const Spacer(),
                    Text('$slotsLeft sisa', style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: slotsLeft <= 3 ? Colors.red : Colors.green,
                    )),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[200],
                    color: progress >= 0.9 ? Colors.red : const Color(0xFF1565C0),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.vertical(
                  bottom: _expanded ? Radius.zero : const Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Text('Daftar Murid (${(widget.data['students'] as List).length})',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1565C0))),
                  const Spacer(),
                  Icon(_expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      color: const Color(0xFF1565C0)),
                ],
              ),
            ),
          ),
          if (_expanded)
            ...((widget.data['students'] as List).map((s) => _StudentRow(student: s))),
        ],
      ),
    );
  }

  Widget _chip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF1565C0).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF1565C0), fontWeight: FontWeight.w600)),
    );
  }

  String _fmt(int v) => v >= 1000 ? '${(v / 1000).toStringAsFixed(0)}.000' : '$v';
}

class _StudentRow extends StatelessWidget {
  final Map<String, dynamic> student;
  const _StudentRow({required this.student});

  @override
  Widget build(BuildContext context) {
    final bool isPending = student['status'] == 'pending';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF1565C0).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_rounded, color: Color(0xFF1565C0), size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student['name'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                Text(student['jadwal'], style: TextStyle(fontSize: 10, color: Colors.grey[500])),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isPending ? Colors.orange[50] : Colors.green[50],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isPending ? 'Pending' : 'Confirmed',
              style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.w700,
                color: isPending ? Colors.orange[700] : Colors.green[700],
              ),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => StudentReportScreen(targetName: student['name'], targetRole: 'Student'),
            )),
            child: Container(
              width: 28, height: 28,
              decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.flag_outlined, color: Colors.red, size: 14),
            ),
          ),
        ],
      ),
    );
  }
}
