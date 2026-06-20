import 'package:flutter/material.dart';
import '../../services/admin_service.dart';
import 'admin_tutor_detail_screen.dart';

class AdminTutorScreen extends StatefulWidget {
  const AdminTutorScreen({super.key});
  @override
  State<AdminTutorScreen> createState() => _State();
}

class _State extends State<AdminTutorScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;
  final _service = AdminService();
  @override
  void initState() { super.initState(); _tab = TabController(length: 2, vsync: this); }
  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  Future<void> _tolak(String uid, String nama) async {
    final alasanCtrl = TextEditingController();
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Tolak $nama?'),
        content: TextField(
          controller: alasanCtrl,
          maxLines: 2,
          decoration: const InputDecoration(
            hintText: 'Alasan penolakan (opsional)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true),
              child: const Text('Tolak', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (konfirmasi != true) return;

    try {
      await _service.tolakTutor(uid, alasan: alasanCtrl.text.trim().isEmpty ? null : alasanCtrl.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$nama ditolak'), backgroundColor: Colors.red));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menolak $nama: $e'), backgroundColor: Colors.red[900]));
    }
  }

  Future<void> _setujui(String uid, String nama) async {
    try {
      await _service.verifikasiTutor(uid);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$nama berhasil diverifikasi!'), backgroundColor: Colors.green));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memverifikasi $nama: $e'), backgroundColor: Colors.red[900]));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF5F7FA),
    appBar: AppBar(title: const Text('Kelola Tutor'), automaticallyImplyLeading: false,
      bottom: TabBar(controller: _tab, labelColor: Colors.white, unselectedLabelColor: Colors.white60,
        indicatorColor: Colors.white,
        tabs: [
          StreamBuilder(stream: _service.streamTutorPending(), builder: (_, s) => Tab(text: 'Pending (${s.data?.length ?? 0})')),
          StreamBuilder(stream: _service.streamTutorVerified(), builder: (_, s) => Tab(text: 'Verified (${s.data?.length ?? 0})')),
        ])),
    body: TabBarView(controller: _tab, children: [
      _buildPending(),
      _buildVerified(),
    ]));

  Widget _buildPending() => StreamBuilder<List<Map<String,dynamic>>>(
    stream: _service.streamTutorPending(),
    builder: (_, snap) {
      if (snap.hasError) {
        return Center(child: Padding(padding: const EdgeInsets.all(20),
          child: Text('Gagal memuat data: ${snap.error}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.red))));
      }
      if (!snap.hasData) return const Center(child: CircularProgressIndicator());
      final list = snap.data!;
      if (list.isEmpty) return const Center(child: Text('Tidak ada tutor pending', style: TextStyle(color: Colors.grey)));
      return ListView.builder(padding: const EdgeInsets.all(14), itemCount: list.length,
        itemBuilder: (_, i) {
          final t = list[i];
          final keahlian = List<String>.from(t['keahlian'] ?? []);
          return InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TutorDetailScreen(tutor: t))),
            child: Container(margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.orange[100]!),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
            child: Column(children: [
              Padding(padding: const EdgeInsets.all(14), child: Row(children: [
                Container(width: 50, height: 50, decoration: BoxDecoration(color: Colors.orange[50], shape: BoxShape.circle),
                  child: t['fotoUrl'] != null ? ClipOval(child: Image.network(t['fotoUrl'], fit: BoxFit.cover)) : Icon(Icons.person_rounded, color: Colors.orange[700], size: 28)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(t['nama'] ?? '', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  Text(t['email'] ?? '', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                  if ((t['pengalaman'] as List? ?? []).isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text((t['pengalaman'] as List).first.toString(), style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                  ],
                  if (keahlian.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(spacing: 4, runSpacing: 4, children: keahlian.map((k) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFF1565C0).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                      child: Text(k, style: const TextStyle(fontSize: 9, color: Color(0xFF1565C0), fontWeight: FontWeight.w600)))).toList()),
                  ],
                ])),
              ])),
              Container(decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFEEEEEE))), borderRadius: BorderRadius.vertical(bottom: Radius.circular(16))),
                child: Row(children: [
                  Expanded(child: TextButton.icon(onPressed: () => _tolak(t['uid'], t['nama'] ?? ''),
                    icon: const Icon(Icons.close_rounded, size: 15, color: Colors.red), label: const Text('Tolak', style: TextStyle(color: Colors.red, fontSize: 12)))),
                  Container(width: 0.5, height: 38, color: Colors.grey[200]),
                  Expanded(child: TextButton.icon(onPressed: () => _setujui(t['uid'], t['nama'] ?? ''),
                    icon: const Icon(Icons.verified_user_rounded, size: 15, color: Colors.green), label: const Text('Setujui', style: TextStyle(color: Colors.green, fontSize: 12)))),
                ])),
            ])));
        });
    });

  Widget _buildVerified() => StreamBuilder<List<Map<String,dynamic>>>(
    stream: _service.streamTutorVerified(),
    builder: (_, snap) {
      if (snap.hasError) {
        return Center(child: Padding(padding: const EdgeInsets.all(20),
          child: Text('Gagal memuat data: ${snap.error}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.red))));
      }
      if (!snap.hasData) return const Center(child: CircularProgressIndicator());
      final list = snap.data!;
      if (list.isEmpty) return const Center(child: Text('Belum ada tutor terverifikasi', style: TextStyle(color: Colors.grey)));
      return ListView.builder(padding: const EdgeInsets.all(14), itemCount: list.length,
        itemBuilder: (_, i) {
          final t = list[i];
          return InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TutorDetailScreen(tutor: t))),
            child: Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 5)]),
            child: Row(children: [
              Container(width: 46, height: 46, decoration: BoxDecoration(color: Colors.green[50], shape: BoxShape.circle),
                child: t['fotoUrl'] != null ? ClipOval(child: Image.network(t['fotoUrl'], fit: BoxFit.cover)) : const Icon(Icons.person_rounded, color: Colors.green, size: 26)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [Text(t['nama'] ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)), const SizedBox(width: 4), const Icon(Icons.verified_rounded, color: Colors.blue, size: 14)]),
                Text(t['email'] ?? '', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                const SizedBox(height: 4),
                Row(children: [
                  _mini(Icons.people_rounded, '${t["totalMurid"] ?? 0} murid'),
                  const SizedBox(width: 10),
                  _mini(Icons.star_rounded, '${(t["rating"] ?? 0.0).toStringAsFixed(1)}', color: Colors.amber),
                ]),
              ])),
              PopupMenuButton<String>(onSelected: (v) async {
                try {
                  if (v == 'suspend') await _service.suspendUser(t['uid']);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tutor disuspend'), backgroundColor: Colors.red));
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red[900]));
                }
              },
                itemBuilder: (_) => [const PopupMenuItem(value: 'suspend', child: Text('Suspend'))],
                child: const Icon(Icons.more_vert_rounded, color: Color(0xFF78909C))),
            ])));
        });
    });

  Widget _mini(IconData icon, String text, {Color? color}) => Row(children: [
    Icon(icon, size: 12, color: color ?? Colors.grey[500]), const SizedBox(width: 3),
    Text(text, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
  ]);
}