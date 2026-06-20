import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../tutor/tutor_home_screen.dart';
import 'login_screen.dart';

/// Halaman perantara untuk tutor yang:
/// - baru register & belum diverifikasi admin (state: pending), atau
/// - sudah ditolak admin (state: rejected) — bisa "Daftar Ulang" pakai
///   akun yang sama tanpa harus bikin akun baru.
class TutorPendingScreen extends StatefulWidget {
  const TutorPendingScreen({super.key});
  @override
  State<TutorPendingScreen> createState() => _TutorPendingScreenState();
}

class _TutorPendingScreenState extends State<TutorPendingScreen> {
  final _auth = AuthService();
  Timer? _autoTimer;
  bool _checking = false;
  bool _daftarUlangLoading = false;
  String? _info;
  bool _rejected = false;
  String? _alasan;

  static const _autoCheckInterval = Duration(seconds: 30);

  @override
  void initState() {
    super.initState();
    _cekStatus(silent: true); // cek sekali saat halaman dibuka
    // Auto-check berkala (tidak terlalu sering, hemat read Firestore).
    _autoTimer = Timer.periodic(_autoCheckInterval, (_) => _cekStatus(silent: true));
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    super.dispose();
  }

  Future<void> _cekStatus({bool silent = false}) async {
    if (_checking) return;
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      if (mounted) _kembaliKeLogin();
      return;
    }

    setState(() {
      _checking = true;
      if (!silent) _info = null;
    });

    try {
      final data = await _auth.getUserData(uid);
      if (!mounted) return;

      // Dokumen sudah tidak ada sama sekali (kasus lama / dihapus manual)
      if (data == null) {
        _kembaliKeLogin();
        return;
      }

      if (data.isVerified) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const TutorHomeScreen()));
        return;
      }

      setState(() {
        _checking = false;
        _rejected = data.isRejected;
        _alasan = data.alasanTolak;
        if (!silent) {
          _info = data.isRejected
              ? null
              : 'Akun kamu masih dalam proses verifikasi admin.';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _checking = false;
        if (!silent) _info = 'Gagal memeriksa status. Coba lagi.';
      });
    }
  }

  Future<void> _daftarUlang() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    setState(() => _daftarUlangLoading = true);
    try {
      // Reset status ditolak → masuk lagi ke daftar pending admin,
      // pakai akun (uid) yang sama, tidak perlu bikin akun baru.
      await _auth.updateProfil(uid, {'isRejected': false, 'alasanTolak': null});
      if (!mounted) return;
      setState(() {
        _rejected = false;
        _alasan = null;
        _info = 'Pendaftaran berhasil dikirim ulang ke admin.';
        _daftarUlangLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _daftarUlangLoading = false;
        _info = 'Gagal mengirim ulang pendaftaran. Coba lagi.';
      });
    }
  }

  void _kembaliKeLogin() async {
    await _auth.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: (_rejected ? Colors.red : const Color(0xFF1565C0)).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _rejected ? Icons.cancel_outlined : Icons.hourglass_top_rounded,
                    size: 48,
                    color: _rejected ? Colors.red : const Color(0xFF1565C0),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  _rejected ? 'Pendaftaran Ditolak' : 'Menunggu Verifikasi',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                Text(
                  _rejected
                      ? (_alasan != null && _alasan!.isNotEmpty
                          ? 'Alasan: $_alasan\n\nKamu bisa memperbaiki data lalu daftar ulang menggunakan akun yang sama.'
                          : 'Pendaftaran tutor kamu ditolak oleh admin. Kamu bisa daftar ulang menggunakan akun yang sama.')
                      : 'Akun tutor kamu sedang diperiksa oleh admin. '
                        'Kamu akan otomatis masuk ke halaman tutor begitu akun '
                        'disetujui. Proses ini biasanya tidak butuh waktu lama.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13.5, color: Colors.grey[600], height: 1.5),
                ),
                const SizedBox(height: 28),
                if (_info != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _info!,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12.5, color: Colors.grey[700]),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                if (_rejected) ...[
                  // State ditolak → tombol utama adalah Daftar Ulang
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _daftarUlangLoading ? null : _daftarUlang,
                      icon: _daftarUlangLoading
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.refresh_rounded, size: 18),
                      label: Text(_daftarUlangLoading ? 'Mengirim...' : 'Daftar Ulang'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ] else ...[
                  // State pending → tombol utama adalah Cek Status
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _checking ? null : () => _cekStatus(silent: false),
                      icon: _checking
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.refresh_rounded, size: 18),
                      label: Text(_checking ? 'Memeriksa...' : 'Cek Status'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _kembaliKeLogin,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1565C0),
                      side: const BorderSide(color: Color(0xFF1565C0)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Kembali ke Login',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}