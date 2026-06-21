import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authState => _auth.authStateChanges();

  Future<UserModel?> register({required String email, required String password,
      required String nama, required String role, int? usia,
      List<String> keahlian = const [], List<String> pengalaman = const []}) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    await cred.user!.updateDisplayName(nama);
    final user = UserModel(uid: cred.user!.uid, nama: nama, email: email, role: role,
        usia: usia, keahlian: keahlian, pengalaman: pengalaman, isVerified: role == 'student');
    await _db.collection('users').doc(cred.user!.uid).set(user.toMap());
    // Kirim email verifikasi (berisi link) ke alamat yang baru didaftarkan.
    // Akun TETAP dibuat walau email belum diverifikasi — pengecekan
    // emailVerified dilakukan terpisah di LoginScreen/SplashScreen sebelum
    // user diizinkan masuk ke halaman utama.
    await cred.user!.sendEmailVerification();
    return user;
  }

  Future<UserModel?> login({required String email, required String password}) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return getUserData(cred.user!.uid);
  }

  /// Cek status verifikasi email TERKINI dari server Firebase (bukan cache
  /// lokal), karena status emailVerified hanya berubah di server saat user
  /// klik link di emailnya — perlu reload() supaya client tahu perubahannya.
  Future<bool> reloadDanCekEmailVerified() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  /// Kirim ulang email verifikasi (dipakai di VerifyEmailScreen jika user
  /// tidak menerima email pertama / link sudah kedaluwarsa).
  Future<void> kirimUlangVerifikasi() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  /// Kirim email reset password (berisi link dari Firebase) ke alamat
  /// yang diberikan. Tidak melempar error spesifik kalau email tidak
  /// terdaftar — caller cukup tampilkan pesan sukses generik demi
  /// menghindari kebocoran info "email ini terdaftar/tidak" (enumeration).
  Future<void> kirimResetPassword(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  Future<UserModel?> getUserData(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!, doc.id);
  }

  Future<void> updateProfil(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
    if (data.containsKey('nama')) {
      await _auth.currentUser?.updateDisplayName(data['nama']);
    }
  }

  Future<void> logout() => _auth.signOut();
}