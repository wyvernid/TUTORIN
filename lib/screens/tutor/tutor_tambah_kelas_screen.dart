import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:latlong2/latlong.dart';
import '../../services/kelas_service.dart';
import '../../services/auth_service.dart';
import '../../models/kelas_model.dart';
import '../shared/peta_lokasi_screen.dart';

class TutorTambahKelasScreen extends StatefulWidget {
  const TutorTambahKelasScreen({super.key});
  @override
  State<TutorTambahKelasScreen> createState() => _State();
}

class _State extends State<TutorTambahKelasScreen> {
  final _title = TextEditingController(), _desc = TextEditingController();
  final _price = TextEditingController(), _loc = TextEditingController();
  final _service = KelasService(); final _auth = AuthService();
  int _quota = 10; String _duration = '1 jam', _mode = 'offline';
  String? _category; final Set<String> _days = {};
  TimeOfDay _time = const TimeOfDay(hour: 18, minute: 0);
  double? _lat, _lng;
  bool _loading = false;
  final List<String> _tags = [];
  final _tagCtrl = TextEditingController();

  final _categories = ['Algoritma','Basda','Jarkom','PBO','Machine Learning','Mobile Dev','Lainnya'];
  final _dayList = ['Senin','Selasa','Rabu','Kamis','Jumat','Sabtu','Minggu'];
  final _durations = ['30 menit','1 jam','1.5 jam','2 jam'];

  void _save() async {
    if (_title.text.isEmpty || _category == null || _days.isEmpty || _price.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lengkapi semua field wajib'))); return;
    }
    setState(() => _loading = true);
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final userData = await _auth.getUserData(user.uid);
      final kelas = KelasModel(id: '', tutorId: user.uid, tutorNama: userData?.nama ?? user.displayName ?? '',
        tutorFotoUrl: userData?.fotoUrl ?? '', judul: _title.text.trim(), deskripsi: _desc.text.trim(),
        kategori: _category!, harga: int.tryParse(_price.text.replaceAll('.','')) ?? 0, kuota: _quota,
        jadwal: _days.toList(), jamMulai: '${_time.hour}.${_time.minute.toString().padLeft(2, "0")}',
        durasi: _duration, mode: _mode, lokasi: _loc.text.trim(), tags: _tags,
        latitude: _lat ?? -7.9839, longitude: _lng ?? 113.6684, createdAt: DateTime.now());
      await _service.tambahKelas(kelas);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kelas berhasil ditambahkan!'), backgroundColor: Colors.green));
      Navigator.pop(context);
    } finally { if (mounted) setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF5F7FA),
    appBar: AppBar(title: const Text('Tambah Kelas'), leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: () => Navigator.pop(context))),
    bottomNavigationBar: SafeArea(child: Padding(padding: const EdgeInsets.all(14),
      child: ElevatedButton(onPressed: _loading ? null : _save,
        child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text('Simpan Kelas', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700))))),
    body: SingleChildScrollView(padding: const EdgeInsets.all(14), child: Column(children: [
      _card([
        const Text('Informasi Kelas', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        _f('Judul Kelas *', _title, hint: 'Deep Learning untuk Pemula'),
        const SizedBox(height: 10),
        _f('Deskripsi', _desc, hint: 'Jelaskan isi kelas...', lines: 3),
        const SizedBox(height: 10),
        const Text('Kategori *', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Wrap(spacing: 6, runSpacing: 6, children: _categories.map((c) { final s = _category == c; return GestureDetector(onTap: () => setState(() => _category = c), child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: s ? const Color(0xFF1565C0) : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: s ? const Color(0xFF1565C0) : Colors.grey[300]!)), child: Text(c, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: s ? Colors.white : Colors.grey[700])))); }).toList()),
        const SizedBox(height: 10),
        const Text('Tags', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Row(children: [Expanded(child: TextField(controller: _tagCtrl, style: const TextStyle(fontSize: 12), decoration: const InputDecoration(hintText: 'Tambah tag...', contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)))),
          const SizedBox(width: 8), GestureDetector(onTap: () { if (_tagCtrl.text.trim().isNotEmpty) { setState(() { _tags.add(_tagCtrl.text.trim()); _tagCtrl.clear(); }); }}, child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFF1565C0), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.add, color: Colors.white, size: 18)))]),
        if (_tags.isNotEmpty) ...[const SizedBox(height: 6), Wrap(spacing: 4, runSpacing: 4, children: _tags.map((t) => Chip(label: Text(t, style: const TextStyle(fontSize: 10)), backgroundColor: const Color(0xFF1565C0).withOpacity(0.1), deleteIcon: const Icon(Icons.close, size: 12), onDeleted: () => setState(() => _tags.remove(t)), materialTapTargetSize: MaterialTapTargetSize.shrinkWrap)).toList())],
      ]),
      const SizedBox(height: 10),
      _card([
        const Text('Harga & Kuota', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        _f('Harga per Sesi (Rp) *', _price, hint: '45000', type: TextInputType.number),
        const SizedBox(height: 12),
        Row(children: [const Expanded(child: Text('Kuota Murid', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
          IconButton(onPressed: () => setState(() { if (_quota > 1) _quota--; }), icon: const Icon(Icons.remove_circle_outline_rounded, color: Color(0xFF1565C0)), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('$_quota', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1565C0)))),
          IconButton(onPressed: () => setState(() => _quota++), icon: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF1565C0)), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
        ]),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(value: _duration, decoration: InputDecoration(labelText: 'Durasi', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), filled: true, fillColor: const Color(0xFFF5F7FA)),
          items: _durations.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(), onChanged: (v) => setState(() => _duration = v!)),
      ]),
      const SizedBox(height: 10),
      _card([
        const Text('Jadwal *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: _dayList.map((d) { final s = _days.contains(d); return GestureDetector(onTap: () => setState(() { if (s) _days.remove(d); else _days.add(d); }), child: AnimatedContainer(duration: const Duration(milliseconds: 200), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7), decoration: BoxDecoration(color: s ? const Color(0xFF1565C0) : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: s ? const Color(0xFF1565C0) : Colors.grey[300]!)), child: Text(d, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: s ? Colors.white : Colors.grey[700])))); }).toList()),
        const SizedBox(height: 12),
        ListTile(contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.access_time_rounded, color: Color(0xFF1565C0)),
          title: Text('Jam: ${_time.hour}:${_time.minute.toString().padLeft(2, "0")} WIB', style: const TextStyle(fontSize: 13)),
          trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          onTap: () async { final t = await showTimePicker(context: context, initialTime: _time); if (t != null) setState(() => _time = t); }),
      ]),
      const SizedBox(height: 10),
      _card([
        const Text('Mode Pembelajaran', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        Row(children: [
          _modeBtn('offline', Icons.location_on_rounded, 'Offline'),
          const SizedBox(width: 8),
          _modeBtn('online', Icons.videocam_rounded, 'Online'),
          const SizedBox(width: 8),
          _modeBtn('keduanya', Icons.swap_horiz_rounded, 'Keduanya'),
        ]),
        if (_mode != 'online') ...[const SizedBox(height: 10), _f('Lokasi / Alamat', _loc, hint: 'Jln. Kalimantan No.37', icon: Icons.location_on_rounded),
          const SizedBox(height: 8),
          OutlinedButton.icon(onPressed: () async {
            final pos = await Navigator.push<LatLng>(context, MaterialPageRoute(builder: (_) => const PetaLokasiScreen(pickMode: true)));
            if (pos != null) setState(() { _lat = pos.latitude; _lng = pos.longitude; _loc.text = 'Lat: ${pos.latitude.toStringAsFixed(5)}, Lng: ${pos.longitude.toStringAsFixed(5)}'; });
          }, icon: const Icon(Icons.map_rounded, size: 16), label: Text(_lat != null ? 'Lokasi dipilih ✓' : 'Pilih di Peta'),
          style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF1565C0), side: const BorderSide(color: Color(0xFF1565C0))))],
      ]),
      const SizedBox(height: 80),
    ])));

  Widget _card(List<Widget> children) => Container(width: double.infinity, padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children));

  Widget _f(String label, TextEditingController ctrl, {String? hint, int lines = 1, TextInputType? type, IconData? icon}) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
    const SizedBox(height: 5),
    TextField(controller: ctrl, maxLines: lines, keyboardType: type, style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12), prefixIcon: icon != null ? Icon(icon, color: const Color(0xFF1565C0), size: 18) : null)),
  ]);

  Widget _modeBtn(String val, IconData icon, String label) { final s = _mode == val; return Expanded(child: GestureDetector(onTap: () => setState(() => _mode = val), child: AnimatedContainer(duration: const Duration(milliseconds: 200), padding: const EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(color: s ? const Color(0xFF1565C0) : Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: s ? const Color(0xFF1565C0) : Colors.grey[300]!)), child: Column(children: [Icon(icon, size: 18, color: s ? Colors.white : Colors.grey[600]), const SizedBox(height: 4), Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: s ? Colors.white : Colors.grey[600]))]))));  }
}