class BookingModel {
  final String id, kelasId, kelasJudul, tutorId, tutorNama, studentId, studentNama;
  final String jadwalDipilih, jamDipilih, noTelepon, status;
  final int nominal;
  final String? buktiBayarUrl, alasanTolak;
  final bool reviewed;
  final DateTime createdAt;
  final DateTime? confirmedAt;

  BookingModel({required this.id, required this.kelasId, required this.kelasJudul,
    required this.tutorId, required this.tutorNama, required this.studentId, required this.studentNama,
    required this.jadwalDipilih, required this.jamDipilih, required this.noTelepon,
    required this.nominal, this.status = "waiting_payment",
    this.buktiBayarUrl, this.alasanTolak, this.reviewed = false,
    required this.createdAt, this.confirmedAt});

  String get statusLabel {
    switch (status) {
      case "waiting_payment": return "Menunggu Pembayaran";
      case "waiting_verification": return "Menunggu Verifikasi";
      case "confirmed": return "Terkonfirmasi";
      case "rejected": return "Ditolak";
      case "completed": return "Selesai";
      default: return status;
    }
  }

  factory BookingModel.fromMap(Map<String, dynamic> m, String id) => BookingModel(
    id: id, kelasId: m["kelasId"] ?? "", kelasJudul: m["kelasJudul"] ?? "",
    tutorId: m["tutorId"] ?? "", tutorNama: m["tutorNama"] ?? "",
    studentId: m["studentId"] ?? "", studentNama: m["studentNama"] ?? "",
    jadwalDipilih: m["jadwalDipilih"] ?? "", jamDipilih: m["jamDipilih"] ?? "",
    noTelepon: m["noTelepon"] ?? "", nominal: m["nominal"] ?? 0,
    status: m["status"] ?? "waiting_payment",
    buktiBayarUrl: m["buktiBayarUrl"], alasanTolak: m["alasanTolak"],
    reviewed: m["reviewed"] ?? false,
    createdAt: m["createdAt"] != null ? (m["createdAt"] as dynamic).toDate() : DateTime.now(),
    confirmedAt: m["confirmedAt"] != null ? (m["confirmedAt"] as dynamic).toDate() : null);

  Map<String, dynamic> toMap() => {
    "kelasId": kelasId, "kelasJudul": kelasJudul, "tutorId": tutorId, "tutorNama": tutorNama,
    "studentId": studentId, "studentNama": studentNama, "jadwalDipilih": jadwalDipilih,
    "jamDipilih": jamDipilih, "noTelepon": noTelepon, "nominal": nominal,
    "status": status, "buktiBayarUrl": buktiBayarUrl, "alasanTolak": alasanTolak,
    "reviewed": reviewed, "createdAt": createdAt, "confirmedAt": confirmedAt};
}