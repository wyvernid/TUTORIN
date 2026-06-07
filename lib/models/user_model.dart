class UserModel {
  final String uid, nama, email, role;
  final String? fotoUrl, noTelepon, sosialMedia;
  final int? usia;
  final int totalKelasSelesai, totalMurid;
  final List<String> keahlian, pengalaman;
  final bool isVerified, isSuspended;
  final double rating;

  UserModel({required this.uid, required this.nama, required this.email, required this.role,
    this.fotoUrl, this.noTelepon, this.sosialMedia, this.usia,
    this.totalKelasSelesai = 0, this.totalMurid = 0,
    this.keahlian = const [], this.pengalaman = const [],
    this.isVerified = false, this.isSuspended = false, this.rating = 0.0});

  factory UserModel.fromMap(Map<String, dynamic> m, String uid) => UserModel(
    uid: uid, nama: m["nama"] ?? "", email: m["email"] ?? "", role: m["role"] ?? "student",
    fotoUrl: m["fotoUrl"], noTelepon: m["noTelepon"], sosialMedia: m["sosialMedia"], usia: m["usia"],
    totalKelasSelesai: m["totalKelasSelesai"] ?? 0, totalMurid: m["totalMurid"] ?? 0,
    keahlian: List<String>.from(m["keahlian"] ?? []), pengalaman: List<String>.from(m["pengalaman"] ?? []),
    isVerified: m["isVerified"] ?? false, isSuspended: m["isSuspended"] ?? false,
    rating: (m["rating"] ?? 0.0).toDouble());

  Map<String, dynamic> toMap() => {
    "nama": nama, "email": email, "role": role, "fotoUrl": fotoUrl,
    "noTelepon": noTelepon, "sosialMedia": sosialMedia, "usia": usia,
    "totalKelasSelesai": totalKelasSelesai, "totalMurid": totalMurid,
    "keahlian": keahlian, "pengalaman": pengalaman,
    "isVerified": isVerified, "isSuspended": isSuspended, "rating": rating};
}