import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';

class StorageService {
  final _supabase = Supabase.instance.client;
  final _picker   = ImagePicker();
  static const _bucket = 'tutorin-storage';

  // ── Ambil gambar ──────────────────────────────────────────────────────────
  Future<File?> ambilDariKamera() async {
    final p = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    return p != null ? File(p.path) : null;
  }

  Future<File?> ambilDariGaleri() async {
    final p = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    return p != null ? File(p.path) : null;
  }

  // ── Ambil PDF ─────────────────────────────────────────────────────────────
  Future<File?> ambilFilePdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      return File(result.files.single.path!);
    }
    return null;
  }

  // ── Upload ke Supabase Storage ────────────────────────────────────────────
  Future<String> _upload(String path, File file, {String contentType = 'image/jpeg'}) async {
    final bytes = await file.readAsBytes();
    await _supabase.storage.from(_bucket).uploadBinary(
      path,
      bytes,
      fileOptions: FileOptions(contentType: contentType, upsert: true),
    );
    final publicUrl = _supabase.storage.from(_bucket).getPublicUrl(path);
    return '$publicUrl?updatedAt=${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<String> uploadFotoProfil(String uid, File f) =>
      _upload('profil/$uid/foto.jpg', f);

  Future<String> uploadBuktiBayar(String bookingId, File f) =>
      _upload('bukti_bayar/$bookingId.jpg', f);

  Future<String> uploadBuktiLaporan(String laporanId, File f) =>
      _upload('laporan/$laporanId.jpg', f);

  Future<String> uploadPortofolioPdf(String uid, String name, File f) =>
      _upload('portofolio/$uid/$name', f, contentType: 'application/pdf');

  Future<String> uploadCvPdf(String uid, String name, File f) =>
      _upload('cv/$uid/$name', f, contentType: 'application/pdf');

  // ── Upload lampiran chat ──────────────────────────────────────────────────
  /// Upload gambar dari chat. Path: chat/images/{timestamp}.jpg
  Future<String> uploadChatGambar(File f) {
    final ts = DateTime.now().millisecondsSinceEpoch;
    return _upload('chat/images/$ts.jpg', f, contentType: 'image/jpeg');
  }

  /// Upload PDF dari chat. Path: chat/pdfs/{timestamp}.pdf
  Future<String> uploadChatPdf(File f) {
    final ts = DateTime.now().millisecondsSinceEpoch;
    return _upload('chat/pdfs/$ts.pdf', f, contentType: 'application/pdf');
  }
}