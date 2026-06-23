import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';
import '../models/notifikasi_model.dart';
import 'notifikasi_service.dart';

class ChatService {
  final _db   = FirebaseFirestore.instance;
  final _notif = NotifikasiService();

  // ── Tracker: uid siapa yang sedang AKTIF membuka chat room tertentu ──
  static final Map<String, String> _activeRooms = {};

  static void setActiveRoom(String roomId, String myUid) =>
      _activeRooms[roomId] = myUid;

  static void clearActiveRoom(String roomId) =>
      _activeRooms.remove(roomId);

  String roomId(String a, String b) {
    final s = [a, b]..sort();
    return '${s[0]}_${s[1]}';
  }

  Future<void> kirimPesan({
    required String senderUid,
    required String senderNama,
    required String senderRole,
    required String receiverUid,
    required String receiverNama,
    required String receiverRole,
    required String text,
    String? fileUrl,
    // 'image' | 'pdf' | null
    String? fileType,
  }) async {
    final rId     = roomId(senderUid, receiverUid);
    final roomRef = _db.collection('chatRooms').doc(rId);
    final batch   = _db.batch();

    // ── Preview teks di daftar chat ──
    String lastMsg = text;
    if (fileType == 'image') lastMsg = '[Gambar]';
    if (fileType == 'pdf')   lastMsg = '[Dokumen PDF]';

    batch.set(roomRef.collection('messages').doc(), {
      'senderId':   senderUid,
      'senderNama': senderNama,
      'text':       text,
      'fileUrl':    fileUrl,
      'fileType':   fileType,   // ← BARU
      'createdAt':  FieldValue.serverTimestamp(),
      'isRead':     false,
    });

    batch.set(
      roomRef,
      {
        'members':       [senderUid, receiverUid],
        'memberNames':   {senderUid: senderNama, receiverUid: receiverNama},
        'memberRoles':   {senderUid: senderRole, receiverUid: receiverRole},
        'lastMessage':   lastMsg,
        'lastMessageAt': FieldValue.serverTimestamp(),
        'unreadCount':   {receiverUid: FieldValue.increment(1)},
      },
      SetOptions(merge: true),
    );

    await batch.commit();

    // ── Hanya kirim push jika penerima TIDAK sedang aktif di room ini ──
    final receiverActiveInRoom = _activeRooms[rId] == receiverUid;
    if (!receiverActiveInRoom) {
      try {
        await _notif.kirim(
          uid:      receiverUid,
          role:     receiverRole,
          tipe:     NotifikasiTipe.chatBaru,
          judul:    senderNama,
          pesan:    lastMsg,
          refId:    rId,
          refType:  'chat',
        );
      } catch (e) {
        print('Gagal kirim notifikasi chat baru: $e');
      }
    }
  }

  Stream<List<ChatMessage>> streamPesan(String uid1, String uid2) => _db
      .collection('chatRooms')
      .doc(roomId(uid1, uid2))
      .collection('messages')
      .orderBy('createdAt')
      .snapshots()
      .map((s) => s.docs.map((d) => ChatMessage.fromMap(d.data(), d.id)).toList());

  Stream<List<ChatRoom>> streamDaftarChat(String uid) => _db
      .collection('chatRooms')
      .where('members', arrayContains: uid)
      .orderBy('lastMessageAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => ChatRoom.fromMap(d.data(), d.id)).toList());

  Future<void> tandaiDibaca(String rId, String uid) async =>
      _db.collection('chatRooms').doc(rId).update({'unreadCount.$uid': 0});
}