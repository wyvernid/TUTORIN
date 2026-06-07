import 'package:flutter/material.dart';

class TutorTambahKelasScreen extends StatefulWidget {
  const TutorTambahKelasScreen({super.key});

  @override
  State<TutorTambahKelasScreen> createState() => _State();
}

class _State extends State<TutorTambahKelasScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  int _quota = 10;
  String _duration = '1 jam';
  final Set<String> _selectedDays = {};

  final List<String> _days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
  final List<String> _durations = ['30 menit', '1 jam', '1.5 jam', '2 jam'];
  final List<String> _categories = ['Algoritma', 'Basda', 'Jarkom', 'PBO', 'Machine Learning', 'Mobile Dev', 'Lainnya'];
  String? _selectedCategory;
  String _mode = 'offline'; // offline / online / keduanya

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Tambah Kelas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Simpan Kelas', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _card(children: [
              const Text('Informasi Kelas', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 14),
              _field('Judul Kelas', _titleCtrl, hint: 'Contoh: Deep Learning untuk Pemula'),
              const SizedBox(height: 12),
              _field('Deskripsi', _descCtrl, hint: 'Jelaskan isi kelas, benefit, dsb...', maxLines: 3),
              const SizedBox(height: 12),
              const Text('Kategori', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6, runSpacing: 6,
                children: _categories.map((c) {
                  final sel = _selectedCategory == c;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = c),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: sel ? const Color(0xFF1565C0) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: sel ? const Color(0xFF1565C0) : Colors.grey[300]!),
                      ),
                      child: Text(c, style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600,
                        color: sel ? Colors.white : Colors.grey[700],
                      )),
                    ),
                  );
                }).toList(),
              ),
            ]),
            const SizedBox(height: 12),
            _card(children: [
              const Text('Harga & Kuota', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 14),
              _field('Harga per Sesi (Rp)', _priceCtrl, hint: '45000', keyboardType: TextInputType.number,
                  prefix: const Text('Rp ', style: TextStyle(color: Color(0xFF1565C0), fontWeight: FontWeight.w700))),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Expanded(child: Text('Kuota Murid', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                  IconButton(
                    onPressed: () => setState(() { if (_quota > 1) _quota--; }),
                    icon: const Icon(Icons.remove_circle_outline_rounded, color: Color(0xFF1565C0)),
                    padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  Text('$_quota', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1565C0))),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => setState(() => _quota++),
                    icon: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF1565C0)),
                    padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _duration,
                decoration: InputDecoration(
                  labelText: 'Durasi per Sesi',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  filled: true, fillColor: const Color(0xFFF5F7FA),
                ),
                items: _durations.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                onChanged: (v) => setState(() => _duration = v!),
              ),
            ]),
            const SizedBox(height: 12),
            _card(children: [
              const Text('Jadwal Tersedia', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('Pilih hari yang kamu tersedia', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: _days.map((day) {
                  final sel = _selectedDays.contains(day);
                  return GestureDetector(
                    onTap: () => setState(() {
                      if (sel) _selectedDays.remove(day); else _selectedDays.add(day);
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel ? const Color(0xFF1565C0) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: sel ? const Color(0xFF1565C0) : Colors.grey[300]!),
                      ),
                      child: Text(day, style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600,
                        color: sel ? Colors.white : Colors.grey[700],
                      )),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              TextField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Jam Mulai',
                  suffixIcon: const Icon(Icons.access_time_rounded, color: Color(0xFF1565C0)),
                  filled: true, fillColor: const Color(0xFFF5F7FA),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                onTap: () async {
                  await showTimePicker(context: context, initialTime: TimeOfDay.now());
                },
              ),
            ]),
            const SizedBox(height: 12),
            _card(children: [
              const Text('Mode Pembelajaran', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Row(
                children: [
                  _modeBtn('offline', Icons.location_on_rounded, 'Offline'),
                  const SizedBox(width: 8),
                  _modeBtn('online', Icons.videocam_rounded, 'Online'),
                  const SizedBox(width: 8),
                  _modeBtn('keduanya', Icons.swap_horiz_rounded, 'Keduanya'),
                ],
              ),
              if (_mode != 'online') ...[
                const SizedBox(height: 12),
                _field('Lokasi / Alamat', _locationCtrl, hint: 'Jln. Kalimantan No.37', icon: Icons.location_on_rounded),
              ],
              if (_mode != 'offline') ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1565C0).withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF1565C0).withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Color(0xFF1565C0), size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text('Link Zoom/Meet akan dibagikan ke murid setelah pembayaran dikonfirmasi.',
                            style: TextStyle(fontSize: 11, color: Colors.grey[700])),
                      ),
                    ],
                  ),
                ),
              ],
            ]),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _modeBtn(String value, IconData icon, String label) {
    final sel = _mode == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _mode = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: sel ? const Color(0xFF1565C0) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: sel ? const Color(0xFF1565C0) : Colors.grey[300]!),
          ),
          child: Column(
            children: [
              Icon(icon, size: 18, color: sel ? Colors.white : Colors.grey[600]),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                  color: sel ? Colors.white : Colors.grey[600])),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _field(String label, TextEditingController ctrl, {
    String? hint, int maxLines = 1, TextInputType? keyboardType, Widget? prefix, IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
            prefixText: prefix != null ? null : null,
            prefix: prefix,
            prefixIcon: icon != null ? Icon(icon, color: const Color(0xFF1565C0), size: 18) : null,
          ),
        ),
      ],
    );
  }
}
