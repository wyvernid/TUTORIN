import 'package:flutter/material.dart';
import '../student/student_chat_room_screen.dart';

class TutorChatListScreen extends StatelessWidget {
  const TutorChatListScreen({super.key});

  static final List<Map<String, dynamic>> _chats = [
    {'name': 'Nafisa Nurin', 'role': 'Student', 'lastMsg': 'Kak, materi besok pakai slide yang mana?', 'time': '15:20', 'unread': 3, 'online': true},
    {'name': 'Budi Santoso', 'role': 'Student', 'lastMsg': 'Makasih kak sudah diverifikasi!', 'time': '14:00', 'unread': 0, 'online': false},
    {'name': 'Rafi Maulana', 'role': 'Student', 'lastMsg': 'Apakah bisa reschedule kak?', 'time': 'Kemarin', 'unread': 1, 'online': true},
    {'name': 'Admin TutorIn', 'role': 'Admin', 'lastMsg': 'Akun Anda telah terverifikasi', 'time': 'Sen', 'unread': 0, 'online': true},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Pesan'),
        automaticallyImplyLeading: false,
        actions: [IconButton(icon: const Icon(Icons.search_rounded), onPressed: () {})],
      ),
      body: ListView.separated(
        itemCount: _chats.length,
        separatorBuilder: (_, __) => const Divider(height: 0, indent: 72),
        itemBuilder: (ctx, i) {
          final chat = _chats[i];
          return ListTile(
            onTap: () => Navigator.push(ctx, MaterialPageRoute(
              builder: (_) => StudentChatRoomScreen(
                name: chat['name'], role: chat['role'], online: chat['online'],
              ),
            )),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Stack(
              children: [
                Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1565C0).withOpacity(0.1), shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_rounded, color: Color(0xFF1565C0), size: 28),
                ),
                if (chat['online'] as bool)
                  Positioned(right: 2, bottom: 2,
                    child: Container(
                      width: 12, height: 12,
                      decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2)),
                    )),
              ],
            ),
            title: Row(
              children: [
                Text(chat['name'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: chat['role'] == 'Admin'
                        ? Colors.purple.withOpacity(0.1)
                        : const Color(0xFF1565C0).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(chat['role'], style: TextStyle(
                    fontSize: 9, fontWeight: FontWeight.w700,
                    color: chat['role'] == 'Admin' ? Colors.purple : const Color(0xFF1565C0),
                  )),
                ),
              ],
            ),
            subtitle: Text(chat['lastMsg'], maxLines: 1, overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(chat['time'], style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                const SizedBox(height: 4),
                if ((chat['unread'] as int) > 0)
                  Container(
                    width: 20, height: 20,
                    decoration: const BoxDecoration(color: Color(0xFF1565C0), shape: BoxShape.circle),
                    child: Center(child: Text('${chat['unread']}',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700))),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
