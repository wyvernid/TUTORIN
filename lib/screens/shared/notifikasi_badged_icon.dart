import 'package:flutter/material.dart';
import '../../services/notifikasi_service.dart';
import 'notifikasi_list_screen.dart';

class NotifikasiBadgeIcon extends StatelessWidget {
  final String uid;
  final String role; // 'student' | 'tutor' | 'admin'
  final bool circleBackground;
  final double size;

  const NotifikasiBadgeIcon({
    super.key,
    required this.uid,
    required this.role,
    this.circleBackground = false,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    final service = NotifikasiService();
    return StreamBuilder<int>(
      stream: service.streamJumlahBelumDibaca(uid),
      builder: (context, snap) {
        final jumlah = snap.data ?? 0;

        final lonceng = circleBackground
            ? GestureDetector(
                onTap: () => _bukaDaftar(context),
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                  child: Icon(Icons.notifications_rounded, color: Colors.white, size: size * 0.5),
                ),
              )
            : IconButton(
                icon: const Icon(Icons.notifications_outlined),
                tooltip: 'Notifikasi',
                onPressed: () => _bukaDaftar(context),
              );

        return Stack(
          clipBehavior: Clip.none,
          children: [
            lonceng,
            if (jumlah > 0)
              Positioned(
                right: circleBackground ? -2 : 6,
                top: circleBackground ? -2 : 6,
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

  void _bukaDaftar(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => NotifikasiListScreen(uid: uid, role: role)),
      );
}