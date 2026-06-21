import 'package:flutter/material.dart';
import '../../services/notifikasi_service.dart';
import 'notifikasi_list_screen.dart';

/// Icon lonceng notifikasi + badge angka belum dibaca.
/// Pasang di `actions: [...]` AppBar tiap home screen (Student/Tutor/Admin).
///
/// Contoh pakai di student_home_screen.dart / tutor_home_screen.dart / admin_home_screen.dart:
/// ```dart
/// import '../shared/notifikasi_badge_icon.dart';
///
/// appBar: AppBar(
///   title: const Text('TutorIn'),
///   actions: [NotifikasiBadgeIcon(uid: myUid, role: 'student')],
/// ),
/// ```
class NotifikasiBadgeIcon extends StatelessWidget {
  final String uid;
  final String role; // 'student' | 'tutor' | 'admin'
  const NotifikasiBadgeIcon({super.key, required this.uid, required this.role});

  @override
  Widget build(BuildContext context) {
    final service = NotifikasiService();
    return StreamBuilder<int>(
      stream: service.streamJumlahBelumDibaca(uid),
      builder: (context, snap) {
        final jumlah = snap.data ?? 0;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              tooltip: 'Notifikasi',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => NotifikasiListScreen(uid: uid, role: role)),
              ),
            ),
            if (jumlah > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  child: Text(
                    jumlah > 9 ? '9+' : '$jumlah',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}