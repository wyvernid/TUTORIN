import 'package:flutter/material.dart';
import '../../services/admin_service.dart';
import '../shared/pdf_viewer_screen.dart';


class TutorDetailScreen extends StatefulWidget {
  final Map<String, dynamic> tutor;
  const TutorDetailScreen({super.key, required this.tutor});

  @override
  State<TutorDetailScreen> createState() => _State();
}

class _State extends State<TutorDetailScreen> {
  final _service = AdminService();
  bool _loading = false;

  Future<void> _tolak() async {
    final alasanCtrl = TextEditingController();
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Tolak ${widget.tutor['nama'] ?? ''}?'),
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

    setState(() => _loading = true);
    try {
      await _service.tolakTutor(widget.tutor['uid'],
          alasan: alasanCtrl.text.trim().isEmpty ? null : alasanCtrl.text.trim());
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.tutor['nama']} ditolak'), backgroundColor: Colors.red));
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menolak: $e'), backgroundColor: Colors.red[900]));
    }
  }

  Future<void> _setujui() async {
    setState(() => _loading = true);
    try {
      await _service.verifikasiTutor(widget.tutor['uid']);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.tutor['nama']} berhasil diverifikasi!'), backgroundColor: Colors.green));
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memverifikasi: $e'), backgroundColor: Colors.red[900]));
    }
  }

  void _lihatPdf(String? url, String title) {
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$title belum diupload tutor ini')));
      return;
    }
    Navigator.push(context, MaterialPageRoute(
        builder: (_) => PdfViewerScreen(pdfUrl: url, title: title)));
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tutor;
    final keahlian = List<String>.from(t['keahlian'] ?? []);
    final pengalaman = List<String>.from(t['pengalaman'] ?? []);
    final isVerified = t['isVerified'] == true;
    final isRejected = t['isRejected'] == true;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(title: const Text('Detail Tutor')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // ── Header foto + nama ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
            child: Column(children: [
              Container(width: 72, height: 72,
                decoration: BoxDecoration(color: const Color(0xFF1565C0).withOpacity(0.1), shape: BoxShape.circle),
                child: t['fotoUrl'] != null
                    ? ClipOval(child: Image.network(t['fotoUrl'], fit: BoxFit.cover, width: 72, height: 72))
                    : const Icon(Icons.person_rounded, color: Color(0xFF1565C0), size: 38)),
              const SizedBox(height: 12),
              Text(t['nama'] ?? '-', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(t['email'] ?? '-', style: TextStyle(fontSize: 12.5, color: Colors.grey[500])),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: isRejected ? Colors.red[50] : (isVerified ? Colors.green[50] : Colors.orange[50]),
                  borderRadius: BorderRadius.circular(20)),
                child: Text(
                  isRejected ? 'Ditolak' : (isVerified ? 'Terverifikasi' : 'Pending'),
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700,
                    color: isRejected ? Colors.red : (isVerified ? Colors.green[700] : Colors.orange[700])),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 16),

          // ── Data diri ──
          _sectionTitle('Data Diri'),
          _infoCard([
            _infoRow(Icons.cake_outlined, 'Umur', t['usia'] != null ? '${t['usia']} tahun' : '-'),
            _infoRow(Icons.phone_outlined, 'No. Telepon', t['noTelepon'] ?? '-'),
            _infoRow(Icons.share_outlined, 'Sosial Media', t['sosialMedia'] ?? '-'),
          ]),
          const SizedBox(height: 16),

          // ── Keahlian ──
          _sectionTitle('Keahlian'),
          _infoCard([
            keahlian.isEmpty
                ? Text('Belum diisi', style: TextStyle(fontSize: 13, color: Colors.grey[400]))
                : Wrap(spacing: 6, runSpacing: 6, children: keahlian.map((k) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFF1565C0).withOpacity(0.08), borderRadius: BorderRadius.circular(20)),
                    child: Text(k, style: const TextStyle(fontSize: 12, color: Color(0xFF1565C0), fontWeight: FontWeight.w600)))).toList()),
          ]),
          const SizedBox(height: 16),

          // ── Pengalaman ──
          _sectionTitle('Pengalaman'),
          _infoCard([
            pengalaman.isEmpty
                ? Text('Belum diisi', style: TextStyle(fontSize: 13, color: Colors.grey[400]))
                : Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: pengalaman.map((p) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Icon(Icons.circle, size: 6, color: Color(0xFF1565C0)),
                        const SizedBox(width: 8),
                        Expanded(child: Text(p, style: const TextStyle(fontSize: 13))),
                      ]))).toList()),
          ]),
          const SizedBox(height: 16),

          // ── CV & Portofolio ──
          _sectionTitle('Dokumen Pendukung'),
          _infoCard([
            _dokumenRow(Icons.description_outlined, 'CV', t['cvUrl'],
                () => _lihatPdf(t['cvUrl'], 'Curriculum Vitae')),
            const Divider(height: 18),
            _dokumenRow(Icons.folder_open_outlined, 'Portofolio', t['portofolioUrl'],
                () => _lihatPdf(t['portofolioUrl'], 'Portofolio')),
          ]),

          if (isRejected && (t['alasanTolak'] ?? '').toString().isNotEmpty) ...[
            const SizedBox(height: 16),
            _sectionTitle('Alasan Ditolak'),
            _infoCard([Text(t['alasanTolak'], style: const TextStyle(fontSize: 13, color: Colors.red))]),
          ],

          const SizedBox(height: 90),
        ]),
      ),

      // ── Tombol aksi, hanya muncul kalau belum verified ──
      bottomNavigationBar: isVerified ? null : SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
          child: Row(children: [
            Expanded(child: OutlinedButton.icon(
              onPressed: _loading ? null : _tolak,
              icon: const Icon(Icons.close_rounded, size: 18, color: Colors.red),
              label: const Text('Tolak', style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 13)))),
            const SizedBox(width: 12),
            Expanded(child: ElevatedButton.icon(
              onPressed: _loading ? null : _setujui,
              icon: _loading
                  ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.verified_user_rounded, size: 18),
              label: const Text('Setujui'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 13)))),
          ]),
        ),
      ),
    );
  }

  Widget _sectionTitle(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8, left: 4),
    child: Text(t, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF455A64))));

  Widget _infoCard(List<Widget> children) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 5)]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children));

  Widget _infoRow(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(children: [
      Icon(icon, size: 17, color: Colors.grey[500]),
      const SizedBox(width: 10),
      Text('$label  ', style: TextStyle(fontSize: 12.5, color: Colors.grey[500])),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600))),
    ]));

  Widget _dokumenRow(IconData icon, String label, String? url, VoidCallback onTap) => Row(children: [
    Icon(icon, size: 20, color: const Color(0xFF1565C0)),
    const SizedBox(width: 10),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      Text(url != null && url.isNotEmpty ? 'Tersedia' : 'Belum diupload',
        style: TextStyle(fontSize: 11, color: url != null && url.isNotEmpty ? Colors.green : Colors.grey[400])),
    ])),
    TextButton(onPressed: onTap, child: const Text('Lihat')),
  ]);
}