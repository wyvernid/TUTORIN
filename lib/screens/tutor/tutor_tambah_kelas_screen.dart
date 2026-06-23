import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:latlong2/latlong.dart';
import '../../services/kelas_service.dart';
import '../../services/auth_service.dart';
import '../../models/kelas_model.dart';
import '../../models/jadwal_sesi_model.dart';
import '../shared/peta_lokasi_screen.dart';

class TutorTambahKelasScreen extends StatefulWidget {
  /// Jika null -> mode tambah kelas baru. Jika diisi -> mode edit kelas.
  final KelasModel? kelas;
  const TutorTambahKelasScreen({super.key, this.kelas});
  @override
  State<TutorTambahKelasScreen> createState() => _State();
}

class _State extends State<TutorTambahKelasScreen> {
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _price = TextEditingController();
  final _loc = TextEditingController();
  final _tagCtrl = TextEditingController();
  final _zoomCtrl = TextEditingController(); // Controller untuk Zoom Link

  final _service = KelasService();
  final _auth = AuthService();

  int _quota = 10;
  String _duration = '1 jam', _mode = 'offline';
  double? _lat, _lng;
  bool _loading = false;
  final List<String> _tags = [];

  /// Daftar jadwal kalender: tiap entri = satu tanggal + daftar jam sesinya.
  final List<JadwalSesi> _jadwalSesi = [];

  final _durations = ['30 menit', '1 jam', '1.5 jam', '2 jam'];

  bool get _isEdit => widget.kelas != null;

  @override
  void initState() {
    super.initState();
    final k = widget.kelas;
    if (k != null) {
      _title.text = k.judul;
      _desc.text = k.deskripsi;
      _price.text = k.harga.toString();
      _loc.text = k.lokasi;
      _zoomCtrl.text = k.zoomLink ?? '';
      _quota = k.kuota;
      _duration = _durations.contains(k.durasi) ? k.durasi : '1 jam';
      _mode = k.mode;
      _tags.addAll(k.tags);
      _lat = k.latitude;
      _lng = k.longitude;
      if (k.jadwalSesi.isNotEmpty) {
        _jadwalSesi.addAll(k.jadwalSesi);
      }
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _price.dispose();
    _loc.dispose();
    _tagCtrl.dispose();
    _zoomCtrl.dispose();
    super.dispose();
  }

  // Jadwal

  void _tambahTanggal() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      helpText: 'Pilih Tanggal Kelas',
    );
    if (picked == null) return;
    final tglOnly = DateTime(picked.year, picked.month, picked.day);
    final existingIdx = _jadwalSesi.indexWhere((j) =>
        j.tanggal.year == tglOnly.year &&
        j.tanggal.month == tglOnly.month &&
        j.tanggal.day == tglOnly.day);
    if (existingIdx != -1) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Tanggal ini sudah ditambahkan, tambahkan jam di kartu yang sudah ada')));
      }
      return;
    }
    setState(() {
      _jadwalSesi.add(JadwalSesi(tanggal: tglOnly, jamList: []));
      _jadwalSesi.sort((a, b) => a.tanggal.compareTo(b.tanggal));
    });
  }

  void _tambahJam(int idx) async {
    final t = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 14, minute: 0),
        helpText: 'Pilih Jam Sesi');
    if (t == null) return;
    final jamStr =
        '${t.hour.toString().padLeft(2, "0")}:${t.minute.toString().padLeft(2, "0")}';
    setState(() {
      final j = _jadwalSesi[idx];
      if (j.jamList.contains(jamStr)) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Jam ini sudah ada di tanggal tersebut')));
        return;
      }
      final newJamList = [...j.jamList, jamStr]..sort();
      _jadwalSesi[idx] = JadwalSesi(tanggal: j.tanggal, jamList: newJamList);
    });
  }

  void _hapusJam(int idx, String jam) {
    setState(() {
      final j = _jadwalSesi[idx];
      final newJamList = j.jamList.where((x) => x != jam).toList();
      _jadwalSesi[idx] = JadwalSesi(tanggal: j.tanggal, jamList: newJamList);
    });
  }

  void _hapusTanggal(int idx) => setState(() => _jadwalSesi.removeAt(idx));

  // Simpan

  void _save() async {
    final adaJamKosong = _jadwalSesi.any((j) => j.jamList.isEmpty);
    if (_title.text.isEmpty || _jadwalSesi.isEmpty || _price.text.isEmpty || adaJamKosong) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_jadwalSesi.isEmpty
              ? 'Tambahkan minimal 1 tanggal kelas'
              : adaJamKosong
                  ? 'Setiap tanggal harus punya minimal 1 jam sesi'
                  : 'Lengkapi semua field wajib')));
      return;
    }
    setState(() => _loading = true);
    try {
      final harga = int.tryParse(_price.text.replaceAll('.', '')) ?? 0;
      final zoomLink = _zoomCtrl.text.trim().isEmpty ? null : _zoomCtrl.text.trim();

      if (!_isEdit) {
        final user = FirebaseAuth.instance.currentUser!;
        final userData = await _auth.getUserData(user.uid);
        final kelas = KelasModel(
          id: '',
          tutorId: user.uid,
          tutorNama: userData?.nama ?? user.displayName ?? '',
          tutorFotoUrl: userData?.fotoUrl ?? '',
          judul: _title.text.trim(),
          deskripsi: _desc.text.trim(),
          harga: harga,
          kuota: _quota,
          jadwalSesi: _jadwalSesi,
          durasi: _duration,
          mode: _mode,
          lokasi: _loc.text.trim(),
          zoomLink: zoomLink,
          tags: _tags,
          latitude: _lat ?? -7.9839,
          longitude: _lng ?? 113.6684,
          createdAt: DateTime.now(),
        );
        await _service.tambahKelas(kelas);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kelas berhasil ditambahkan!'), backgroundColor: Colors.green));
        Navigator.pop(context);
      } else {
        await _service.updateKelas(widget.kelas!.id, {
          'judul': _title.text.trim(),
          'deskripsi': _desc.text.trim(),
          'harga': harga,
          'kuota': _quota,
          'jadwalSesi': _jadwalSesi.map((j) => j.toMap()).toList(),
          'durasi': _duration,
          'mode': _mode,
          'lokasi': _loc.text.trim(),
          'zoomLink': zoomLink,
          'tags': _tags,
          'latitude': _lat ?? widget.kelas!.latitude,
          'longitude': _lng ?? widget.kelas!.longitude,
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kelas berhasil diperbarui!'), backgroundColor: Colors.green));
        Navigator.pop(context, true);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // Build 

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          title: Text(_isEdit ? 'Edit Kelas' : 'Tambah Kelas'),
          leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Navigator.pop(context)),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: ElevatedButton(
              onPressed: _loading ? null : _save,
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(_isEdit ? 'Update Kelas' : 'Simpan Kelas',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(14),
          child: Column(children: [

            // Card 1: Informasi Kelas
            _card([
              const Text('Informasi Kelas',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              _f('Judul Kelas *', _title, hint: 'Deep Learning untuk Pemula'),
              const SizedBox(height: 10),
              _f('Deskripsi', _desc, hint: 'Jelaskan isi kelas...', lines: 3),
              const SizedBox(height: 10),

              // Tags
              const Text('Tags',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text('Tambahkan topik relevan dengan kelasmu',
                  style: TextStyle(fontSize: 10, color: Colors.grey[500])),
              const SizedBox(height: 6),
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: _tagCtrl,
                    style: const TextStyle(fontSize: 12),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _addTag(),
                    decoration: const InputDecoration(
                      hintText: 'Contoh: Machine Learning, Python...',
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _addTag,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: const Color(0xFF1565C0),
                        borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.add, color: Colors.white, size: 18),
                  ),
                ),
              ]),
              if (_tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: _tags
                      .map((t) => Chip(
                            label: Text(t, style: const TextStyle(fontSize: 10)),
                            backgroundColor: const Color(0xFF1565C0).withOpacity(0.1),
                            deleteIcon: const Icon(Icons.close, size: 12),
                            onDeleted: () => setState(() => _tags.remove(t)),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ))
                      .toList(),
                ),
              ],
            ]),
            const SizedBox(height: 10),

            // Card 2: Harga & Kuota
            _card([
              const Text('Harga & Kuota',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              _f('Harga per Sesi (Rp) *', _price,
                  hint: '45000', type: TextInputType.number),
              const SizedBox(height: 12),
              Row(children: [
                const Expanded(
                    child: Text('Kuota Murid',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600))),
                IconButton(
                    onPressed: () =>
                        setState(() { if (_quota > 1) _quota--; }),
                    icon: const Icon(Icons.remove_circle_outline_rounded,
                        color: Color(0xFF1565C0)),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints()),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('$_quota',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1565C0)))),
                IconButton(
                    onPressed: () => setState(() => _quota++),
                    icon: const Icon(Icons.add_circle_outline_rounded,
                        color: Color(0xFF1565C0)),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints()),
              ]),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _duration,
                decoration: InputDecoration(
                    labelText: 'Durasi per sesi',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                    filled: true,
                    fillColor: const Color(0xFFF5F7FA)),
                items: _durations
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (v) => setState(() => _duration = v!),
              ),
            ]),
            const SizedBox(height: 10),

            // Card 3: Jadwal
            _card([
              Row(children: [
                const Expanded(
                    child: Text('Jadwal Kelas *',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700))),
                TextButton.icon(
                  onPressed: _tambahTanggal,
                  icon: const Icon(Icons.add_circle_rounded, size: 16),
                  label: const Text('Tambah Tanggal',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF1565C0),
                      padding: EdgeInsets.zero),
                ),
              ]),
              const SizedBox(height: 2),
              Text(
                'Pilih tanggal di kalender, lalu tambahkan satu atau lebih jam sesi.',
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
              const SizedBox(height: 10),
              if (_jadwalSesi.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(12)),
                  child: Column(children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 28, color: Colors.grey[400]),
                    const SizedBox(height: 6),
                    Text('Belum ada tanggal ditambahkan',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                  ]),
                )
              else
                ..._jadwalSesi.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final j = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!)),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            const Icon(Icons.calendar_month_rounded,
                                size: 16, color: Color(0xFF1565C0)),
                            const SizedBox(width: 6),
                            Expanded(
                                child: Text(j.tanggalFormatted,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700))),
                            GestureDetector(
                              onTap: () => _hapusTanggal(idx),
                              child: Icon(Icons.delete_outline_rounded,
                                  size: 18, color: Colors.red[400]),
                            ),
                          ]),
                          const SizedBox(height: 8),
                          Wrap(spacing: 6, runSpacing: 6, children: [
                            ...j.jamList.map((jam) => Chip(
                                label: Text('$jam WIB',
                                    style: const TextStyle(fontSize: 11)),
                                backgroundColor:
                                    const Color(0xFF1565C0).withOpacity(0.1),
                                deleteIcon: const Icon(Icons.close, size: 13),
                                onDeleted: () => _hapusJam(idx, jam),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact)),
                            ActionChip(
                                avatar: const Icon(Icons.add,
                                    size: 14, color: Color(0xFF1565C0)),
                                label: const Text('Tambah Jam',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF1565C0))),
                                onPressed: () => _tambahJam(idx),
                                backgroundColor: Colors.white,
                                side: const BorderSide(
                                    color: Color(0xFF1565C0)),
                                visualDensity: VisualDensity.compact),
                          ]),
                          if (j.jamList.isEmpty) ...[
                            const SizedBox(height: 4),
                            Text('Belum ada jam, tambahkan minimal 1',
                                style: TextStyle(
                                    fontSize: 10, color: Colors.red[400])),
                          ],
                        ]),
                  );
                }),
            ]),
            const SizedBox(height: 10),

            // Card 4: Mode & Lokasi
            _card([
              const Text('Mode & Lokasi',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Row(children: [
                _modeBtn('offline', Icons.location_on_rounded, 'Offline'),
                const SizedBox(width: 8),
                _modeBtn('online', Icons.videocam_rounded, 'Online'),
                const SizedBox(width: 8),
                _modeBtn('keduanya', Icons.swap_horiz_rounded, 'Keduanya'),
              ]),
              
              // Tampilkan ZOOM jika Mode Online / Keduanya
              if (_mode == 'online' || _mode == 'keduanya') ...[
                const SizedBox(height: 16),
                _f('Link Zoom / Meeting (opsional)', _zoomCtrl,
                    hint: 'https://zoom.us/j/xxxxxxxxx',
                    icon: Icons.video_camera_front_rounded),
                const SizedBox(height: 4),
                Text(
                  'Diperlukan untuk kelas online.',
                  style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                ),
              ],

              // Tampilkan LOKASI jika Mode Offline / Keduanya
              if (_mode != 'online') ...[
                const SizedBox(height: 16),
                _f('Alamat Lokasi', _loc,
                    hint: 'Jln. Kalimantan No.37', icon: Icons.location_on_rounded),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () async {
                    // Menggunakan logika yang berjalan mulus dari kode pertama
                    final result = await Navigator.push<Map<String, dynamic>>(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const PetaLokasiScreen(
                                pickMode: true)));
                    if (result != null && result['latlng'] != null) {
                      final pos = result['latlng'] as LatLng;
                      final alamat = result['alamat'] as String?;
                      setState(() {
                        _lat = pos.latitude;
                        _lng = pos.longitude;
                        _loc.text = (alamat != null &&
                                alamat.isNotEmpty &&
                                alamat != 'Alamat tidak ditemukan' &&
                                alamat != 'Gagal memuat alamat')
                            ? alamat
                            : 'Lat: ${pos.latitude.toStringAsFixed(5)}, Lng: ${pos.longitude.toStringAsFixed(5)}';
                      });
                    }
                  },
                  icon: const Icon(Icons.map_rounded, size: 16),
                  label: Text(_lat != null ? 'Lokasi dipilih ✓' : 'Pilih di Peta'),
                  style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1565C0),
                      side: const BorderSide(color: Color(0xFF1565C0))),
                ),
              ],
            ]),
            const SizedBox(height: 80),
          ]),
        ),
      );

  // Helpers

  void _addTag() {
    final t = _tagCtrl.text.trim();
    if (t.isNotEmpty && !_tags.contains(t)) {
      setState(() {
        _tags.add(t);
        _tagCtrl.clear();
      });
    }
  }

  Widget _card(List<Widget> children) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)
            ]),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: children));

  Widget _f(String label, TextEditingController ctrl,
          {String? hint,
          int lines = 1,
          TextInputType? type,
          IconData? icon}) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(height: 5),
        TextField(
          controller: ctrl,
          maxLines: lines,
          keyboardType: type,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
            prefixIcon: icon != null
                ? Icon(icon, color: const Color(0xFF1565C0), size: 18)
                : null,
          ),
        ),
      ]);

  Widget _modeBtn(String val, IconData icon, String label) {
    final s = _mode == val;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _mode = val),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
              color: s ? const Color(0xFF1565C0) : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: s ? const Color(0xFF1565C0) : Colors.grey[300]!)),
          child: Column(children: [
            Icon(icon, size: 18, color: s ? Colors.white : Colors.grey[600]),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: s ? Colors.white : Colors.grey[600])),
          ]),
        ),
      ),
    );
  }
}