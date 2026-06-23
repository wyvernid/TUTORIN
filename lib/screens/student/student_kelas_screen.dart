import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/booking_model.dart';
import '../../services/kelas_service.dart';
import '../shared/chat_room_screen.dart';
import '../shared/report_screen.dart';
// import 'student_detail_kelas_screen.dart';
// import 'student_booking_screen.dart';

class StudentKelasScreen extends StatefulWidget {
  final bool showBackButton;
  const StudentKelasScreen({super.key, this.showBackButton = false});
  @override
  State<StudentKelasScreen> createState() => _State();
}

class _State extends State<StudentKelasScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  final _service = KelasService();
  late final String _uid;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _uid = FirebaseAuth.instance.currentUser!.uid;
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Map<String, List<BookingModel>> _groupByKelas(List<BookingModel> items) {
    final Map<String, List<BookingModel>> grouped = {};
    for (final b in items) {
      grouped.putIfAbsent(b.kelasId, () => []).add(b);
    }
    // Urutkan jadwal tiap kelas ascending (tanggal terdekat di atas)
    for (final list in grouped.values) {
      list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }
    // Urutkan group: booking terbaru (createdAt max) paling atas
    final sorted = grouped.entries.toList()
      ..sort((a, b) => b.value.last.createdAt.compareTo(a.value.last.createdAt));
    return Map.fromEntries(sorted);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF5F7FA),
    appBar: AppBar(
      title: const Text('Kelas Saya'),
      automaticallyImplyLeading: widget.showBackButton,
      leading: widget.showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Navigator.pop(context))
          : null,
      bottom: TabBar(
        controller: _tab,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white60,
        indicatorColor: Colors.white,
        tabs: const [
          Tab(text: 'Mendatang'),
          Tab(text: 'Selesai'),
          Tab(text: 'Semua'),
        ],
      ),
    ),
    body: StreamBuilder<List<BookingModel>>(
      stream: _service.streamBookingStudent(_uid),
      builder: (_, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());

        final all = snap.data!;
        final upcoming = all.where((b) =>
            b.status == 'waiting_payment' ||
            b.status == 'waiting_verification' ||
            b.status == 'confirmed').toList();
        final done = all.where((b) => b.status == 'completed').toList();

        return TabBarView(
          controller: _tab,
          children: [
            _buildGroupedList(upcoming),
            _buildGroupedList(done, isDone: true),
            _buildGroupedList(all),
          ],
        );
      },
    ),
  );

  Widget _buildGroupedList(List<BookingModel> items, {bool isDone = false}) {
    if (items.isEmpty) return _empty('Belum ada kelas');
    final grouped = _groupByKelas(items);
    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: grouped.length,
      itemBuilder: (_, i) {
        final kelasId   = grouped.keys.elementAt(i);
        final bookings  = grouped[kelasId]!;
        final canReview = isDone &&
            bookings.any((b) => b.status == 'completed' && !b.reviewed);
        return _GroupedBookingCard(
          bookings: bookings,
          uid: _uid,
          onReview: canReview
              ? () => _showReviewDialog(bookings.firstWhere(
                  (b) => b.status == 'completed' && !b.reviewed))
              : null,
        );
      },
    );
  }

  Widget _empty(String msg) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.inbox_rounded, size: 56, color: Colors.grey[300]),
      const SizedBox(height: 10),
      Text(msg, style: TextStyle(color: Colors.grey[400], fontSize: 14)),
    ]),
  );

  void _showReviewDialog(BookingModel b) {
    int rating = 4;
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, ss) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Beri Ulasan', style: TextStyle(fontWeight: FontWeight.w700)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(b.kelasJudul, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) => GestureDetector(
                onTap: () => ss(() => rating = i + 1),
                child: Icon(
                  i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: const Color(0xFFFFC107),
                  size: 38,
                ),
              )),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'Tulis ulasanmu...'),
            ),
          ]),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await _service.submitUlasan(
                  bookingId:   b.id,
                  kelasId:     b.kelasId,
                  tutorId:     b.tutorId,
                  rating:      rating,
                  komentar:    ctrl.text.trim(),
                  studentNama: FirebaseAuth.instance.currentUser?.displayName ?? '',
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ulasan terkirim, terima kasih!')));
                }
              },
              child: const Text('Kirim'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Card 1 kelas (berisi beberapa jadwal) ─────────────────────────────────
class _GroupedBookingCard extends StatelessWidget {
  final List<BookingModel> bookings; // semua booking untuk 1 kelas
  final String uid;
  final VoidCallback? onReview;

  const _GroupedBookingCard({
    required this.bookings,
    required this.uid,
    this.onReview,
  });

  // Pakai data dari booking pertama untuk info kelas umum
  BookingModel get _first => bookings.first;

  int get _totalNominal => bookings.fold(0, (sum, b) => sum + b.nominal);

  // Status "paling penting" untuk ditampilkan di badge
  // Prioritas: waiting_payment > waiting_verification > confirmed > completed
  String get _statusUtama {
    const priority = [
      'waiting_payment',
      'waiting_verification',
      'rejected',
      'confirmed',
      'completed',
    ];
    for (final s in priority) {
      if (bookings.any((b) => b.status == s)) return s;
    }
    return bookings.first.status;
  }

  Color get _statusColor {
    switch (_statusUtama) {
      case 'confirmed':            return Colors.green;
      case 'waiting_verification': return Colors.orange;
      case 'waiting_payment':      return Colors.blue;
      case 'rejected':             return Colors.red;
      case 'completed':            return Colors.grey;
      default:                     return Colors.grey;
    }
  }

  IconData get _statusIcon {
    switch (_statusUtama) {
      case 'confirmed':            return Icons.check_circle_rounded;
      case 'waiting_verification': return Icons.hourglass_bottom_rounded;
      case 'waiting_payment':      return Icons.payment_rounded;
      case 'rejected':             return Icons.cancel_rounded;
      case 'completed':            return Icons.done_all_rounded;
      default:                     return Icons.schedule_rounded;
    }
  }

  String get _statusLabel {
    switch (_statusUtama) {
      case 'waiting_payment':      return 'Menunggu Pembayaran';
      case 'waiting_verification': return 'Menunggu Verifikasi';
      case 'confirmed':            return 'Terkonfirmasi';
      case 'rejected':             return 'Ditolak';
      case 'completed':            return 'Selesai';
      default:                     return _statusUtama;
    }
  }

  // Format nominal: 3000 → "3.000"
  String _formatNominal(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  void _confirmBatalkan(BuildContext context, BookingModel b) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Batalkan Booking?', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text(
          'Jadwal "${b.jadwalDipilih} - ${b.jamDipilih}" akan dibatalkan.',
          style: TextStyle(fontSize: 13, color: Colors.grey[700]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tidak'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await KelasService().batalkanBooking(b.id);
              if (ctx.mounted) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Booking dibatalkan')));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );
  }

  void _showDetailJadwal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.55,
        minChildSize: 0.35,
        maxChildSize: 0.85,
        builder: (_, ctrl) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Handle
            Center(
              child: Container(
                width: 36, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              _first.kelasJudul,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1565C0)),
            ),
            Text(
              'Tutor: ${_first.tutorNama}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              '${bookings.length} sesi  ·  Total: Rp${_formatNominal(_totalNominal)}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const Divider(height: 24),
            const Text(
              'Jadwal Sesi',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                controller: ctrl,
                itemCount: bookings.length,
                itemBuilder: (_, i) {
                  final b = bookings[i];
                  final statusColor = b.status == 'confirmed'
                      ? Colors.green
                      : b.status == 'waiting_verification'
                          ? Colors.orange
                          : b.status == 'waiting_payment'
                              ? Colors.blue
                              : Colors.grey;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(children: [
                      Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${i + 1}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(
                            b.jadwalDipilih,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            b.jamDipilih,
                            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                          ),
                        ]),
                      ),
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text(
                          'Rp${_formatNominal(b.nominal)}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        if (b.status == 'waiting_payment')
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              _confirmBatalkan(context, b);
                            },
                            child: Text(
                              'Batalkan',
                              style: TextStyle(fontSize: 10, color: Colors.red[400]),
                            ),
                          ),
                      ]),
                    ]),
                  );
                },
              ),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasWaitingPayment = bookings.any((b) => b.status == 'waiting_payment');
    final bool hasConfirmed = bookings.any((b) =>
        b.status == 'confirmed' || b.status == 'waiting_verification');
    final BookingModel? firstWaiting = hasWaitingPayment
        ? bookings.firstWhere((b) => b.status == 'waiting_payment')
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showDetailJadwal(context),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Badge status + jumlah sesi
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(children: [
                    Icon(_statusIcon, size: 12, color: _statusColor),
                    const SizedBox(width: 5),
                    Text(
                      _statusLabel,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _statusColor,
                      ),
                    ),
                  ]),
                ),
                const SizedBox(width: 8),
                // Badge jumlah sesi (hanya tampil kalau > 1)
                if (bookings.length > 1)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${bookings.length} sesi',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                const Spacer(),
                // Ikon panah untuk buka detail
                Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey[400], size: 18),
              ]),

              const SizedBox(height: 10),
              Text(
                _first.kelasJudul,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1565C0),
                ),
              ),
              Text(
                'Tutor: ${_first.tutorNama}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 6),

              // Jadwal preview (maks 2 baris, sisanya "... +N lainnya")
              ...bookings.take(2).map((b) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(children: [
                  Icon(Icons.calendar_today_rounded, size: 11, color: Colors.grey[400]),
                  const SizedBox(width: 5),
                  Text(
                    '${b.jadwalDipilih}  ·  ${b.jamDipilih}',
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ]),
              )),
              if (bookings.length > 2)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    '+ ${bookings.length - 2} jadwal lainnya — ketuk untuk lihat semua',
                    style: TextStyle(fontSize: 10, color: Colors.grey[400], fontStyle: FontStyle.italic),
                  ),
                ),

              const SizedBox(height: 8),
              // Total harga
              Row(children: [
                const Icon(Icons.payments_rounded, size: 13, color: Color(0xFF1565C0)),
                const SizedBox(width: 5),
                Text(
                  bookings.length > 1
                      ? 'Total ${bookings.length} sesi: Rp${_formatNominal(_totalNominal)}'
                      : 'Total: Rp${_formatNominal(_totalNominal)}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ]),

              // Hint bayar (kalau ada yang waiting_payment)
              if (hasWaitingPayment) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(children: [
                    Icon(Icons.touch_app_rounded, color: Colors.blue[700], size: 14),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Ketuk untuk lihat detail & lanjutkan pembayaran',
                        style: TextStyle(fontSize: 11, color: Colors.blue[700]),
                      ),
                    ),
                  ]),
                ),
              ],
            ]),
          ),

          // ── Action bar bawah ──
          Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
            ),
            child: Row(children: [
              // Chat Tutor
              if (hasConfirmed)
                Expanded(child: TextButton.icon(
                  onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => ChatRoomScreen(
                      peerUid:  _first.tutorId,
                      peerNama: _first.tutorNama,
                      peerRole: 'tutor',
                      myRole:   'student',
                    ))),
                  icon: const Icon(Icons.chat_bubble_outline, size: 15),
                  label: const Text('Chat Tutor', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(foregroundColor: const Color(0xFF1565C0)),
                )),

              // Batalkan (hanya kalau semua masih waiting_payment)
              if (hasWaitingPayment && !hasConfirmed && firstWaiting != null)
                Expanded(child: TextButton.icon(
                  onPressed: () => _confirmBatalkan(context, firstWaiting),
                  icon: const Icon(Icons.cancel_outlined, size: 15, color: Colors.red),
                  label: const Text('Batalkan', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                )),

              // Review
              if (onReview != null)
                Expanded(child: TextButton.icon(
                  onPressed: onReview,
                  icon: const Icon(Icons.star_outline_rounded, size: 15, color: Color(0xFFFFC107)),
                  label: const Text('Beri Ulasan', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(foregroundColor: const Color(0xFFFFC107)),
                )),

              // Sudah direview
              if (_first.status == 'completed' && _first.reviewed && onReview == null)
                Expanded(child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.check_circle_rounded, size: 14, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Text('Sudah Direview', style: TextStyle(fontSize: 12, color: Colors.grey[400])),
                  ]),
                )),

              // Laporkan
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  tooltip: 'Laporkan',
                  onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => ReportScreen(
                      targetUid:  _first.tutorId,
                      targetNama: _first.tutorNama,
                      targetRole: 'tutor',
                      myRole:     'student',
                    ))),
                  icon: const Icon(Icons.flag_outlined, color: Colors.red, size: 18),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.red[50],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}