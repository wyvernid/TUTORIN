import 'package:flutter/material.dart';
import 'student_detail_kelas_screen.dart';

class StudentBerandaScreen extends StatelessWidget {
  const StudentBerandaScreen({super.key});

  static final List<Map<String, dynamic>> _classes = [
    {
      'title': 'Deep Learning Bert Algorithm',
      'tutor': 'Bintang Ivanna Cholida',
      'category': 'Machine Learning',
      'price': 45000,
      'rating': 4.6,
      'reviews': 3000,
      'address': 'Jln Jawa jawa jawa 5',
      'slots': 15,
      'slotsUsed': 8,
      'schedules': ['Senin', 'Rabu', 'Jumat'],
      'time': '18.00',
      'duration': '1 jam',
      'tags': ['AI', 'ML', 'Deep Learning'],
    },
    {
      'title': 'Pemrograman Flutter Dasar',
      'tutor': 'Ahmad Fauzi',
      'category': 'Mobile Dev',
      'price': 35000,
      'rating': 4.8,
      'reviews': 1200,
      'address': 'Jln Kalimantan No.37',
      'slots': 20,
      'slotsUsed': 5,
      'schedules': ['Selasa', 'Kamis'],
      'time': '19.00',
      'duration': '1.5 jam',
      'tags': ['Flutter', 'Dart', 'Mobile'],
    },
    {
      'title': 'Algoritma dan Struktur Data',
      'tutor': 'Siti Rahmawati',
      'category': 'Algoritma',
      'price': 40000,
      'rating': 4.5,
      'reviews': 870,
      'address': 'Jln Sumatra No.12',
      'slots': 12,
      'slotsUsed': 12,
      'schedules': ['Sabtu'],
      'time': '09.00',
      'duration': '2 jam',
      'tags': ['Algo', 'DS', 'C++'],
    },
    {
      'title': 'Jaringan Komputer Dasar',
      'tutor': 'Rizki Pratama',
      'category': 'Jarkom',
      'price': 30000,
      'rating': 4.3,
      'reviews': 450,
      'address': 'Jln Brawijaya No.5',
      'slots': 10,
      'slotsUsed': 3,
      'schedules': ['Minggu'],
      'time': '10.00',
      'duration': '1 jam',
      'tags': ['Network', 'Cisco', 'TCP/IP'],
    },
  ];

  static const List<String> _categories = [
    'Semua', 'Algo', 'Basda', 'Jarkom', 'PBO', 'JST', 'Machine Learning', 'Mobile Dev',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context)),
          SliverToBoxAdapter(child: _buildCategories()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(
                'Tutor dan Pembelajaran Tersedia',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800],
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _ClassCard(data: _classes[index]),
              childCount: _classes.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF1565C0),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Hi Murid ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Text('👋', style: TextStyle(fontSize: 20)),
                      ],
                    ),
                    const Text(
                      'Lets Start Learning',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_rounded, color: Colors.white, size: 26),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                ),
              ],
            ),
            child: TextField(
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Cari tutor atau mata pelajaran...',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF1565C0)),
                suffixIcon: const Icon(Icons.tune, color: Color(0xFF1565C0)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 56,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final isFirst = index == 0;
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(_categories[index]),
              selected: isFirst,
              onSelected: (_) {},
              selectedColor: const Color(0xFF1565C0),
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isFirst ? Colors.white : Colors.grey[700],
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              side: BorderSide.none,
              padding: const EdgeInsets.symmetric(horizontal: 4),
            ),
          );
        },
      ),
    );
  }
}

class _ClassCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _ClassCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final isFull = data['slotsUsed'] >= data['slots'];
    final slotsLeft = data['slots'] - data['slotsUsed'];

    return GestureDetector(
      onTap: isFull
          ? null
          : () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StudentDetailKelasScreen(data: data),
                ),
              ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF1565C0).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.person_rounded, color: Color(0xFF1565C0), size: 36),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['title'],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1565C0),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tutor: ${data['tutor']}',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 6),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ...((data['schedules'] as List).take(3).map((s) => _chip(s))),
                        if ((data['schedules'] as List).length > 3)
                          _chip('+${(data['schedules'] as List).length - 3}', isMore: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 12, color: Color(0xFF1565C0)),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          data['address'],
                          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rp${_formatPrice(data['price'])}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1565C0),
                            ),
                          ),
                          Text(
                            '${data['duration']} · ${isFull ? 'Penuh' : '$slotsLeft slot tersisa'}',
                            style: TextStyle(
                              fontSize: 10,
                              color: isFull ? Colors.red : Colors.grey[500],
                              fontWeight: isFull ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFC107)),
                          const SizedBox(width: 2),
                          Text(
                            '${data['rating']} (${data['reviews']})',
                            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                          ),
                          const SizedBox(width: 8),
                          if (!isFull)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1565C0),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Lihat Detail',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Penuh',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, {bool isMore = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isMore ? Colors.grey[200] : const Color(0xFF1565C0).withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: isMore ? Colors.grey[600] : const Color(0xFF1565C0),
        ),
      ),
    );
  }

  String _formatPrice(int price) {
    if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)}.000';
    }
    return price.toString();
  }
}
