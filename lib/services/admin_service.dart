import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  final _db = FirebaseFirestore.instance;

  Stream<List<Map<String,dynamic>>> streamTutorPending() => _db.collection('users')
      .where('role', isEqualTo: 'tutor').where('isVerified', isEqualTo: false)
      .snapshots().map((s) => s.docs.map((d) => {...d.data(), 'uid': d.id}).toList());

  Stream<List<Map<String,dynamic>>> streamTutorVerified() => _db.collection('users')
      .where('role', isEqualTo: 'tutor').where('isVerified', isEqualTo: true)
      .snapshots().map((s) => s.docs.map((d) => {...d.data(), 'uid': d.id}).toList());

  Stream<List<Map<String,dynamic>>> streamStudent() => _db.collection('users')
      .where('role', isEqualTo: 'student')
      .snapshots().map((s) => s.docs.map((d) => {...d.data(), 'uid': d.id}).toList());

  Future<void> verifikasiTutor(String uid) => _db.collection('users').doc(uid).update({'isVerified': true});
  Future<void> tolakTutor(String uid) => _db.collection('users').doc(uid).delete();
  Future<void> suspendUser(String uid) => _db.collection('users').doc(uid).update({'isSuspended': true});
  Future<void> aktifkanUser(String uid) => _db.collection('users').doc(uid).update({'isSuspended': false});
}