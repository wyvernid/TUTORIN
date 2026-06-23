import 'package:flutter/material.dart';
import '../../models/ulasan_model.dart';
import '../../services/kelas_service.dart';

class UlasanSection extends StatefulWidget {
  final String kelasId;
  final double ratingAvg;
  final int jumlahUlasan;
  final KelasService service;
  const UlasanSection({super.key, required this.kelasId, required this.ratingAvg, required this.jumlahUlasan, required this.service});

  @override
  State<UlasanSection> createState() => _UlasanSectionState();
}

class _UlasanSectionState extends State<UlasanSection> {
  int? _filter; // null = semua bintang
  bool _syncing = false;

  void _sync() async {
    setState(() => _syncing = true);
    try {
      await widget.service.recalculateRatingKelas(widget.kelasId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rating kelas disinkronkan'), backgroundColor: Colors.green));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal sinkron: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
        child: StreamBuilder<List<UlasanModel>>(
          stream: widget.service.streamUlasanKelas(widget.kelasId),
          builder: (_, snap) {
            final all = snap.data ?? const <UlasanModel>[];
            // Hitung langsung dari data ulasan (source of truth), bukan dari
            // field kelas.rating yang bisa saja belum tersinkron.
            final count = all.isNotEmpty ? all.length : widget.jumlahUlasan;
            final avg = all.isNotEmpty ? all.map((u) => u.rating).reduce((a, b) => a + b) / all.length : widget.ratingAvg;

            var list = all;
            if (_filter != null) list = list.where((u) => u.rating == _filter).toList();

            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Text('Rating & Ulasan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                const Spacer(),
                const Icon(Icons.star_rounded, size: 16, color: Color(0xFFFFC107)),
                const SizedBox(width: 3),
                Text('${avg.toStringAsFixed(1)} ($count ulasan)', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                const SizedBox(width: 4),
                SizedBox(width: 28, height: 28, child: IconButton(
                  padding: EdgeInsets.zero,
                  tooltip: 'Sinkronkan rating ke katalog',
                  icon: _syncing
                      ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.sync_rounded, size: 16, color: Color(0xFF1565C0)),
                  onPressed: _syncing ? null : _sync,
                )),
              ]),
              const SizedBox(height: 6),
              _filterDropdown(),
              const SizedBox(height: 10),
              if (!snap.hasData)
                const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Center(child: CircularProgressIndicator()))
              else if (list.isEmpty)
                Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Center(
                  child: Text(_filter == null ? 'Belum ada ulasan untuk kelas ini' : 'Belum ada ulasan dengan rating $_filter ★',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]))))
              else
                Column(children: list.map((u) => Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFEEEEEE)))),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Expanded(child: Text(u.studentNama, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
                      Row(children: List.generate(5, (i) => Icon(i < u.rating ? Icons.star_rounded : Icons.star_outline_rounded, size: 13, color: const Color(0xFFFFC107)))),
                    ]),
                    if (u.komentar.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(u.komentar, style: TextStyle(fontSize: 12, color: Colors.grey[700], height: 1.4)),
                    ],
                    const SizedBox(height: 4),
                    Text('${u.createdAt.day}/${u.createdAt.month}/${u.createdAt.year}', style: TextStyle(fontSize: 10, color: Colors.grey[400])),
                  ]))).toList()),
            ]);
          },
        ),
      );

  Widget _filterDropdown() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(20)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int?>(
            value: _filter,
            isDense: true,
            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Color(0xFF1565C0)),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1565C0)),
            items: [
              const DropdownMenuItem(value: null, child: Text('Semua Rating')),
              for (int i = 5; i >= 1; i--)
                DropdownMenuItem(value: i, child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('$i Bintang'),
                  const SizedBox(width: 4),
                  const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFC107)),
                ])),
            ],
            onChanged: (v) => setState(() => _filter = v),
          ),
        ),
      );
}