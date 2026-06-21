import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/chat_service.dart';
import '../../models/chat_model.dart';
import '../shared/chat_room_screen.dart';

class StudentChatListScreen extends StatelessWidget {
  const StudentChatListScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(title: const Text('Pesan'), automaticallyImplyLeading: false,
        actions: [IconButton(icon: const Icon(Icons.search_rounded), onPressed: () {})]),
      body: StreamBuilder<List<ChatRoom>>(
        stream: ChatService().streamDaftarChat(uid),
        builder: (_, snap) {
          // BARU: tangani error stream secara eksplisit. Tanpa ini, kalau
          // query gagal (paling sering karena composite index Firestore
          // 'chatRooms (members ARRAY, lastMessageAt DESC)' belum dibuat),
          // snap.hasData tetap false SELAMANYA dan spinner muter tanpa
          // henti tanpa ada pesan error sama sekali ke user.
          if (snap.hasError) {
            final errStr = snap.error.toString();
            final isIndexError = errStr.contains('FAILED_PRECONDITION') || errStr.contains('index');
            return Center(child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.error_outline_rounded, size: 44, color: Colors.red[300]),
                const SizedBox(height: 12),
                Text(
                  isIndexError
                      ? 'Index Firestore untuk daftar chat belum dibuat.\nBuka log konsol Flutter, cari link Firebase Console,\nklik untuk membuat index secara otomatis.'
                      : 'Gagal memuat daftar chat',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.5)),
                const SizedBox(height: 6),
                Text(errStr, textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, color: Colors.grey[400])),
              ])));
          }
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final rooms = snap.data!;
          if (rooms.isEmpty) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey[300]), const SizedBox(height: 8),
            Text('Belum ada pesan', style: TextStyle(color: Colors.grey[400]))]));
          return ListView.separated(itemCount: rooms.length, separatorBuilder: (_, __) => const Divider(height: 0, indent: 72),
            itemBuilder: (_, i) { final r = rooms[i];
              final peerId = r.members.firstWhere((m) => m != uid, orElse: () => '');
              final peerName = r.memberNames[peerId] ?? '';
              final peerRole = r.memberRoles[peerId] ?? 'tutor';
              final unread = r.unreadCount[uid] ?? 0;
              return ListTile(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatRoomScreen(
                  peerUid: peerId, peerNama: peerName, peerRole: peerRole, myRole: 'student'))),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Container(width: 50, height: 50, decoration: BoxDecoration(color: const Color(0xFF1565C0).withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.person_rounded, color: Color(0xFF1565C0), size: 28)),
                title: Row(children: [
                  Text(peerName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 6),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: peerRole == 'admin' ? Colors.purple.withOpacity(0.1) : const Color(0xFF1565C0).withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                    child: Text(peerRole, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: peerRole == 'admin' ? Colors.purple : const Color(0xFF1565C0)))),
                ]),
                subtitle: Text(r.lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('${r.lastMessageAt.hour}:${r.lastMessageAt.minute.toString().padLeft(2, "0")}', style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                  const SizedBox(height: 4),
                  if (unread > 0) Container(width: 20, height: 20, decoration: const BoxDecoration(color: Color(0xFF1565C0), shape: BoxShape.circle),
                    child: Center(child: Text('$unread', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)))),
                ]));
            });
        }));
  }
}