class LaporanModel {
  final String id, fromUid, fromNama, fromRole, againstUid, againstNama, againstRole;
  final String kategori, deskripsi, status;
  final String? buktiUrl, catatanAdmin;
  final DateTime createdAt;

  LaporanModel({required this.id, required this.fromUid, required this.fromNama,
    required this.fromRole, required this.againstUid, required this.againstNama,
    required this.againstRole, required this.kategori, required this.deskripsi,
    this.buktiUrl, this.status = "open", this.catatanAdmin, required this.createdAt});

  factory LaporanModel.fromMap(Map<String, dynamic> m, String id) => LaporanModel(
    id: id, fromUid: m["fromUid"] ?? "", fromNama: m["fromNama"] ?? "",
    fromRole: m["fromRole"] ?? "", againstUid: m["againstUid"] ?? "",
    againstNama: m["againstNama"] ?? "", againstRole: m["againstRole"] ?? "",
    kategori: m["kategori"] ?? "", deskripsi: m["deskripsi"] ?? "",
    buktiUrl: m["buktiUrl"], status: m["status"] ?? "open", catatanAdmin: m["catatanAdmin"],
    createdAt: m["createdAt"] != null ? (m["createdAt"] as dynamic).toDate() : DateTime.now());

  Map<String, dynamic> toMap() => {
    "fromUid": fromUid, "fromNama": fromNama, "fromRole": fromRole,
    "againstUid": againstUid, "againstNama": againstNama, "againstRole": againstRole,
    "kategori": kategori, "deskripsi": deskripsi, "buktiUrl": buktiUrl,
    "status": status, "catatanAdmin": catatanAdmin, "createdAt": createdAt};
}