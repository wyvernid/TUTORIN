import 'package:flutter/material.dart';

class TutorVerifikasiPembayaranScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  const TutorVerifikasiPembayaranScreen({super.key, required this.data});

  @override
  State<TutorVerifikasiPembayaranScreen> createState() => _State();
}

class _State extends State<TutorVerifikasiPembayaranScreen> {
  bool _zoomed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(title: const Text('Verifikasi Pembayaran')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _section(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Detail Booking', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  _row(Icons.person_rounded, 'Murid', widget.data['student']),
                  const SizedBox(height: 8),
                  _row(Icons.class_rounded, 'Kelas', widget.data['kelas']),
                  const SizedBox(height: 8),
                  _row(Icons.calendar_today_rounded, 'Jadwal', widget.data['jadwal']),
                  const SizedBox(height: 8),
                  _row(Icons.attach_money_rounded, 'Nominal', 'Rp${_fmt(widget.data['nominal'])}'),
                  const SizedBox(height: 8),
                  _row(Icons.access_time_rounded, 'Diunggah', widget.data['uploadedAt']),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Text('Bukti Pembayaran', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => setState(() => _zoomed = !_zoomed),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                height: _zoomed ? 300 : 180,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_rounded, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 6),
                    Text(_zoomed ? 'Ketuk untuk perkecil' : 'Ketuk untuk perbesar',
                        style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text('Pastikan nominal dan nama rekening sesuai sebelum verifikasi.',
                style: TextStyle(fontSize: 11, color: Colors.grey[500])),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showRejectDialog(context),
                    icon: const Icon(Icons.close_rounded, size: 18, color: Colors.red),
                    label: const Text('Tolak', style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showConfirmDialog(context),
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text('Konfirmasi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _section({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
      ),
      child: child,
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF1565C0)),
        const SizedBox(width: 8),
        SizedBox(width: 70, child: Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500]))),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
      ],
    );
  }

  void _showConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Konfirmasi Pembayaran', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('Konfirmasi pembayaran dari ${widget.data['student']}?\nSlot kelas akan langsung terkunci.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () { Navigator.pop(context); Navigator.pop(context); },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Ya, Konfirmasi'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Tolak Pembayaran', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Alasan penolakan akan dikirim ke ${widget.data['student']}.'),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'Tulis alasan penolakan...'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () { Navigator.pop(context); Navigator.pop(context); },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Tolak'),
          ),
        ],
      ),
    );
  }

  String _fmt(int v) => v >= 1000 ? '${(v / 1000).toStringAsFixed(0)}.000' : '$v';
}
