import 'package:flutter/material.dart';

class StudentReportScreen extends StatefulWidget {
  final String targetName;
  final String targetRole;

  const StudentReportScreen({
    super.key,
    required this.targetName,
    required this.targetRole,
  });

  @override
  State<StudentReportScreen> createState() => _StudentReportScreenState();
}

class _StudentReportScreenState extends State<StudentReportScreen> {
  String? _selectedCategory;
  final _descCtrl = TextEditingController();
  bool _submitted = false;

  final List<String> _categories = [
    'Pembayaran tidak dikonfirmasi',
    'Tutor tidak hadir',
    'Materi tidak sesuai deskripsi',
    'Perilaku tidak pantas',
    'Penipuan / Kecurangan',
    'Lainnya',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Laporkan ke Admin'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _submitted ? _buildSuccess() : _buildForm(),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.flag_rounded, color: Colors.red[600], size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Melaporkan: ${widget.targetName}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.red[700],
                          )),
                      Text(widget.targetRole,
                          style: TextStyle(fontSize: 12, color: Colors.red[400])),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Kategori Laporan',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          ...(_categories.map((cat) {
            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedCategory == cat
                      ? const Color(0xFF1565C0).withOpacity(0.06)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedCategory == cat
                        ? const Color(0xFF1565C0)
                        : Colors.grey[200]!,
                    width: _selectedCategory == cat ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _selectedCategory == cat
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: _selectedCategory == cat
                          ? const Color(0xFF1565C0)
                          : Colors.grey[400],
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      cat,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: _selectedCategory == cat
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: _selectedCategory == cat
                            ? const Color(0xFF1565C0)
                            : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            );
          })),
          const SizedBox(height: 16),
          const Text('Deskripsi Laporan',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          TextField(
            controller: _descCtrl,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Ceritakan detail kejadian yang ingin Anda laporkan...',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.attach_file_rounded, color: Colors.grey[500], size: 20),
                  const SizedBox(width: 8),
                  Text('Lampirkan bukti (opsional)',
                      style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '⚠️ Laporan palsu dapat mengakibatkan pemblokiran akun. Pastikan laporan ini berdasarkan kejadian nyata.',
              style: TextStyle(fontSize: 12, color: Colors.orange[800]),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedCategory == null
                  ? null
                  : () => setState(() => _submitted = true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                disabledBackgroundColor: Colors.grey[300],
              ),
              child: const Text('Kirim Laporan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green[50],
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 44),
            ),
            const SizedBox(height: 20),
            const Text(
              'Laporan Berhasil Dikirim!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Text(
              'Tim admin TutorIn akan meninjau laporan Anda dan mengambil tindakan yang diperlukan dalam 1x24 jam.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.5),
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Kembali'),
            ),
          ],
        ),
      ),
    );
  }
}
