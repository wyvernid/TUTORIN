import 'package:cloud_firestore/cloud_firestore.dart';

class UlasanModel {
  final String id;
  final String kelasId;
  final String tutorId;
  final String studentNama;
  final int rating;
  final String komentar;
  final DateTime createdAt;

  UlasanModel({
    required this.id,
    required this.kelasId,
    required this.tutorId,
    required this.studentNama,
    required this.rating,
    required this.komentar,
    required this.createdAt,
  });

  factory UlasanModel.fromMap(Map<String, dynamic> m, String id) => UlasanModel(
        id: id,
        kelasId: m['kelasId'] ?? '',
        tutorId: m['tutorId'] ?? '',
        studentNama: m['studentNama'] ?? '',
        rating: (m['rating'] ?? 0) is int ? m['rating'] ?? 0 : (m['rating'] as num).toInt(),
        komentar: m['komentar'] ?? '',
        createdAt: (m['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
}