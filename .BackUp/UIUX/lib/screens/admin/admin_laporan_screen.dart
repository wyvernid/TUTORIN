import 'package:flutter/material.dart';

class AdminLaporanScreen extends StatefulWidget {
  const AdminLaporanScreen({super.key});

  @override
  State<AdminLaporanScreen> createState() => _AdminLaporanScreenState();
}

class _AdminLaporanScreenState extends State<AdminLaporanScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;

  final List<Map<String, dynamic>> _open = [
    {
      'from': 'Nafisa Nurin', 'fromRole': 'Student',
      'against': 'Bintang Ivanna Cholida', 'againstRole': 'Tutor',
      'category': 'Pembayaran tidak dikonfirmasi',
      'desc': 'Saya sudah transfer 3 hari lalu tapi belum dikonfirmasi juga.',
      'date': '30 Apr 2026', 'status': 'open',
    },
    {
      'from': 'Ahmad Fauzi', 'fromRole': 'Tutor',
      'against': 'Budi Santoso', 'againstRole': 'Student',
      'category': 'Penipuan / Kecurangan',
      'desc': 'Student mengklaim sudah transfer tapi bukti terlihat palsu.',
      'date': '29 Apr 2026', 'status': 'open',
    },
    {
      'from': 'Rizki Pratama', 'fromRole': 'Tutor',
      'against': 'Sari Dewi', 'againstRole': 'Student',
      'category': 'Perilaku tidak pantas',
      'desc': 'Student mengirim pesan yang tidak sopan.',
      'date': '28 Apr 2026', 'status': 'open',
    },
  ];

  final List<Map<String, dynamic>> _resolved = [
    {
      'from': 'Damar Wulan', 'fromRole': 'Student',
      'against': 'Tutor X', 'againstRole': 'Tutor',
      'category': 'Tutor tidak hadir',
      'desc': 'Tutor tidak hadir tanpa pemberitahuan.',
      'date': '20 Apr 2026', 'status': 'resolved',
      'resolution': 'Tutor diperingatkan. Refund diberikan.',
    },
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
        title: const Text('Kelola Laporan'),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tab,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: 'Aktif (${_open.length})'),
            Tab(text: 'Selesai (${_resolved.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _buildList(_open, isOpen: true),
          _buildList(_resolved, isOpen: false),
        ],
      ),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> items, {required bool isOpen}) {
    if (items.isEmpty) {
      return const Center(child: Text('Tidak ada laporan', style: TextStyle(color: Colors.grey)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (ctx, i) => _ReportCard(data: items[i], isOpen: isOpen, onAction: (action) {
        setState(() {
          if (action == 'resolve') {
            _resolved.add({..._open[i], 'status': 'resolved', 'resolution': 'Ditangani oleh admin.'});
            _open.removeAt(i);
          } else if (action == 'dismiss') {
            _open.removeAt(i);
          }
        });
      }),
    );
  }
}

class _ReportCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final bool isOpen;
  final Function(String) onAction;
  const _ReportCard({required this.data, required this.isOpen, required this.onAction});

  @override
  State<_ReportCard> createState() => _ReportCardState();
}

class _ReportCardState extends State<_ReportCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: widget.isOpen ? Colors.red[100]! : Colors.green[100]!),
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: widget.isOpen ? Colors.red[50] : Colors.green[50],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(children: [
                        Icon(widget.isOpen ? Icons.flag_rounded : Icons.check_circle_rounded,
                            size: 12, color: widget.isOpen ? Colors.red[700] : Colors.green[700]),
                        const SizedBox(width: 4),
                        Text(widget.isOpen ? 'Aktif' : 'Selesai',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                                color: widget.isOpen ? Colors.red[700] : Colors.green[700])),
                      ]),
                    ),
                    const Spacer(),
                    Text(d['date'], style: TextStyle(fontSize: 10, color: Colors.grey[400])),
                  ],
                ),
                const SizedBox(height: 10),
                Text(d['category'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                _partyRow(d['from'], d['fromRole'], Icons.arrow_right_alt_rounded, d['against'], d['againstRole']),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => setState(() => _expanded = !_expanded),
                  child: Row(
                    children: [
                      Text(_expanded ? 'Sembunyikan detail' : 'Lihat detail',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF1565C0), fontWeight: FontWeight.w600)),
                      Icon(_expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          color: const Color(0xFF1565C0), size: 16),
                    ],
                  ),
                ),
                if (_expanded) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FA), borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(d['desc'], style: TextStyle(fontSize: 12, color: Colors.grey[700], height: 1.5)),
                  ),
                  if (d['resolution'] != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green[50], borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Row(children: [
                        const Icon(Icons.check_circle_rounded, color: Colors.green, size: 14),
                        const SizedBox(width: 6),
                        Expanded(child: Text(d['resolution'], style: TextStyle(fontSize: 11, color: Colors.green[800]))),
                      ]),
                    ),
                  ],
                ],
              ],
            ),
          ),
          if (widget.isOpen)
            Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () => _showActionDialog(context, 'dismiss'),
                      icon: const Icon(Icons.close_rounded, size: 16, color: Colors.grey),
                      label: const Text('Abaikan', style: TextStyle(color: Colors.grey)),
                    ),
                  ),
                  Container(width: 0.5, height: 40, color: Colors.grey[200]),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () => _showChatButton(context),
                      icon: const Icon(Icons.chat_bubble_outline, size: 16, color: Color(0xFF1565C0)),
                      label: const Text('Hubungi', style: TextStyle(color: Color(0xFF1565C0))),
                    ),
                  ),
                  Container(width: 0.5, height: 40, color: Colors.grey[200]),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () => _showActionDialog(context, 'resolve'),
                      icon: const Icon(Icons.check_rounded, size: 16, color: Colors.green),
                      label: const Text('Selesaikan', style: TextStyle(color: Colors.green)),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _partyRow(String from, String fromRole, IconData arrow, String against, String againstRole) {
    return Row(
      children: [
        _party(from, fromRole, Colors.blue),
        const SizedBox(width: 8),
        Icon(arrow, color: Colors.red, size: 20),
        const SizedBox(width: 8),
        _party(against, againstRole, Colors.orange),
      ],
    );
  }

  Widget _party(String name, String role, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(role, style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.w700)),
          Text(name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
        ]),
      ),
    );
  }

  void _showActionDialog(BuildContext context, String action) {
    final isResolve = action == 'resolve';
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(isResolve ? 'Selesaikan Laporan' : 'Abaikan Laporan',
            style: const TextStyle(fontWeight: FontWeight.w700)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(isResolve ? 'Tulis catatan penyelesaian:' : 'Alasan mengabaikan laporan:'),
          const SizedBox(height: 10),
          TextField(controller: ctrl, maxLines: 3,
              decoration: const InputDecoration(hintText: 'Tulis catatan...')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () { Navigator.pop(context); widget.onAction(action); },
            style: ElevatedButton.styleFrom(backgroundColor: isResolve ? Colors.green : Colors.grey),
            child: Text(isResolve ? 'Selesaikan' : 'Abaikan'),
          ),
        ],
      ),
    );
  }

  void _showChatButton(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Membuka chat dengan pelapor...'), backgroundColor: Color(0xFF1565C0)),
    );
  }
}
