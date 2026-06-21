import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/kelas_service.dart';
import '../../models/booking_model.dart';
import '../shared/chat_room_screen.dart';
import '../shared/report_screen.dart';
import 'student_detail_kelas_screen.dart';
import 'student_booking_screen.dart'; // BARU: buat lanjutkan pembayaran

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
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF5F7FA),
    appBar: AppBar(
      title: const Text('Kelas Saya'),
      automaticallyImplyLeading: widget.showBackButton,
      leading: widget.showBackButton
          ? IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: () => Navigator.pop(context))
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
        ])),
    body: StreamBuilder<List<BookingModel>>(
      stream: _service.streamBookingStudent(_uid),
      builder: (_, snap) {
        if (!snap.hasData)
          return const Center(child: CircularProgressIndicator());

        final all      = snap.data!;
        final upcoming = all.where((b) =>
          b.status == 'waiting_payment' ||
          b.status == 'waiting_verification' ||
          b.status == 'confirmed').toList();
        final done = all.where((b) => b.status == 'completed').toList();

        return TabBarView(
          controller: _tab,
          children: [
            _buildList(upcoming),
            _buildDone(done),
            _buildList(all),
          ]);
      }));

  Widget _buildList(List<BookingModel> items) {
    if (items.isEmpty) return _empty('Belum ada kelas');
    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: items.length,
      itemBuilder: (_, i) => _BookingCard(
        booking: items[i],
        uid: _uid,
        onReview: null));
  }

  Widget _buildDone(List<BookingModel> items) {
    if (items.isEmpty) return _empty('Belum ada kelas selesai');
    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: items.length,
      itemBuilder: (_, i) => _BookingCard(
        booking: items[i],
        uid: _uid,
        onReview: items[i].reviewed
            ? null
            : () => _showReviewDialog(items[i])));
  }

  Widget _empty(String msg) => Center(child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.inbox_rounded, size: 56, color: Colors.grey[300]),
      const SizedBox(height: 10),
      Text(msg, style: TextStyle(color: Colors.grey[400], fontSize: 14)),
    ]));

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
            Row(mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) => GestureDetector(
                onTap: () => ss(() => rating = i + 1),
                child: Icon(
                  i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: const Color(0xFFFFC107), size: 38)))),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl, maxLines: 3,
              decoration: const InputDecoration(hintText: 'Tulis ulasanmu...')),
          ]),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal')),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await _service.submitUlasan(
                  bookingId:   b.id,
                  kelasId:     b.kelasId,
                  tutorId:     b.tutorId,
                  rating:      rating,
                  komentar:    ctrl.text.trim(),
                  studentNama: FirebaseAuth.instance.currentUser?.displayName ?? '');
                if (mounted)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ulasan terkirim, terima kasih!')));
              },
              child: const Text('Kirim')),
          ])));
  }
}

class _BookingCard extends StatelessWidget {
  final BookingModel booking;
  final String uid;
  final VoidCallback? onReview;

  const _BookingCard({required this.booking, required this.uid, this.onReview});

  Color get _statusColor {
    switch (booking.status) {
      case 'confirmed':            return Colors.green;
      case 'waiting_verification': return Colors.orange;
      case 'waiting_payment':      return Colors.blue;
      case 'rejected':             return Colors.red;
      case 'completed':            return Colors.grey;
      default:                     return Colors.grey;
    }
  }

  IconData get _statusIcon {
    switch (booking.status) {
      case 'confirmed':            return Icons.check_circle_rounded;
      case 'waiting_verification': return Icons.hourglass_bottom_rounded;
      case 'waiting_payment':      return Icons.payment_rounded;
      case 'rejected':             return Icons.cancel_rounded;
      case 'completed':            return Icons.done_all_rounded;
      default:                     return Icons.schedule_rounded;
    }
  }

  void _confirmBatalkan(BuildContext context) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Batalkan Booking?', style: TextStyle(fontWeight: FontWeight.w700)),
      content: Text(
        'Booking "${booking.kelasJudul}" pada ${booking.jadwalDipilih} - ${booking.jamDipilih} akan dibatalkan dan tidak bisa dikembalikan.',
        style: TextStyle(fontSize: 13, color: Colors.grey[700])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tidak')),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(ctx);
            await KelasService().batalkanBooking(booking.id);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Booking dibatalkan')));
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Ya, Batalkan')),
      ]));
  }

  @override
  Widget build(BuildContext context) {
    // BARU: waiting_payment juga bisa diklik buat lanjutkan pembayaran
    final bool canClick = booking.status == 'confirmed' ||
        booking.status == 'completed' ||
        booking.status == 'waiting_payment';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: canClick ? () async {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: CircularProgressIndicator()),
          );

          try {
            final kelasDetail = await KelasService().getKelasById(booking.kelasId);

            if (context.mounted) Navigator.pop(context); // Tutup loading dialog

            if (kelasDetail != null && context.mounted) {
              if (booking.status == 'waiting_payment') {
                // BARU: belum dibayar → lanjutkan ke step pembayaran, skip pilih jadwal
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => StudentBookingScreen(kelas: kelasDetail, existingBooking: booking),
                ));
              } else {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => StudentDetailKelasScreen(kelas: kelasDetail, booking: booking),
                ));
              }
            }
          } catch (e) {
            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Gagal memuat detail kelas: $e')),
              );
            }
          }
        } : null,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20)),
                  child: Row(children: [
                    Icon(_statusIcon, size: 12, color: _statusColor),
                    const SizedBox(width: 5),
                    Text(booking.statusLabel,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _statusColor)),
                  ])),
                const Spacer(),
                Text('${booking.jadwalDipilih}  -  ${booking.jamDipilih}',
                  style: TextStyle(fontSize: 10, color: Colors.grey[400])),
              ]),
              const SizedBox(height: 10),
              Text(booking.kelasJudul,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1565C0))),
              Text('Tutor: ${booking.tutorNama}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              const SizedBox(height: 4),
              Text('Total: Rp${(booking.nominal / 1000).toStringAsFixed(0)}.000',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),

              if (booking.status == 'waiting_payment') ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!)),
                  child: Row(children: [
                    Icon(Icons.touch_app_rounded, color: Colors.blue[700], size: 14),
                    const SizedBox(width: 6),
                    Expanded(child: Text('Ketuk kartu ini untuk lanjutkan pembayaran',
                      style: TextStyle(fontSize: 11, color: Colors.blue[700]))),
                  ])),
              ],

              if (booking.status == 'rejected' && booking.alasanTolak != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!)),
                  child: Row(children: [
                    const Icon(Icons.info_outline, color: Colors.red, size: 14),
                    const SizedBox(width: 6),
                    Expanded(child: Text('Alasan: ${booking.alasanTolak}',
                      style: TextStyle(fontSize: 11, color: Colors.red[700]))),
                  ])),
              ],
            ])),

          Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFEEEEEE)))),
            child: Row(children: [
              if (booking.status == 'confirmed' || booking.status == 'waiting_verification')
                Expanded(child: TextButton.icon(
                  onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => ChatRoomScreen(
                      peerUid:  booking.tutorId,
                      peerNama: booking.tutorNama,
                      peerRole: 'tutor',
                      myRole:   'student'))),
                  icon: const Icon(Icons.chat_bubble_outline, size: 15),
                  label: const Text('Chat Tutor', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(foregroundColor: const Color(0xFF1565C0)))),

              if (booking.status == 'waiting_payment')
                Expanded(child: TextButton.icon(
                  onPressed: () => _confirmBatalkan(context),
                  icon: const Icon(Icons.cancel_outlined, size: 15, color: Colors.red),
                  label: const Text('Batalkan', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(foregroundColor: Colors.red))),

              if (onReview != null)
                Expanded(child: TextButton.icon(
                  onPressed: onReview,
                  icon: const Icon(Icons.star_outline_rounded, size: 15, color: Color(0xFFFFC107)),
                  label: const Text('Beri Ulasan', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(foregroundColor: const Color(0xFFFFC107)))),

              if (booking.status == 'completed' && booking.reviewed)
                Expanded(child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.check_circle_rounded, size: 14, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Text('Sudah Direview', style: TextStyle(fontSize: 12, color: Colors.grey[400])),
                  ]))),

              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  tooltip: 'Laporkan',
                  onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => ReportScreen(
                      targetUid:  booking.tutorId,
                      targetNama: booking.tutorNama,
                      targetRole: 'tutor',
                      myRole:     'student'))),
                  icon: const Icon(Icons.flag_outlined, color: Colors.red, size: 18),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.red[50],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))))),
            ])),
        ]),
      ),
    );
  }
}