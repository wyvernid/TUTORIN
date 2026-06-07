import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/chat_service.dart';
import '../../services/storage_service.dart';
import '../../models/chat_model.dart';

class ChatRoomScreen extends StatefulWidget {
  final String peerUid, peerNama, peerRole, myRole;
  final bool online;
  const ChatRoomScreen({super.key, required this.peerUid, required this.peerNama,
    required this.peerRole, required this.myRole, this.online = false});
  @override
  State<ChatRoomScreen> createState() => _State();
}

class _State extends State<ChatRoomScreen> {
  final _msgCtrl = TextEditingController();
  final _scroll = ScrollController();
  final _chat = ChatService();
  final _storage = StorageService();
  late final String _myUid, _myNama;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    final u = FirebaseAuth.instance.currentUser!;
    _myUid = u.uid;
    _myNama = u.displayName ?? u.email ?? 'Saya';
  }

  void _send({String? text, String? fileUrl}) async {
    final msg = text ?? _msgCtrl.text.trim();
    if (msg.isEmpty && fileUrl == null) return;
    setState(() => _sending = true);
    _msgCtrl.clear();
    try {
      await _chat.kirimPesan(senderUid: _myUid, senderNama: _myNama, senderRole: widget.myRole,
        receiverUid: widget.peerUid, receiverNama: widget.peerNama, receiverRole: widget.peerRole,
        text: msg, fileUrl: fileUrl);
      Future.delayed(const Duration(milliseconds: 150), () {
        if (_scroll.hasClients) _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      });
    } finally { if (mounted) setState(() => _sending = false); }
  }

  void _pickImg() => showModalBottomSheet(context: context, builder: (_) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
    ListTile(leading: const Icon(Icons.camera_alt_rounded, color: Color(0xFF1565C0)), title: const Text('Kamera'),
      onTap: () async { Navigator.pop(context); final f = await _storage.ambilDariKamera(); if (f != null) { setState(() => _sending = true); final url = await _storage.uploadBuktiBayar('chat_${DateTime.now().millisecondsSinceEpoch}', f); _send(text: '[Gambar]', fileUrl: url); }}),
    ListTile(leading: const Icon(Icons.photo_library_rounded, color: Color(0xFF1565C0)), title: const Text('Galeri'),
      onTap: () async { Navigator.pop(context); final f = await _storage.ambilDariGaleri(); if (f != null) { setState(() => _sending = true); final url = await _storage.uploadBuktiBayar('chat_${DateTime.now().millisecondsSinceEpoch}', f); _send(text: '[Gambar]', fileUrl: url); }}),
  ])));

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF5F7FA),
    appBar: AppBar(
      leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: () => Navigator.pop(context)),
      title: Row(children: [
        Container(width: 32, height: 32, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
          child: const Icon(Icons.person_rounded, color: Colors.white, size: 18)),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.peerNama, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          Text(widget.online ? 'Online' : 'Offline', style: const TextStyle(fontSize: 10, color: Colors.white70)),
        ]),
      ])),
    body: Column(children: [
      Expanded(child: StreamBuilder<List<ChatMessage>>(
        stream: _chat.streamPesan(_myUid, widget.peerUid),
        builder: (_, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final msgs = snap.data!;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent);
          });
          return ListView.builder(controller: _scroll, padding: const EdgeInsets.all(14), itemCount: msgs.length,
            itemBuilder: (_, i) {
              final m = msgs[i]; final isMe = m.senderId == _myUid;
              return Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(
                mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (!isMe) Container(width: 26, height: 26, margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(color: const Color(0xFF1565C0).withOpacity(0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.person_rounded, color: Color(0xFF1565C0), size: 14)),
                  Flexible(child: Column(crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start, children: [
                    if (m.fileUrl != null) ClipRRect(borderRadius: BorderRadius.circular(10),
                      child: Image.network(m.fileUrl!, width: 160, fit: BoxFit.cover)),
                    if (m.text.isNotEmpty && m.text != '[Gambar]') Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
                      decoration: BoxDecoration(
                        color: isMe ? const Color(0xFF1565C0) : Colors.white,
                        borderRadius: BorderRadius.only(topLeft: const Radius.circular(14), topRight: const Radius.circular(14),
                          bottomLeft: isMe ? const Radius.circular(14) : const Radius.circular(3),
                          bottomRight: isMe ? const Radius.circular(3) : const Radius.circular(14))),
                      child: Text(m.text, style: TextStyle(color: isMe ? Colors.white : Colors.grey[800], fontSize: 13))),
                    const SizedBox(height: 2),
                    Text('${m.createdAt.hour}:${m.createdAt.minute.toString().padLeft(2, "0")}',
                      style: TextStyle(fontSize: 9, color: Colors.grey[400])),
                  ])),
                ]));
            });
        })),
      Container(padding: const EdgeInsets.fromLTRB(10,8,10,12), color: Colors.white,
        child: SafeArea(child: Row(children: [
          IconButton(icon: const Icon(Icons.attach_file_rounded, color: Color(0xFF1565C0)), onPressed: _pickImg, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
          const SizedBox(width: 6),
          Expanded(child: TextField(controller: _msgCtrl, minLines: 1, maxLines: 4, style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(hintText: 'Tulis pesan...', hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: BorderSide.none),
              filled: true, fillColor: const Color(0xFFF5F7FA)))),
          const SizedBox(width: 8),
          GestureDetector(onTap: _sending ? null : () => _send(text: _msgCtrl.text.trim()),
            child: Container(width: 40, height: 40, decoration: BoxDecoration(color: _sending ? Colors.grey : const Color(0xFF1565C0), shape: BoxShape.circle),
              child: _sending ? const Padding(padding: EdgeInsets.all(10), child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.send_rounded, color: Colors.white, size: 18))),
        ]))),
    ]),
  );
}