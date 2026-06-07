import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/laporan_service.dart';
import '../../services/storage_service.dart';
import '../../models/laporan_model.dart';

class ReportScreen extends StatefulWidget {
  final String targetUid, targetNama, targetRole, myRole;
  const ReportScreen({super.key, required this.targetUid, required this.targetNama, required this.targetRole, required this.myRole});
  @override
  State<ReportScreen> createState() => _State();
}

class _State extends State<ReportScreen> {
  final _desc = TextEditingController();
  final _service = LaporanService();
  final _storage = StorageService();
  String? _kategori, _buktiUrl;
  bool _loading = false, _submitted = false;

  final List<String> _cats = [
    'Pembayaran tidak dikonfirmasi', 'Tutor tidak hadir',
    'Materi tidak sesuai deskripsi', 'Perilaku tidak pantas',
    'Penipuan / Kecurangan', 'Lainnya'];

  void _kirim() async {
    if (_kategori == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih kategori laporan'))); return; }
    setState(() => _loading = true);
    try {
      final me = FirebaseAuth.instance.currentUser!;
      final laporan = LaporanModel(id: '', fromUid: me.uid, fromNama: me.displayName ?? me.email ?? '',
        fromRole: widget.myRole, againstUid: widget.targetUid, againstNama: widget.targetNama,
        againstRole: widget.targetRole, kategori: _kategori!, deskripsi: _desc.text.trim(),
        buktiUrl: _buktiUrl, createdAt: DateTime.now());
      await _service.kirim(laporan);
      setState(() => _submitted = true);
    } finally { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _uploadBukti() async {
    final f = await _storage.ambilDariGaleri();
    if (f == null) return;
    final url = await _storage.uploadBuktiLaporan('laporan_\${DateTime.now().millisecondsSinceEpoch}', f);
    setState(() => _buktiUrl = url);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF5F7FA),
    appBar: AppBar(title: const Text('Laporkan ke Admin'),
      leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: () => Navigator.pop(context))),
    body: _submitted ? _buildSuccess() : _buildForm());

  Widget _buildForm() => SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Container(padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.red[200]!)),
      child: Row(children: [
        Icon(Icons.flag_rounded, color: Colors.red[600], size: 20),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Melaporkan: \${widget.targetNama}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.red[700])),
          Text(widget.targetRole, style: TextStyle(fontSize: 12, color: Colors.red[400])),
        ])),
      ])),
    const SizedBox(height: 20),
    const Text('Kategori Laporan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
    const SizedBox(height: 10),
    ..._cats.map((cat) => GestureDetector(onTap: () => setState(() => _kategori = cat),
      child: AnimatedContainer(duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: _kategori == cat ? const Color(0xFF1565C0).withOpacity(0.06) : Colors.white,
          borderRadius: BorderRadius.circular(12), border: Border.all(color: _kategori == cat ? const Color(0xFF1565C0) : Colors.grey[200]!, width: _kategori == cat ? 1.5 : 1)),
        child: Row(children: [
          Icon(_kategori == cat ? Icons.radio_button_checked : Icons.radio_button_unchecked,
            color: _kategori == cat ? const Color(0xFF1565C0) : Colors.grey[400], size: 20),
          const SizedBox(width: 10),
          Text(cat, style: TextStyle(fontSize: 13, fontWeight: _kategori == cat ? FontWeight.w700 : FontWeight.w400,
            color: _kategori == cat ? const Color(0xFF1565C0) : Colors.grey[700])),
        ])))),
    const SizedBox(height: 16),
    const Text('Deskripsi', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
    const SizedBox(height: 8),
    TextField(controller: _desc, maxLines: 4,
      decoration: InputDecoration(hintText: 'Ceritakan detail kejadian...', hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13), filled: true, fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
        contentPadding: const EdgeInsets.all(14))),
    const SizedBox(height: 10),
    GestureDetector(onTap: _uploadBukti, child: Container(padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
      child: Row(children: [
        Icon(Icons.attach_file_rounded, color: Colors.grey[500], size: 20),
        const SizedBox(width: 8),
        Text(_buktiUrl != null ? 'Bukti terunggah ✓' : 'Lampirkan bukti (opsional)',
          style: TextStyle(fontSize: 13, color: _buktiUrl != null ? Colors.green : Colors.grey[500])),
      ]))),
    const SizedBox(height: 16),
    Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(10)),
      child: Text('⚠️ Laporan palsu dapat mengakibatkan pemblokiran akun.', style: TextStyle(fontSize: 12, color: Colors.orange[800]))),
    const SizedBox(height: 20),
    SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _loading ? null : _kirim,
      style: ElevatedButton.styleFrom(backgroundColor: Colors.red[600]),
      child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : const Text('Kirim Laporan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)))),
  ]));

  Widget _buildSuccess() => Center(child: Padding(padding: const EdgeInsets.all(28), child: Column(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 80, height: 80, decoration: BoxDecoration(color: Colors.green[50], shape: BoxShape.circle),
      child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 44)),
    const SizedBox(height: 20),
    const Text('Laporan Berhasil Dikirim!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
    const SizedBox(height: 10),
    Text('Admin akan meninjau laporan dalam 1x24 jam.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
    const SizedBox(height: 28),
    ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Kembali')),
  ])));
}