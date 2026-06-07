import 'package:flutter/material.dart';
import 'student_chat_room_screen.dart';

class StudentChatListScreen extends StatelessWidget {
  const StudentChatListScreen({super.key});

  static final List<Map<String, dynamic>> _chats = [
    {
      'name': 'Bintang Ivanna Cholida',
      'role': 'Tutor',
      'lastMsg': 'Baik, sampai jumpa besok ya!',
      'time': '14:32',
      'unread': 2,
      'online': true,
    },
    {
      'name': 'Ahmad Fauzi',
      'role': 'Tutor',
      'lastMsg': 'Materi sudah saya kirim ya',
      'time': '12:10',
      'unread': 0,
      'online': false,
    },
    {
      'name': 'Siti Rahmawati',
      'role': 'Tutor',
      'lastMsg': 'Jangan lupa bawa laptop besok',
      'time': 'Kemarin',
      'unread': 1,
      'online': true,
    },
    {
      'name': 'Admin TutorIn',
      'role': 'Admin',
      'lastMsg': 'Laporan Anda sedang diproses',
      'time': 'Sen',
      'unread': 0,
      'online': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Pesan'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _chats.length,
        separatorBuilder: (_, __) => const Divider(height: 0, indent: 72),
        itemBuilder: (ctx, i) {
          final chat = _chats[i];
          return ListTile(
            onTap: () => Navigator.push(
              ctx,
              MaterialPageRoute(
                builder: (_) => StudentChatRoomScreen(
                  name: chat['name'],
                  role: chat['role'],
                  online: chat['online'],
                ),
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Stack(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1565C0).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_rounded, color: Color(0xFF1565C0), size: 28),
                ),
                if (chat['online'] as bool)
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            title: Row(
              children: [
                Text(
                  chat['name'],
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: chat['role'] == 'Admin'
                        ? Colors.purple.withOpacity(0.1)
                        : const Color(0xFF1565C0).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    chat['role'],
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: chat['role'] == 'Admin' ? Colors.purple : const Color(0xFF1565C0),
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Text(
              chat['lastMsg'],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(chat['time'],
                    style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                const SizedBox(height: 4),
                if ((chat['unread'] as int) > 0)
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1565C0),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${chat['unread']}',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
