import 'package:flutter/material.dart';
import '../../models/notifikasi_model.dart';
import '../../services/notifikasi_service.dart';

/// Halaman daftar SEMUA notifikasi milik user yang sedang login.
/// Mendukung swipe-to-delete dan tombol "Tandai semua dibaca".
class NotifikasiListScreen extends StatelessWidget {
  final String uid;
  final String role;
  const NotifikasiListScreen({super.key, required this.uid, required this.role});

  IconData _iconUntuk(String tipe) {
    switch (tipe) {
      case NotifikasiTipe.bookingBaru:
        return Icons.event_available;
      case NotifikasiTipe.bookingDikonfirmasi:
        return Icons.check_circle;
      case NotifikasiTipe.bookingDitolak:
        return Icons.cancel;
      case NotifikasiTipe.reminderKelas:
        return Icons.alarm;
      case NotifikasiTipe.chatBaru:
        return Icons.chat_bubble;
      case NotifikasiTipe.tutorDisetujui:
        return Icons.verified;
      case NotifikasiTipe.tutorDitolak:
        return Icons.block;
      case NotifikasiTipe.laporanBaru:
        return Icons.flag;
      case NotifikasiTipe.laporanSelesai:
        return Icons.task_alt;
      case NotifikasiTipe.ulasanBaru:
        return Icons.star;
      case NotifikasiTipe.tutorMendaftar:
        return Icons.person_add;
      default:
        return Icons.notifications;
    }
  }

  Color _warnaUntuk(String tipe) {
    switch (tipe) {
      case NotifikasiTipe.bookingDitolak:
      case NotifikasiTipe.tutorDitolak:
      case NotifikasiTipe.laporanBaru:
        return Colors.red;
      case NotifikasiTipe.bookingDikonfirmasi:
      case NotifikasiTipe.tutorDisetujui:
      case NotifikasiTipe.laporanSelesai:
        return Colors.green;
      case NotifikasiTipe.reminderKelas:
        return Colors.orange;
      case NotifikasiTipe.tutorMendaftar:
        return Colors.orange;
      default:
        return const Color(0xFF1565C0);
    }
  }

  String _waktuRelatif(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    const bulan = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${dt.day} ${bulan[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final service = NotifikasiService();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        actions: [
          TextButton(
            onPressed: () => service.tandaiSemuaDibaca(uid),
            child: const Text('Tandai semua dibaca', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: StreamBuilder<List<NotifikasiModel>>(
        stream: service.streamNotifikasi(uid),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final list = snap.data ?? [];
          if (list.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Belum ada notifikasi', style: TextStyle(color: Colors.grey)),
              ),
            );
          }
          return ListView.separated(
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final n = list[i];
              return Dismissible(
                key: ValueKey(n.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) => service.hapus(n.id),
                child: ListTile(
                  tileColor: n.isRead ? null : const Color(0xFFEAF2FB),
                  leading: CircleAvatar(
                    backgroundColor: _warnaUntuk(n.tipe).withOpacity(0.15),
                    child: Icon(_iconUntuk(n.tipe), color: _warnaUntuk(n.tipe)),
                  ),
                  title: Text(
                    n.judul,
                    style: TextStyle(fontWeight: n.isRead ? FontWeight.w500 : FontWeight.w700),
                  ),
                  subtitle: Text(n.pesan, maxLines: 2, overflow: TextOverflow.ellipsis),
                  trailing: Text(_waktuRelatif(n.createdAt), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  onTap: () {
                    if (!n.isRead) service.tandaiDibaca(n.id);
                    // TODO: arahkan ke layar terkait berdasarkan n.refType & n.refId.
                    // Contoh (sesuaikan dengan constructor screen kamu):
                    // if (n.refType == 'chat')    Navigator.push(context, MaterialPageRoute(
                    //     builder: (_) => ChatRoomScreen(peerUid: n.refId!, ...)));
                    // if (n.refType == 'laporan') Navigator.push(context, MaterialPageRoute(
                    //     builder: (_) => AdminLaporanScreen()));
                    // if (n.refType == 'booking') tampilkan detail booking terkait.
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}