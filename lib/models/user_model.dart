class UserModel {
  final String uid, nama, email, role;
  final String? fotoUrl, noTelepon, sosialMedia, cvUrl, portofolioUrl;
  final int? usia;
  final int totalKelasSelesai, totalMurid;
  final List<String> keahlian, pengalaman;
  final bool isVerified, isSuspended;
  final double rating;

  // ── Status Penolakan Tutor ──
  final bool isRejected;
  final String? alasanTolak;

  // ── Info rekening tutor (opsional) ──
  final String? namaBank;       
  final String? nomorRekening;  
  final String? namaRekening;   

  UserModel({
    required this.uid,
    required this.nama,
    required this.email,
    required this.role,
    this.fotoUrl,
    this.noTelepon,
    this.sosialMedia,
    this.cvUrl,
    this.portofolioUrl,
    this.usia,
    this.totalKelasSelesai = 0,
    this.totalMurid = 0,
    this.keahlian = const [],
    this.pengalaman = const [],
    this.isVerified = false,
    this.isSuspended = false,
    this.rating = 0.0,
    this.isRejected = false,
    this.alasanTolak,
    this.namaBank,
    this.nomorRekening,
    this.namaRekening,
  });

  /// Helper: apakah tutor ini sudah mengisi info rekening?
  bool get punyaRekening =>
      namaBank != null && namaBank!.trim().isNotEmpty &&
      nomorRekening != null && nomorRekening!.trim().isNotEmpty;

  factory UserModel.fromMap(Map<String, dynamic> m, String uid) => UserModel(
        uid: uid,
        nama: m["nama"] ?? "",
        email: m["email"] ?? "",
        role: m["role"] ?? "student",
        fotoUrl: m["fotoUrl"],
        noTelepon: m["noTelepon"],
        sosialMedia: m["sosialMedia"],
        cvUrl: m["cvUrl"],
        portofolioUrl: m["portofolioUrl"],
        usia: m["usia"],
        totalKelasSelesai: m["totalKelasSelesai"] ?? 0,
        totalMurid: m["totalMurid"] ?? 0,
        keahlian: List<String>.from(m["keahlian"] ?? []),
        pengalaman: List<String>.from(m["pengalaman"] ?? []),
        isVerified: m["isVerified"] ?? false,
        isSuspended: m["isSuspended"] ?? false,
        rating: (m["rating"] ?? 0.0).toDouble(),
        isRejected: m["isRejected"] ?? false,
        alasanTolak: m["alasanTolak"],
        namaBank: m["namaBank"],
        nomorRekening: m["nomorRekening"],
        namaRekening: m["namaRekening"],
      );

  Map<String, dynamic> toMap() => {
        "nama": nama,
        "email": email,
        "role": role,
        "fotoUrl": fotoUrl,
        "noTelepon": noTelepon,
        "sosialMedia": sosialMedia,
        "cvUrl": cvUrl,
        "portofolioUrl": portofolioUrl,
        "usia": usia,
        "totalKelasSelesai": totalKelasSelesai,
        "totalMurid": totalMurid,
        "keahlian": keahlian,
        "pengalaman": pengalaman,
        "isVerified": isVerified,
        "isSuspended": isSuspended,
        "rating": rating,
        "isRejected": isRejected,
        "alasanTolak": alasanTolak,
        "namaBank": namaBank,
        "nomorRekening": nomorRekening,
        "namaRekening": namaRekening,
      };
}