class JadwalSesi {
  final DateTime tanggal;
  final List<String> jamList; // contoh: ['14:00', '16:00']

  JadwalSesi({required this.tanggal, required this.jamList});

  factory JadwalSesi.fromMap(Map<String, dynamic> m) => JadwalSesi(
        tanggal: m['tanggal'] != null ? (m['tanggal'] as dynamic).toDate() : DateTime.now(),
        jamList: List<String>.from(m['jamList'] ?? []),
      );

  Map<String, dynamic> toMap() => {
        'tanggal': tanggal,
        'jamList': jamList,
      };

  String get tanggalFormatted {
    const hari = ['Senin','Selasa','Rabu','Kamis','Jumat','Sabtu','Minggu'];
    const bulan = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
    final namaHari = hari[tanggal.weekday - 1];
    return '$namaHari, ${tanggal.day} ${bulan[tanggal.month - 1]} ${tanggal.year}';
  }
}