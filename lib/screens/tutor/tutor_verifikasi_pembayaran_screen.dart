import 'package:flutter/material.dart';
import '../../models/booking_model.dart';
import '../../services/kelas_service.dart';

class TutorVerifikasiPembayaranScreen extends StatefulWidget {
  final BookingModel booking;
  const TutorVerifikasiPembayaranScreen({super.key, required this.booking});
  @override
  State<TutorVerifikasiPembayaranScreen> createState() => _State();
}

class _State extends State<TutorVerifikasiPembayaranScreen> {
  final _service = KelasService();
  bool _loading = false, _zoomed = false;

  void _konfirmasi() async {
    setState(() => _loading = true);
    try {
      await _service.konfirmasi(widget.booking.id, widget.booking.kelasId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pembayaran dikonfirmasi!'), backgroundColor: Colors.green));
      Navigator.pop(context);
    } finally { if (mounted) setState(() => _loading = false); }
  }

  void _tolak() {
    final ctrl = TextEditingController();
    showDialog(context: context, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Tolak Pembayaran', style: TextStyle(fontWeight: FontWeight.w700)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('Alasan akan dikirim ke \${widget.booking.studentNama}.'),
        const SizedBox(height: 12),
        TextField(controller: ctrl, maxLines: 3, decoration: const InputDecoration(hintText: 'Tulis alasan penolakan...')),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        ElevatedButton(onPressed: () async {
          Navigator.pop(context);
          setState(() => _loading = true);
          await _service.tolak(widget.booking.id, ctrl.text.trim());
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pembayaran ditolak'), backgroundColor: Colors.red));
          Navigator.pop(context);
        }, style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Tolak'))],
    ));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF5F7FA),
    appBar: AppBar(title: const Text('Verifikasi Pembayaran'),
      leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: () => Navigator.pop(context))),
    body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Detail Booking', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        _row(Icons.person_rounded, 'Murid', widget.booking.studentNama),
        const SizedBox(height: 8),
        _row(Icons.class_rounded, 'Kelas', widget.booking.kelasJudul),
        const SizedBox(height: 8),
        _row(Icons.calendar_today_rounded, 'Jadwal', '\${widget.booking.jadwalDipilih} · \${widget.booking.jamDipilih}'),
        const SizedBox(height: 8),
        _row(Icons.attach_money_rounded, 'Nominal', 'Rp\${(widget.booking.nominal/1000).toStringAsFixed(0)}.000'),
      ])),
      const SizedBox(height: 14),
      const Text('Bukti Pembayaran', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      GestureDetector(onTap: () => setState(() => _zoomed = !_zoomed),
        child: AnimatedContainer(duration: const Duration(milliseconds: 300), width: double.infinity, height: _zoomed ? 300 : 180,
          decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey[300]!)),
          child: widget.booking.buktiBayarUrl != null
              ? ClipRRect(borderRadius: BorderRadius.circular(13), child: Image.network(widget.booking.buktiBayarUrl!, fit: BoxFit.cover))
              : Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.image_rounded, size: 44, color: Colors.grey[400]), Text(_zoomed ? 'Ketuk untuk perkecil' : 'Memuat bukti...', style: TextStyle(fontSize: 11, color: Colors.grey[400]))]))),
      const SizedBox(height: 8),
      Text('Pastikan nominal & rekening sesuai sebelum konfirmasi.', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
      const SizedBox(height: 20),
      Row(children: [
        Expanded(child: OutlinedButton.icon(onPressed: _loading ? null : _tolak,
          icon: const Icon(Icons.close_rounded, size: 17, color: Colors.red),
          label: const Text('Tolak', style: TextStyle(color: Colors.red)),
          style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
        const SizedBox(width: 12),
        Expanded(child: ElevatedButton.icon(onPressed: _loading ? null : _konfirmasi,
          icon: _loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.check_rounded, size: 18),
          label: const Text('Konfirmasi'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
      ]),
    ])));

  Widget _card({required Widget child}) => Container(width: double.infinity, padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
    child: child);

  Widget _row(IconData icon, String label, String value) => Row(children: [
    Icon(icon, size: 15, color: const Color(0xFF1565C0)), const SizedBox(width: 8),
    SizedBox(width: 65, child: Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500]))),
    Expanded(child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
  ]);
}