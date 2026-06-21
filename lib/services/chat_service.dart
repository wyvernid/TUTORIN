import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';
import '../models/notifikasi_model.dart';
import 'notifikasi_service.dart';

class ChatService {
  final _db = FirebaseFirestore.instance;
  final _notif = NotifikasiService();

  String roomId(String a, String b) { final s = [a, b]..sort(); return '${s[0]}_${s[1]}'; }

  Future<void> kirimPesan({required String senderUid, required String senderNama,
      required String senderRole, required String receiverUid, required String receiverNama,
      required String receiverRole, required String text, String? fileUrl}) async {
    final rId = roomId(senderUid, receiverUid);
    final roomRef = _db.collection('chatRooms').doc(rId);
    final batch = _db.batch();
    batch.set(roomRef.collection('messages').doc(), {
      'senderId': senderUid, 'senderNama': senderNama, 'text': text,
      'fileUrl': fileUrl, 'createdAt': FieldValue.serverTimestamp(), 'isRead': false});
    batch.set(roomRef, {
      'members': [senderUid, receiverUid],
      'memberNames': {senderUid: senderNama, receiverUid: receiverNama},
      'memberRoles': {senderUid: senderRole, receiverUid: receiverRole},
      'lastMessage': fileUrl != null ? '[Gambar]' : text,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'unreadCount': {receiverUid: FieldValue.increment(1)},
    }, SetOptions(merge: true));
    await batch.commit();

    // ── BARU: kabari penerima ada pesan baru ──
    try {
      await _notif.kirim(
        uid: receiverUid,
        role: receiverRole,
        tipe: NotifikasiTipe.chatBaru,
        judul: senderNama,
        pesan: fileUrl != null ? '[Gambar]' : text,
        refId: rId,
        refType: 'chat',
      );
    } catch (e) {
      print('Gagal kirim notifikasi chat baru: $e');
    }
  }

  Stream<List<ChatMessage>> streamPesan(String uid1, String uid2) => _db
      .collection('chatRooms').doc(roomId(uid1, uid2))
      .collection('messages').orderBy('createdAt')
      .snapshots().map((s) => s.docs.map((d) => ChatMessage.fromMap(d.data(), d.id)).toList());

  Stream<List<ChatRoom>> streamDaftarChat(String uid) => _db.collection('chatRooms')
      .where('members', arrayContains: uid).orderBy('lastMessageAt', descending: true)
      .snapshots().map((s) => s.docs.map((d) => ChatRoom.fromMap(d.data(), d.id)).toList());

  Future<void> tandaiDibaca(String rId, String uid) async =>
      _db.collection('chatRooms').doc(rId).update({'unreadCount.$uid': 0});
}