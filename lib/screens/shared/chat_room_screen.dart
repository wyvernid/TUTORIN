import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import '../../services/chat_service.dart';
import '../../services/storage_service.dart';
import '../../models/chat_model.dart';
import 'pdf_viewer_screen.dart';

class ChatRoomScreen extends StatefulWidget {
  final String peerUid, peerNama, peerRole, myRole;
  final bool online;
  const ChatRoomScreen({
    super.key,
    required this.peerUid,
    required this.peerNama,
    required this.peerRole,
    required this.myRole,
    this.online = false,
  });
  @override
  State<ChatRoomScreen> createState() => _State();
}

class _State extends State<ChatRoomScreen> {
  final _msgCtrl = TextEditingController();
  final _scroll  = ScrollController();
  final _chat    = ChatService();
  final _storage = StorageService();
  late final String _myUid, _myNama, _roomId;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    final u = FirebaseAuth.instance.currentUser!;
    _myUid  = u.uid;
    _myNama = u.displayName ?? u.email ?? 'Saya';
    _roomId = _chat.roomId(_myUid, widget.peerUid);
    ChatService.setActiveRoom(_roomId, _myUid);
    _chat.tandaiDibaca(_roomId, _myUid);
  }

  @override
  void dispose() {
    ChatService.clearActiveRoom(_roomId);
    _msgCtrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  // ── Kirim pesan ───────────────────────────────────────────────────────────
  void _send({String? text, String? fileUrl, String? fileType}) async {
    final msg = text ?? _msgCtrl.text.trim();
    if (msg.isEmpty && fileUrl == null) return;
    setState(() => _sending = true);
    _msgCtrl.clear();
    try {
      await _chat.kirimPesan(
        senderUid:    _myUid,
        senderNama:   _myNama,
        senderRole:   widget.myRole,
        receiverUid:  widget.peerUid,
        receiverNama: widget.peerNama,
        receiverRole: widget.peerRole,
        text:     msg,
        fileUrl:  fileUrl,
        fileType: fileType,
      );
      Future.delayed(const Duration(milliseconds: 150), () {
        if (_scroll.hasClients) {
          _scroll.animateTo(
            _scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  // ── Bottom sheet lampiran ─────────────────────────────────────────────────
  void _showLampiranSheet() => showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36, height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF1565C0).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.camera_alt_rounded, color: Color(0xFF1565C0), size: 20),
              ),
              title: const Text('Kamera', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Ambil foto langsung'),
              onTap: () async {
                Navigator.pop(context);
                final f = await _storage.ambilDariKamera();
                if (f != null && mounted) {
                  setState(() => _sending = true);
                  final url = await _storage.uploadChatGambar(f);
                  _send(text: '[Gambar]', fileUrl: url, fileType: 'image');
                }
              },
            ),
            ListTile(
              leading: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF1565C0).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.photo_library_rounded, color: Color(0xFF1565C0), size: 20),
              ),
              title: const Text('Galeri', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Pilih gambar dari galeri'),
              onTap: () async {
                Navigator.pop(context);
                final f = await _storage.ambilDariGaleri();
                if (f != null && mounted) {
                  setState(() => _sending = true);
                  final url = await _storage.uploadChatGambar(f);
                  _send(text: '[Gambar]', fileUrl: url, fileType: 'image');
                }
              },
            ),
            ListTile(
              leading: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.picture_as_pdf_rounded, color: Colors.red, size: 20),
              ),
              title: const Text('Dokumen PDF', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Kirim file PDF'),
              onTap: () async {
                Navigator.pop(context);
                final f = await _storage.ambilFilePdf();
                if (f != null && mounted) {
                  setState(() => _sending = true);
                  final url = await _storage.uploadChatPdf(f);
                  // Tampilkan nama file asli sebagai label
                  final namaFile = f.path.split('/').last;
                  _send(text: '[PDF] $namaFile', fileUrl: url, fileType: 'pdf');
                }
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ),
  );

  // ── Buka gambar full screen ───────────────────────────────────────────────
  void _lihatGambar(String url) => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => _FullImageScreen(url: url)),
  );

  // ── Buka PDF viewer ───────────────────────────────────────────────────────
  void _lihatPdf(String url, String nama) => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => PdfViewerScreen(pdfUrl: url, title: nama)),
  );

  // ── Download file ─────────────────────────────────────────────────────────
  Future<void> _downloadFile(String url, String namaFile) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mengunduh...')),
      );
      final response = await http.get(Uri.parse(url));
      final dir   = await getApplicationDocumentsDirectory();
      final file  = File('${dir.path}/$namaFile');
      await file.writeAsBytes(response.bodyBytes);
      await OpenFile.open(file.path);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tersimpan: $namaFile')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengunduh: $e')),
        );
      }
    }
  }

  // ── Build bubble berdasarkan tipe pesan ───────────────────────────────────
  Widget _buildBubble(ChatMessage m, bool isMe) {
    // ── Bubble PDF ──
    if (m.isPdf && m.fileUrl != null) {
      // Ambil nama file dari teks pesan ("[PDF] namafile.pdf") atau fallback
      final namaFile = m.text.startsWith('[PDF] ')
          ? m.text.replaceFirst('[PDF] ', '')
          : 'dokumen.pdf';

      return GestureDetector(
        onTap: () => _lihatPdf(m.fileUrl!, namaFile),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.65,
          ),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isMe ? const Color(0xFF1565C0) : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft:     const Radius.circular(14),
              topRight:    const Radius.circular(14),
              bottomLeft:  isMe ? const Radius.circular(14) : const Radius.circular(3),
              bottomRight: isMe ? const Radius.circular(3)  : const Radius.circular(14),
            ),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.picture_as_pdf_rounded,
                color: isMe ? Colors.white70 : Colors.red,
                size: 28,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      namaFile,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isMe ? Colors.white : Colors.grey[800],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Ketuk untuk lihat · ',
                      style: TextStyle(
                        fontSize: 10,
                        color: isMe ? Colors.white70 : Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              // Tombol download
              GestureDetector(
                onTap: () => _downloadFile(m.fileUrl!, namaFile),
                child: Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Icon(
                    Icons.download_rounded,
                    size: 20,
                    color: isMe ? Colors.white70 : const Color(0xFF1565C0),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ── Bubble Gambar ──
    if (m.isImage && m.fileUrl != null) {
      return GestureDetector(
        onTap: () => _lihatGambar(m.fileUrl!),
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                m.fileUrl!,
                width: 180,
                fit: BoxFit.cover,
                loadingBuilder: (_, child, progress) => progress == null
                    ? child
                    : Container(
                        width: 180, height: 120,
                        color: Colors.grey[200],
                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
              ),
            ),
            // Tombol download di sudut gambar
            GestureDetector(
              onTap: () {
                final ts = DateTime.now().millisecondsSinceEpoch;
                _downloadFile(m.fileUrl!, 'gambar_$ts.jpg');
              },
              child: Container(
                margin: const EdgeInsets.all(6),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.45),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.download_rounded, size: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    // ── Bubble teks biasa ──
    // (termasuk backward-compat: fileUrl ada tapi fileType null = gambar lama)
    if (m.fileUrl != null && m.fileType == null) {
      // Pesan lama — tampilkan sebagai gambar (fallback)
      return GestureDetector(
        onTap: () => _lihatGambar(m.fileUrl!),
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(m.fileUrl!, width: 180, fit: BoxFit.cover),
            ),
            GestureDetector(
              onTap: () {
                final ts = DateTime.now().millisecondsSinceEpoch;
                _downloadFile(m.fileUrl!, 'gambar_$ts.jpg');
              },
              child: Container(
                margin: const EdgeInsets.all(6),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.45),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.download_rounded, size: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    // Teks murni
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
      decoration: BoxDecoration(
        color: isMe ? const Color(0xFF1565C0) : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft:     const Radius.circular(14),
          topRight:    const Radius.circular(14),
          bottomLeft:  isMe ? const Radius.circular(14) : const Radius.circular(3),
          bottomRight: isMe ? const Radius.circular(3)  : const Radius.circular(14),
        ),
      ),
      child: Text(
        m.text,
        style: TextStyle(
          color: isMe ? Colors.white : Colors.grey[800],
          fontSize: 13,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF5F7FA),
    appBar: AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person_rounded, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.peerNama,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          Text(widget.online ? 'Online' : 'Offline',
              style: const TextStyle(fontSize: 10, color: Colors.white70)),
        ]),
      ]),
    ),
    body: Column(children: [
      Expanded(
        child: StreamBuilder<List<ChatMessage>>(
          stream: _chat.streamPesan(_myUid, widget.peerUid),
          builder: (_, snap) {
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final msgs = snap.data!;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scroll.hasClients) {
                _scroll.jumpTo(_scroll.position.maxScrollExtent);
              }
            });
            return ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(14),
              itemCount: msgs.length,
              itemBuilder: (_, i) {
                final m    = msgs[i];
                final isMe = m.senderId == _myUid;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: isMe
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (!isMe)
                        Container(
                          width: 26, height: 26,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1565C0).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person_rounded,
                              color: Color(0xFF1565C0), size: 14),
                        ),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            _buildBubble(m, isMe),
                            const SizedBox(height: 2),
                            Text(
                              '${m.createdAt.hour}:${m.createdAt.minute.toString().padLeft(2, "0")}',
                              style: TextStyle(fontSize: 9, color: Colors.grey[400]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),

      // ── Input bar ──────────────────────────────────────────────────────────
      Container(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 12),
        color: Colors.white,
        child: SafeArea(
          child: Row(children: [
            IconButton(
              icon: const Icon(Icons.attach_file_rounded, color: Color(0xFF1565C0)),
              onPressed: _showLampiranSheet,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: TextField(
                controller: _msgCtrl,
                minLines: 1,
                maxLines: 4,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Tulis pesan...',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF5F7FA),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _sending ? null : () => _send(text: _msgCtrl.text.trim()),
              child: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: _sending ? Colors.grey : const Color(0xFF1565C0),
                  shape: BoxShape.circle,
                ),
                child: _sending
                    ? const Padding(
                        padding: EdgeInsets.all(10),
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.send_rounded, color: Colors.white, size: 18),
              ),
            ),
          ]),
        ),
      ),
    ]),
  );
}

// ── Full Screen Image Viewer ───────────────────────────────────────────────
class _FullImageScreen extends StatelessWidget {
  final String url;
  const _FullImageScreen({required this.url});

  Future<void> _download(BuildContext context) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mengunduh gambar...')),
      );
      final response = await http.get(Uri.parse(url));
      final dir  = await getApplicationDocumentsDirectory();
      final ts   = DateTime.now().millisecondsSinceEpoch;
      final file = File('${dir.path}/gambar_$ts.jpg');
      await file.writeAsBytes(response.bodyBytes);
      await OpenFile.open(file.path);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    appBar: AppBar(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      title: const Text('Lihat Gambar', style: TextStyle(color: Colors.white)),
      actions: [
        IconButton(
          icon: const Icon(Icons.download_rounded, color: Colors.white),
          tooltip: 'Unduh',
          onPressed: () => _download(context),
        ),
      ],
    ),
    body: Center(
      child: InteractiveViewer(
        minScale: 0.5,
        maxScale: 4.0,
        child: Image.network(
          url,
          fit: BoxFit.contain,
          loadingBuilder: (_, child, progress) => progress == null
              ? child
              : const CircularProgressIndicator(color: Colors.white),
        ),
      ),
    ),
  );
}