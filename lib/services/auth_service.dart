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
    return user;
  }

  Future<UserModel?> login({required String email, required String password}) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return getUserData(cred.user!.uid);
  }

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