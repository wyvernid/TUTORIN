import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/notifikasi_model.dart';
import 'notifikasi_service.dart';
import 'onesignal_service.dart'; // ← TAMBAH

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  final _notif = NotifikasiService();

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authState => _auth.authStateChanges();

  Future<UserModel?> register({
    required String email,
    required String password,
    required String nama,
    required String role,
    int? usia,
    List<String> keahlian = const [],
    List<String> pengalaman = const [],
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    await cred.user!.updateDisplayName(nama);

    final user = UserModel(
        uid: cred.user!.uid,
        nama: nama,
        email: email,
        role: role,
        usia: usia,
        keahlian: keahlian,
        pengalaman: pengalaman,
        isVerified: role == 'student');

    await _db.collection('users').doc(cred.user!.uid).set(user.toMap());
    await cred.user!.sendEmailVerification();

    // daftarkan device ke OneSignal dengan uid
    await OneSignalService.loginUser(cred.user!.uid);

    if (role == 'tutor') {
      try {
        await _notif.kirimKeSemuaAdmin(
          tipe: NotifikasiTipe.tutorMendaftar,
          judul: 'Tutor baru mendaftar',
          pesan: '$nama mendaftar sebagai tutor dan menunggu verifikasi.',
          refId: user.uid,
          refType: 'tutor',
        );
      } catch (e) {
        print('Gagal kirim notifikasi tutor mendaftar: $e');
      }
    }

    return user;
  }

  Future<UserModel?> login(
      {required String email, required String password}) async {
    final cred =
        await _auth.signInWithEmailAndPassword(email: email, password: password);

    await OneSignalService.loginUser(cred.user!.uid);

    return getUserData(cred.user!.uid);
  }

  Future<bool> reloadDanCekEmailVerified() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  Future<void> kirimUlangVerifikasi() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

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

  Future<void> logout() async {
    await OneSignalService.logoutUser();
    await _auth.signOut();
  }
}