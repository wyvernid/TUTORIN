import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/kelas_model.dart';
import '../../models/booking_model.dart';
import '../../services/kelas_service.dart';
import '../../services/storage_service.dart';

class StudentBookingScreen extends StatefulWidget {
  final KelasModel kelas;
  const StudentBookingScreen({super.key, required this.kelas});
  @override
  State<StudentBookingScreen> createState() => _State();
}

class _State extends State<StudentBookingScreen> {
  final _phoneCtrl    = TextEditingController();
  final _kelasService = KelasService();
  final _storage      = StorageService();

  int?   _selectedIdx;
  int    _step     = 1;
  bool   _loading  = false;
  File?  _buktiBayar;
  String? _bookingId;

  List<Map<String, String>> get _dates {
    const dayNums = {'Senin':1,'Selasa':2,'Rabu':3,'Kamis':4,'Jumat':5,'Sabtu':6,'Minggu':7};
    const months  = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
    final now = DateTime.now();
    final result = <Map<String,String>>[];

    for (final day in widget.kelas.jadwal) {
      final target = dayNums[day] ?? 1;
      for (int w = 0; w < 4; w++) {
        var d = now.add(const Duration(days: 1));
        while (d.weekday != target) d = d.add(const Duration(days: 1));
        d = d.add(Duration(days: 7 * w));
        result.add({
          'day':  day,
          'date': '${d.day} ${months[d.month - 1]} ${d.year}',
          'time': widget.kelas.jamMulai,
        });
      }
    }
    return result;
  }

  Future<void> _createBooking() async {
    final me    = FirebaseAuth.instance.currentUser!;
    final dates = _dates;
    final b = BookingModel(
      id: '',
      kelasId:      widget.kelas.id,
      kelasJudul:   widget.kelas.judul,
      tutorId:      widget.kelas.tutorId,
      tutorNama:    widget.kelas.tutorNama,
      studentId:    me.uid,
      studentNama:  me.displayName ?? me.email ?? '',
      jadwalDipilih: dates[_selectedIdx!]['date']!,
      jamDipilih:    dates[_selectedIdx!]['time']!,
      noTelepon:     _phoneCtrl.text.trim(),
      nominal:       widget.kelas.harga,
      createdAt:     DateTime.now());
    _bookingId = await _kelasService.buatBooking(b);
  }

  Future<void> _uploadAndSubmit() async {
    if (_buktiBayar == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upload bukti pembayaran dulu!')));
      return;
    }
    setState(() => _loading = true);
    try {
      final url = await _storage.uploadBuktiBayar(_bookingId!, _buktiBayar!);
      await _kelasService.uploadBukti(_bookingId!, url);
      if (!mounted) return;
      _showSuccessSheet();
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal upload: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _pickBukti() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4, margin: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
        ListTile(
          leading: const Icon(Icons.camera_alt_rounded, color: Color(0xFF1565C0)),
          title: const Text('Buka Kamera'),
          onTap: () async {
            Navigator.pop(context);
            final f = await _storage.ambilDariKamera();
            if (f != null) setState(() => _buktiBayar = f);
          }),
        ListTile(
          leading: const Icon(Icons.photo_library_rounded, color: Color(0xFF1565C0)),
          title: const Text('Pilih dari Galeri'),
          onTap: () async {
            Navigator.pop(context);
            final f = await _storage.ambilDariGaleri();
            if (f != null) setState(() => _buktiBayar = f);
          }),
        const SizedBox(height: 8),
      ])));
  }

  void _showSuccessSheet() {
    final dates = _dates;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 72, height: 72,
            decoration: BoxDecoration(color: Colors.orange[50], shape: BoxShape.circle),
            child: const Icon(Icons.hourglass_bottom_rounded, color: Colors.orange, size: 38)),
          const SizedBox(height: 16),
          const Text('Bukti Terkirim!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text('Tutor akan memverifikasi dalam 1x24 jam.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          const SizedBox(height: 16),
          Container(width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFFF5F7FA), borderRadius: BorderRadius.circular(12)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Detail Booking', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(widget.kelas.judul,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              Text('Tutor: ${widget.kelas.tutorNama}',
                style: TextStyle(fontSize: 11, color: Colors.grey[600])),
              if (_selectedIdx != null)
                Text(
                  '${dates[_selectedIdx!]['day']}, ${dates[_selectedIdx!]['date']} - ${dates[_selectedIdx!]['time']} WIB',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600])),
            ])),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: OutlinedButton(
              onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF1565C0)),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Ke Beranda', style: TextStyle(fontSize: 13)))),
            const SizedBox(width: 12),
            Expanded(child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 13)),
              child: const Text('Lihat Status', style: TextStyle(fontSize: 13)))),
          ]),
        ])));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF5F7FA),
    appBar: AppBar(
      title: const Text('Booking'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () {
          if (_step > 1) setState(() => _step--);
          else Navigator.pop(context);
        })),
    body: AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: _step == 1 ? _buildStep1()
           : _step == 2 ? _buildStep2()
           : _buildStep3()));

  Widget _buildStep1() {
    final dates = _dates;
    return SingleChildScrollView(
      key: const ValueKey(1),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _stepIndicator(1),
        const SizedBox(height: 20),
        Text(widget.kelas.judul,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text('Tutor: ${widget.kelas.tutorNama}',
          style: TextStyle(fontSize: 13, color: Colors.grey[600])),
        const SizedBox(height: 20),
        const Text('Pilih Jadwal', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text('Pilih salah satu sesi yang tersedia',
          style: TextStyle(fontSize: 11, color: Colors.grey[500])),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, childAspectRatio: 1.05,
            crossAxisSpacing: 8, mainAxisSpacing: 8),
          itemCount: dates.length,
          itemBuilder: (_, i) {
            final sel = _selectedIdx == i;
            return GestureDetector(
              onTap: () => setState(() => _selectedIdx = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: sel ? const Color(0xFF1565C0) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: sel ? const Color(0xFF1565C0) : Colors.grey[300]!),
                  boxShadow: sel ? [BoxShadow(color: const Color(0xFF1565C0).withOpacity(0.3), blurRadius: 8, offset: const Offset(0,3))] : []),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.calendar_month_rounded, size: 18,
                    color: sel ? Colors.white : const Color(0xFF1565C0)),
                  const SizedBox(height: 4),
                  Text(dates[i]['day']!,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                      color: sel ? Colors.white : Colors.grey[800])),
                  Text(dates[i]['date']!,
                    style: TextStyle(fontSize: 8,
                      color: sel ? Colors.white70 : Colors.grey[500]),
                    textAlign: TextAlign.center),
                  Text('${dates[i]['time']!} WIB',
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600,
                      color: sel ? Colors.white : Colors.grey[700])),
                ])));
          }),
        const SizedBox(height: 20),
        const Text('Nomor Telepon yang Bisa Dihubungi',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: _phoneCtrl,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            hintText: '0812xxxxxxxx',
            prefixIcon: Icon(Icons.phone_outlined, size: 20, color: Color(0xFF1565C0)))),
        const SizedBox(height: 28),
        SizedBox(width: double.infinity,
          child: ElevatedButton(
            onPressed: _selectedIdx == null
                ? null
                : () async {
                    if (_phoneCtrl.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Isi nomor telepon dulu!')));
                      return;
                    }
                    setState(() => _loading = true);
                    await _createBooking();
                    setState(() { _loading = false; _step = 2; });
                  },
            child: _loading
                ? const SizedBox(height: 20, width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Lanjut ke Pembayaran',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)))),
      ]));
  }

  Widget _buildStep2() => SingleChildScrollView(
    key: const ValueKey(2),
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _stepIndicator(2),
      const SizedBox(height: 20),
      const Text('Informasi Pembayaran',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
      const SizedBox(height: 16),
      _infoCard(child: Column(children: [
        _payRow('Kelas', widget.kelas.judul),
        const Divider(height: 20),
        _payRow('Tutor', widget.kelas.tutorNama),
        const Divider(height: 20),
        _payRow('Jadwal',
          _selectedIdx != null
              ? '${_dates[_selectedIdx!]['day']}, ${_dates[_selectedIdx!]['date']}'
              : '-'),
        const Divider(height: 20),
        _payRow('Total Bayar', widget.kelas.hargaFormatted, isTotal: true),
      ])),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1565C0).withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1565C0).withOpacity(0.2))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Transfer ke Rekening:',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1565C0))),
          const SizedBox(height: 12),
          _bankRow('BCA', '1234 5678 9012', 'TutorIn Official'),
          const SizedBox(height: 10),
          _bankRow('Mandiri', '0987 6543 2100', 'TutorIn Official'),
          const SizedBox(height: 10),
          _bankRow('GoPay/OVO', '0812-3456-7890', 'TutorIn'),
        ])),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange[200]!)),
        child: Row(children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange[700], size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(
            'Setelah transfer, segera upload bukti agar slot tidak dilepas.',
            style: TextStyle(fontSize: 12, color: Colors.orange[800]))),
        ])),
      const SizedBox(height: 24),
      SizedBox(width: double.infinity,
        child: ElevatedButton(
          onPressed: () => setState(() => _step = 3),
          child: const Text('Sudah Transfer, Upload Bukti',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)))),
    ]));

  Widget _buildStep3() => SingleChildScrollView(
    key: const ValueKey(3),
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _stepIndicator(3),
      const SizedBox(height: 20),
      const Text('Upload Bukti Pembayaran',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
      const SizedBox(height: 6),
      Text('Tutor akan memverifikasi pembayaranmu',
        style: TextStyle(fontSize: 13, color: Colors.grey[600])),
      const SizedBox(height: 20),
      GestureDetector(
        onTap: _pickBukti,
        child: Container(
          width: double.infinity, height: 190,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF1565C0).withOpacity(_buktiBayar != null ? 1 : 0.35),
              width: _buktiBayar != null ? 2 : 1.5)),
          child: _buktiBayar != null
              ? Stack(fit: StackFit.expand, children: [
                  ClipRRect(borderRadius: BorderRadius.circular(14),
                    child: Image.file(_buktiBayar!, fit: BoxFit.cover)),
                  Positioned(top: 8, right: 8,
                    child: GestureDetector(
                      onTap: () => setState(() => _buktiBayar = null),
                      child: Container(width: 28, height: 28,
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        child: const Icon(Icons.close, color: Colors.white, size: 16)))),
                ])
              : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.cloud_upload_outlined, size: 48,
                    color: const Color(0xFF1565C0).withOpacity(0.5)),
                  const SizedBox(height: 10),
                  const Text('Ketuk untuk upload foto bukti transfer',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1565C0))),
                  const SizedBox(height: 4),
                  Text('JPG, PNG, max 5 MB',
                    style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                ]))),
      const SizedBox(height: 16),
      _infoCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Ringkasan Booking',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        _payRow('Kelas', widget.kelas.judul),
        const SizedBox(height: 4),
        _payRow('Tutor', widget.kelas.tutorNama),
        const SizedBox(height: 4),
        _payRow('Total', widget.kelas.hargaFormatted, isTotal: true),
      ])),
      const SizedBox(height: 24),
      SizedBox(width: double.infinity,
        child: ElevatedButton(
          onPressed: _loading ? null : _uploadAndSubmit,
          child: _loading
              ? const SizedBox(height: 20, width: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Kirim Bukti Pembayaran',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)))),
    ]));

  Widget _stepIndicator(int current) => Row(children: List.generate(3, (i) {
    final step = i + 1;
    final done = step < current;
    final active = step == current;
    return Expanded(child: Row(children: [
      Expanded(child: Container(height: 4, decoration: BoxDecoration(
        color: done || active ? const Color(0xFF1565C0) : Colors.grey[300],
        borderRadius: BorderRadius.circular(2)))),
      if (i < 2) const SizedBox(width: 4),
    ]));
  }));

  Widget _infoCard({required Widget child}) => Container(
    width: double.infinity, padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
    child: child);

  Widget _payRow(String label, String value, {bool isTotal = false}) =>
    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      Flexible(child: Text(value,
        textAlign: TextAlign.right,
        style: TextStyle(
          fontSize: isTotal ? 14 : 12,
          fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
          color: isTotal ? const Color(0xFF1565C0) : Colors.grey[800]))),
    ]);

  Widget _bankRow(String bank, String number, String name) => Row(children: [
    Container(width: 44, height: 26,
      decoration: BoxDecoration(color: const Color(0xFF1565C0), borderRadius: BorderRadius.circular(6)),
      child: Center(child: Text(
        bank.length <= 4 ? bank : bank.substring(0, 4),
        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)))),
    const SizedBox(width: 12),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(number, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
      Text('a.n. $name', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
    ])),
    IconButton(
      icon: Icon(Icons.copy_rounded, size: 16, color: Colors.grey[400]),
      onPressed: () {}, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
  ]);
}