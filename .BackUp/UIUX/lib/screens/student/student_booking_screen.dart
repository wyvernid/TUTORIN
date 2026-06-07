import 'package:flutter/material.dart';

class StudentBookingScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  const StudentBookingScreen({super.key, required this.data});

  @override
  State<StudentBookingScreen> createState() => _StudentBookingScreenState();
}

class _StudentBookingScreenState extends State<StudentBookingScreen> {
  int? _selectedDayIndex;
  final _phoneCtrl = TextEditingController();
  bool _showConfirmDialog = false;
  int _step = 1; // 1: pilih jadwal, 2: info pembayaran, 3: upload bukti

  // Generate dummy upcoming dates for each schedule day
  List<Map<String, String>> get _availableDates {
    final days = widget.data['schedules'] as List;
    final List<Map<String, String>> dates = [];
    final dayNames = {'Senin': 1, 'Selasa': 2, 'Rabu': 3, 'Kamis': 4, 'Jumat': 5, 'Sabtu': 6, 'Minggu': 7};
    final now = DateTime.now();
    for (var day in days) {
      for (int i = 1; i <= 4; i++) {
        final target = dayNames[day] ?? 1;
        var date = now;
        while (date.weekday != target) {
          date = date.add(const Duration(days: 1));
        }
        date = date.add(Duration(days: 7 * (i - 1)));
        dates.add({
          'day': day,
          'date': '${date.day} ${_monthName(date.month)} ${date.year}',
          'time': widget.data['time'],
        });
      }
    }
    return dates;
  }

  String _monthName(int m) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return months[m - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking')),
      backgroundColor: const Color(0xFFF5F7FA),
      body: Stack(
        children: [
          _buildBody(),
          if (_showConfirmDialog) _buildConfirmOverlay(),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_step == 2) return _buildPaymentInfo();
    if (_step == 3) return _buildUploadBukti();

    final dates = _availableDates;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.data['title'],
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text('Tutor: ${widget.data['tutor']}',
              style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          const SizedBox(height: 20),
          const Text('Pilih Jadwal',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('(Pilih salah satu sesi)',
              style: TextStyle(fontSize: 12, color: Colors.grey[500])),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.1,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: dates.length,
            itemBuilder: (ctx, i) {
              final isSelected = _selectedDayIndex == i;
              return GestureDetector(
                onTap: () => setState(() => _selectedDayIndex = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF1565C0) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF1565C0) : Colors.grey[300]!,
                    ),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: const Color(0xFF1565C0).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_month_rounded,
                          size: 20,
                          color: isSelected ? Colors.white : const Color(0xFF1565C0)),
                      const SizedBox(height: 4),
                      Text(
                        dates[i]['day']!,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : Colors.grey[800],
                        ),
                      ),
                      Text(
                        dates[i]['date']!,
                        style: TextStyle(
                          fontSize: 9,
                          color: isSelected ? Colors.white70 : Colors.grey[500],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        '${dates[i]['time']} WIB',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          const Text('Nomor Telepon Yang Bisa Dihubungi',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              hintText: 'Contoh: 0812xxxx',
              prefixIcon: Icon(Icons.phone_outlined, size: 20, color: Color(0xFF1565C0)),
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedDayIndex == null
                  ? null
                  : () => setState(() => _showConfirmDialog = true),
              child: const Text('Lanjut ke Pembayaran',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmOverlay() {
    final dates = _availableDates;
    return Container(
      color: Colors.black54,
      child: Center(
        child: Margin(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Apakah Anda Benar-benar\nIngin Mengambil Kelas Ini?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Text(
                  '${widget.data['title']}\n${dates[_selectedDayIndex!]['day']}, ${dates[_selectedDayIndex!]['date']} - ${dates[_selectedDayIndex!]['time']} WIB',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _showConfirmDialog = false),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF1565C0)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Batal'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => setState(() {
                          _showConfirmDialog = false;
                          _step = 2;
                        }),
                        child: const Text('Lanjut'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentInfo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Informasi Pembayaran',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
            ),
            child: Column(
              children: [
                _payRow('Kelas', widget.data['title']),
                const Divider(height: 20),
                _payRow('Tutor', widget.data['tutor']),
                const Divider(height: 20),
                _payRow('Total', 'Rp${_formatPrice(widget.data['price'])}', isTotal: true),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1565C0).withOpacity(0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF1565C0).withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Transfer ke Rekening Berikut:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1565C0))),
                const SizedBox(height: 10),
                _bankRow('BCA', '1234567890', 'TutorIn Official'),
                const SizedBox(height: 8),
                _bankRow('Mandiri', '0987654321', 'TutorIn Official'),
                const SizedBox(height: 8),
                _bankRow('GoPay / OVO', '0812-3456-7890', 'TutorIn'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.orange[700], size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Setelah transfer, segera unggah bukti pembayaran agar slot kelas tidak dilepas.',
                    style: TextStyle(fontSize: 12, color: Colors.orange[800]),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => setState(() => _step = 3),
              child: const Text('Sudah Transfer, Upload Bukti',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadBukti() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Upload Bukti Pembayaran',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text('Tutor akan memverifikasi pembayaran Anda',
              style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF1565C0).withOpacity(0.4),
                  style: BorderStyle.solid,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_upload_outlined, size: 48, color: const Color(0xFF1565C0).withOpacity(0.6)),
                  const SizedBox(height: 10),
                  const Text('Klik untuk Upload Foto Bukti Transfer',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1565C0))),
                  const SizedBox(height: 4),
                  Text('JPG, PNG, max 5MB', style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ringkasan Booking', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                _payRow('Kelas', widget.data['title']),
                const SizedBox(height: 6),
                _payRow('Tutor', widget.data['tutor']),
                const SizedBox(height: 6),
                _payRow('Total Bayar', 'Rp${_formatPrice(widget.data['price'])}', isTotal: true),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showSuccessBottomSheet(),
              child: const Text('Kirim Bukti Pembayaran',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessBottomSheet() {
    final dates = _availableDates;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(28),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.green[50],
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.hourglass_bottom_rounded, color: Colors.orange, size: 36),
            ),
            const SizedBox(height: 16),
            const Text(
              'Bukti Terkirim!\nMenunggu Verifikasi Tutor',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Text(
              'Tutor akan memverifikasi pembayaran Anda dalam 1x24 jam.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Detail Booking', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(widget.data['title'],
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text('Tutor: ${widget.data['tutor']}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  if (_selectedDayIndex != null) ...[
                    const SizedBox(height: 2),
                    Text(
                        '${dates[_selectedDayIndex!]['day']}, ${dates[_selectedDayIndex!]['date']} · ${dates[_selectedDayIndex!]['time']} WIB',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF1565C0)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Kembali ke Beranda', style: TextStyle(fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                    child: const Text('Lihat Status', style: TextStyle(fontSize: 13)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _payRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: isTotal ? 15 : 13,
              fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
              color: isTotal ? const Color(0xFF1565C0) : Colors.grey[800],
            ),
          ),
        ),
      ],
    );
  }

  Widget _bankRow(String bank, String number, String name) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 28,
          decoration: BoxDecoration(
            color: const Color(0xFF1565C0),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(bank.substring(0, bank.length < 3 ? bank.length : 3),
                style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w800)),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(number, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            Text('a.n. $name', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          ],
        ),
        const Spacer(),
        Icon(Icons.copy_rounded, size: 16, color: Colors.grey[400]),
      ],
    );
  }

  String _formatPrice(int price) {
    if (price >= 1000) return '${(price / 1000).toStringAsFixed(0)}.000';
    return price.toString();
  }
}

class Margin extends StatelessWidget {
  final EdgeInsets margin;
  final Widget child;
  const Margin({super.key, required this.margin, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(padding: margin, child: child);
  }
}
