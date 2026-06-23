import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/laporan_service.dart';
import '../../models/laporan_model.dart';
import '../shared/chat_room_screen.dart';

class AdminLaporanScreen extends StatefulWidget {
  const AdminLaporanScreen({super.key});
  @override
  State<AdminLaporanScreen> createState() => _State();
}

class _State extends State<AdminLaporanScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;
  final _service = LaporanService();

  @override
  void initState() { super.initState(); _tab = TabController(length: 2, vsync: this); }
  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF5F7FA),
    appBar: AppBar(title: const Text('Kelola Laporan'), automaticallyImplyLeading: false,
      bottom: TabBar(controller: _tab, labelColor: Colors.white, unselectedLabelColor: Colors.white60,
        indicatorColor: Colors.white, tabs: const [Tab(text: 'Aktif'), Tab(text: 'Selesai')])),
    body: TabBarView(controller: _tab, children: [
      _buildTab(_service.streamAktif(), true),
      _buildTab(_service.streamSelesai(), false),
    ]));

  Widget _buildTab(Stream<List<LaporanModel>> stream, bool isOpen) => StreamBuilder<List<LaporanModel>>(
    stream: stream,
    builder: (_, snap) {
      if (!snap.hasData) return const Center(child: CircularProgressIndicator());
      final items = snap.data!;
      if (items.isEmpty) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.check_circle_outline, size: 48, color: Colors.grey[300]), const SizedBox(height: 8),
        Text(isOpen ? 'Tidak ada laporan aktif' : 'Belum ada laporan selesai', style: TextStyle(color: Colors.grey[400]))]));
      return ListView.builder(padding: const EdgeInsets.all(14), itemCount: items.length,
        itemBuilder: (_, i) => _LaporanCard(laporan: items[i], isOpen: isOpen, service: _service));
    });
}

class _LaporanCard extends StatefulWidget {
  final LaporanModel laporan; final bool isOpen; final LaporanService service;
  const _LaporanCard({required this.laporan, required this.isOpen, required this.service});
  @override
  State<_LaporanCard> createState() => _LaporanCardState();
}

class _LaporanCardState extends State<_LaporanCard> {
  bool _expanded = false;

  void _bukaChat({
    required String peerUid,
    required String peerNama,
    required String peerRole,
  }) {
    final me = FirebaseAuth.instance.currentUser;
    if (me == null) return;
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => ChatRoomScreen(
        peerUid: peerUid,
        peerNama: peerNama,
        peerRole: peerRole,
        myRole: 'admin',
      )));
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.laporan;
    return Container(margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: widget.isOpen ? Colors.red[100]! : Colors.green[100]!),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        //  Konten utama card 
        Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: widget.isOpen ? Colors.red[50] : Colors.green[50], borderRadius: BorderRadius.circular(20)),
              child: Row(children: [
                Icon(widget.isOpen ? Icons.flag_rounded : Icons.check_circle_rounded, size: 11, color: widget.isOpen ? Colors.red[700] : Colors.green[700]),
                const SizedBox(width: 4),
                Text(widget.isOpen ? 'Aktif' : 'Selesai', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: widget.isOpen ? Colors.red[700] : Colors.green[700])),
              ])),
            const Spacer(),
            Text('${l.createdAt.day}/${l.createdAt.month}/${l.createdAt.year}', style: TextStyle(fontSize: 10, color: Colors.grey[400])),
          ]),
          const SizedBox(height: 10),
          Text(l.kategori, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),

          // Pelapor → Terlapor
          Row(children: [
            Expanded(child: Container(padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.07), borderRadius: BorderRadius.circular(8)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(l.fromRole, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFF1565C0))),
                Text(l.fromNama, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
              ]))),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: Icon(Icons.arrow_right_alt_rounded, color: Colors.red)),
            Expanded(child: Container(padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.orange.withOpacity(0.07), borderRadius: BorderRadius.circular(8)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(l.againstRole, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.orange)),
                Text(l.againstNama, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
              ]))),
          ]),
          const SizedBox(height: 8),

          GestureDetector(onTap: () => setState(() => _expanded = !_expanded),
            child: Row(children: [
              Text(_expanded ? 'Sembunyikan' : 'Lihat detail', style: const TextStyle(fontSize: 11, color: Color(0xFF1565C0), fontWeight: FontWeight.w600)),
              Icon(_expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: const Color(0xFF1565C0), size: 16),
            ])),

          if (_expanded) ...[
            const SizedBox(height: 8),
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFFF5F7FA), borderRadius: BorderRadius.circular(10)),
              child: Text(l.deskripsi, style: TextStyle(fontSize: 12, color: Colors.grey[700], height: 1.5))),
            if (l.buktiUrl != null) ...[
              const SizedBox(height: 10),
              Text('Bukti dari ${l.fromNama}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.grey[600])),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => _FullImageViewer(imageUrl: l.buktiUrl!), fullscreenDialog: true)),
                child: Container(width: double.infinity, height: 160,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey[300]!)),
                  child: Stack(fit: StackFit.expand, children: [
                    ClipRRect(borderRadius: BorderRadius.circular(9),
                      child: Image.network(l.buktiUrl!, fit: BoxFit.cover,
                        loadingBuilder: (_, child, progress) => progress == null ? child : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        errorBuilder: (_, __, ___) => Center(child: Icon(Icons.broken_image_rounded, color: Colors.grey[400])))),
                    Positioned(right: 6, bottom: 6, child: Container(padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: Colors.black.withOpacity(0.55), borderRadius: BorderRadius.circular(6)),
                      child: const Icon(Icons.zoom_in_rounded, size: 14, color: Colors.white))),
                  ]))),
            ],
            if (l.catatanAdmin != null) ...[
              const SizedBox(height: 8),
              Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.green[200]!)),
                child: Row(children: [const Icon(Icons.check_circle_rounded, color: Colors.green, size: 14), const SizedBox(width: 6), Expanded(child: Text(l.catatanAdmin!, style: TextStyle(fontSize: 11, color: Colors.green[800])))])),
            ],
          ],
        ])),

        const Divider(height: 1, color: Color(0xFFEEEEEE)),

        IntrinsicHeight(
          child: Row(children: [
            Expanded(child: TextButton.icon(
              onPressed: () => _bukaChat(
                peerUid: l.fromUid,
                peerNama: l.fromNama,
                peerRole: l.fromRole,
              ),
              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 14, color: Color(0xFF1565C0)),
              label: Text('Chat ${_labelRole(l.fromRole)}', style: const TextStyle(color: Color(0xFF1565C0), fontSize: 11)),
            )),
            VerticalDivider(width: 1, color: Colors.grey[200]),
            Expanded(child: TextButton.icon(
              onPressed: () => _bukaChat(
                peerUid: l.againstUid,
                peerNama: l.againstNama,
                peerRole: l.againstRole,
              ),
              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 14, color: Colors.orange),
              label: Text('Chat ${_labelRole(l.againstRole)}', style: const TextStyle(color: Colors.orange, fontSize: 11)),
            )),
          ]),
        ),

        if (widget.isOpen) ...[
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
            child: Row(children: [
              Expanded(child: TextButton.icon(onPressed: () => _doAction('dismiss'),
                icon: const Icon(Icons.close_rounded, size: 15, color: Colors.grey), label: const Text('Abaikan', style: TextStyle(color: Colors.grey, fontSize: 12)))),
              Container(width: 0.5, height: 38, color: Colors.grey[200]),
              Expanded(child: TextButton.icon(onPressed: () => _doAction('resolve'),
                icon: const Icon(Icons.check_rounded, size: 15, color: Colors.green), label: const Text('Selesaikan', style: TextStyle(color: Colors.green, fontSize: 12)))),
            ]),
          ),
        ],

      ]));
  }

  String _labelRole(String role) {
    switch (role) {
      case 'student': return 'Student';
      case 'tutor':   return 'Tutor';
      default:        return role;
    }
  }

  void _doAction(String action) {
    final ctrl = TextEditingController();
    showDialog(context: context, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(action == 'resolve' ? 'Selesaikan Laporan' : 'Abaikan Laporan', style: const TextStyle(fontWeight: FontWeight.w700)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(action == 'resolve' ? 'Tulis catatan penyelesaian:' : 'Alasan mengabaikan:'),
        const SizedBox(height: 10),
        TextField(controller: ctrl, maxLines: 3, decoration: const InputDecoration(hintText: 'Tulis catatan...')),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context);
            if (action == 'resolve') await widget.service.selesaikan(widget.laporan.id, ctrl.text.trim());
            else await widget.service.abaikan(widget.laporan.id, ctrl.text.trim());
          },
          style: ElevatedButton.styleFrom(backgroundColor: action == 'resolve' ? Colors.green : Colors.grey),
          child: Text(action == 'resolve' ? 'Selesaikan' : 'Abaikan')),
      ]));
  }
}

class _FullImageViewer extends StatefulWidget {
  final String imageUrl;
  const _FullImageViewer({required this.imageUrl});
  @override
  State<_FullImageViewer> createState() => _FullImageViewerState();
}

class _FullImageViewerState extends State<_FullImageViewer> {
  final _transformCtrl = TransformationController();
  TapDownDetails? _doubleTapDetails;

  void _onDoubleTap() {
    final pos = _doubleTapDetails?.localPosition;
    if (_transformCtrl.value != Matrix4.identity()) {
      _transformCtrl.value = Matrix4.identity();
    } else if (pos != null) {
      _transformCtrl.value = Matrix4.identity()
        ..translate(-pos.dx * 2, -pos.dy * 2)
        ..scale(3.0);
    }
  }

  @override
  void dispose() { _transformCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    appBar: AppBar(backgroundColor: Colors.black, elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      title: const Text('Bukti Laporan', style: TextStyle(color: Colors.white, fontSize: 14))),
    body: GestureDetector(
      onDoubleTapDown: (d) => _doubleTapDetails = d,
      onDoubleTap: _onDoubleTap,
      child: InteractiveViewer(
        transformationController: _transformCtrl,
        minScale: 1, maxScale: 5,
        child: Center(child: Image.network(widget.imageUrl, fit: BoxFit.contain,
          loadingBuilder: (context, child, progress) => progress == null ? child : const Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator(color: Colors.white)),
          errorBuilder: (context, error, stack) => const Padding(padding: EdgeInsets.all(24), child: Text('Gagal memuat gambar', style: TextStyle(color: Colors.white)))))),
    ));
}