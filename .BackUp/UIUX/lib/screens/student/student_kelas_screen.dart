import 'package:flutter/material.dart';
import 'student_report_screen.dart';

class StudentKelasScreen extends StatefulWidget {
  const StudentKelasScreen({super.key});

  @override
  State<StudentKelasScreen> createState() => _StudentKelasScreenState();
}

class _StudentKelasScreenState extends State<StudentKelasScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _upcoming = [
    {
      'title': 'Deep Learning Bert Algorithm',
      'tutor': 'Bintang Ivanna Cholida',
      'date': 'Senin, 25 April 2026',
      'time': '18.00 PM',
      'status': 'upcoming',
      'statusLabel': 'Terkonfirmasi',
    },
    {
      'title': 'Flutter Mobile Development',
      'tutor': 'Ahmad Fauzi',
      'date': 'Rabu, 27 April 2026',
      'time': '19.00 PM',
      'status': 'waiting',
      'statusLabel': 'Menunggu Verifikasi',
    },
    {
      'title': 'Algoritma dan Struktur Data',
      'tutor': 'Siti Rahmawati',
      'date': 'Sabtu, 29 April 2026',
      'time': '09.00 AM',
      'status': 'upcoming',
      'statusLabel': 'Terkonfirmasi',
    },
  ];

  final List<Map<String, dynamic>> _completed = [
    {'title': 'Deep Learning Bert Algorithm', 'tutor': 'Bintang Ivanna Cholida', 'reviewed': false},
    {'title': 'Jaringan Komputer Dasar', 'tutor': 'Rizki Pratama', 'reviewed': true},
    {'title': 'Deep Learning Bert Algorithm', 'tutor': 'Bintang Ivanna Cholida', 'reviewed': false},
    {'title': 'PBO - Java Programming', 'tutor': 'Sari Dewi', 'reviewed': true},
    {'title': 'Deep Learning Bert Algorithm', 'tutor': 'Bintang Ivanna Cholida', 'reviewed': false},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Kelas Saya'),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Mendatang'),
            Tab(text: 'Selesai'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUpcoming(),
          _buildCompleted(),
        ],
      ),
    );
  }

  Widget _buildUpcoming() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _upcoming.length,
      itemBuilder: (ctx, i) {
        final item = _upcoming[i];
        final isWaiting = item['status'] == 'waiting';
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isWaiting ? Colors.orange[50] : Colors.green[50],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      item['statusLabel'],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isWaiting ? Colors.orange[700] : Colors.green[700],
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${item['date']} · ${item['time']}',
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                item['title'],
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1565C0),
                ),
              ),
              Text('Tutor: ${item['tutor']}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.chat_bubble_outline, size: 16),
                      label: const Text('Hubungi Tutor', style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1565C0),
                        side: const BorderSide(color: Color(0xFF1565C0)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StudentReportScreen(
                          targetName: item['tutor'],
                          targetRole: 'Tutor',
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.flag_outlined, color: Colors.red, size: 20),
                    tooltip: 'Laporkan',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.red[50],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCompleted() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _completed.length,
      itemBuilder: (ctx, i) {
        final item = _completed[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'],
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                    Text('Tutor: ${item['tutor']}',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: item['reviewed'] ? null : () => _showReviewDialog(context, item['title']),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: item['reviewed'] ? Colors.grey[300] : const Color(0xFF1565C0),
                      foregroundColor: item['reviewed'] ? Colors.grey : Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      minimumSize: Size.zero,
                      textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(item['reviewed'] ? 'Direview' : 'Submit Review'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showReviewDialog(BuildContext context, String title) {
    int rating = 4;
    final reviewCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Beri Ulasan', style: TextStyle(fontWeight: FontWeight.w700)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  return GestureDetector(
                    onTap: () => setS(() => rating = i + 1),
                    child: Icon(
                      i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: const Color(0xFFFFC107),
                      size: 36,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reviewCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Tulis ulasan Anda...',
                  hintStyle: TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Kirim'),
            ),
          ],
        ),
      ),
    );
  }
}
