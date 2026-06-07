import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  // ── Upload ke Supabase Storage ────────────────────────────────────────────
  Future<String> _upload(String path, File file) async {
    final bytes = await file.readAsBytes();

    await _supabase.storage.from(_bucket).uploadBinary(
      path,
      bytes,
      fileOptions: const FileOptions(
        contentType: 'image/jpeg',
        upsert: true,   // timpa jika sudah ada
      ),
    );

    return _supabase.storage.from(_bucket).getPublicUrl(path);
  }

  Future<String> uploadFotoProfil(String uid, File f) =>
      _upload('profil/$uid/foto.jpg', f);

  Future<String> uploadBuktiBayar(String bookingId, File f) =>
      _upload('bukti_bayar/$bookingId.jpg', f);

  Future<String> uploadBuktiLaporan(String laporanId, File f) =>
      _upload('laporan/$laporanId.jpg', f);

  Future<String> uploadPortofolio(String uid, String name, File f) =>
      _upload('portofolio/$uid/$name', f);
}