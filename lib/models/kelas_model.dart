class KelasModel {
  final String id, tutorId, tutorNama, tutorFotoUrl, judul, deskripsi, kategori;
  final String jamMulai, durasi, mode, lokasi;
  final int harga, kuota, kuotaTerisi, jumlahUlasan;
  final List<String> jadwal, tags;
  final double rating, latitude, longitude;
  final bool isActive;
  final DateTime createdAt;

  KelasModel({required this.id, required this.tutorId, required this.tutorNama,
    this.tutorFotoUrl = "", required this.judul, required this.deskripsi, required this.kategori,
    required this.harga, required this.kuota, this.kuotaTerisi = 0,
    required this.jadwal, required this.jamMulai, required this.durasi,
    this.mode = "offline", this.lokasi = "", this.rating = 0.0, this.jumlahUlasan = 0,
    this.tags = const [], this.latitude = -7.9839, this.longitude = 113.6684,
    this.isActive = true, required this.createdAt});

  bool get isFull => kuotaTerisi >= kuota;
  int get sisaSlot => kuota - kuotaTerisi;
  String get hargaFormatted => "Rp\${(harga/1000).toStringAsFixed(0)}.000";

  factory KelasModel.fromMap(Map<String, dynamic> m, String id) => KelasModel(
    id: id, tutorId: m["tutorId"] ?? "", tutorNama: m["tutorNama"] ?? "",
    tutorFotoUrl: m["tutorFotoUrl"] ?? "", judul: m["judul"] ?? "",
    deskripsi: m["deskripsi"] ?? "", kategori: m["kategori"] ?? "",
    harga: m["harga"] ?? 0, kuota: m["kuota"] ?? 10, kuotaTerisi: m["kuotaTerisi"] ?? 0,
    jadwal: List<String>.from(m["jadwal"] ?? []), jamMulai: m["jamMulai"] ?? "",
    durasi: m["durasi"] ?? "1 jam", mode: m["mode"] ?? "offline", lokasi: m["lokasi"] ?? "",
    rating: (m["rating"] ?? 0.0).toDouble(), jumlahUlasan: m["jumlahUlasan"] ?? 0,
    tags: List<String>.from(m["tags"] ?? []),
    latitude: (m["latitude"] ?? -7.9839).toDouble(), longitude: (m["longitude"] ?? 113.6684).toDouble(),
    isActive: m["isActive"] ?? true,
    createdAt: m["createdAt"] != null ? (m["createdAt"] as dynamic).toDate() : DateTime.now());

  Map<String, dynamic> toMap() => {
    "tutorId": tutorId, "tutorNama": tutorNama, "tutorFotoUrl": tutorFotoUrl,
    "judul": judul, "deskripsi": deskripsi, "kategori": kategori,
    "harga": harga, "kuota": kuota, "kuotaTerisi": kuotaTerisi,
    "jadwal": jadwal, "jamMulai": jamMulai, "durasi": durasi, "mode": mode, "lokasi": lokasi,
    "rating": rating, "jumlahUlasan": jumlahUlasan, "tags": tags,
    "latitude": latitude, "longitude": longitude, "isActive": isActive, "createdAt": createdAt};
}