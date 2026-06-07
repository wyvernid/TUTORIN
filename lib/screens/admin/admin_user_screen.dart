import 'package:flutter/material.dart';
import '../../services/admin_service.dart';

class AdminUserScreen extends StatefulWidget {
  const AdminUserScreen({super.key});
  @override
  State<AdminUserScreen> createState() => _State();
}

class _State extends State<AdminUserScreen> {
  final _service = AdminService();
  final _searchCtrl = TextEditingController();
  String _search = '';

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF5F7FA),
    appBar: AppBar(title: const Text('Kelola Pengguna'), automaticallyImplyLeading: false),
    body: Column(children: [
      Container(color: Colors.white, padding: const EdgeInsets.fromLTRB(14,8,14,12),
        child: TextField(controller: _searchCtrl, onChanged: (v) => setState(() => _search = v),
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(hintText: 'Cari pengguna...', hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
            prefixIcon: const Icon(Icons.search, color: Color(0xFF1565C0), size: 20),
            filled: true, fillColor: const Color(0xFFF5F7FA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            suffixIcon: _search.isNotEmpty ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () => setState(() { _search = ''; _searchCtrl.clear(); })) : null))),
      Expanded(child: StreamBuilder<List<Map<String,dynamic>>>(
        stream: _service.streamStudent(),
        builder: (_, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final list = snap.data!.where((u) => _search.isEmpty || (u['nama'] ?? '').toString().toLowerCase().contains(_search.toLowerCase()) || (u['email'] ?? '').toString().toLowerCase().contains(_search.toLowerCase())).toList();
          if (list.isEmpty) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.person_search_rounded, size: 48, color: Colors.grey[300]), const SizedBox(height: 8), Text('Tidak ada pengguna ditemukan', style: TextStyle(color: Colors.grey[400]))]));
          return ListView.builder(padding: const EdgeInsets.all(14), itemCount: list.length,
            itemBuilder: (_, i) {
              final u = list[i];
              final suspended = u['isSuspended'] ?? false;
              return Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
                  border: suspended ? Border.all(color: Colors.red[100]!) : null,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 5)]),
                child: Row(children: [
                  Container(width: 44, height: 44, decoration: BoxDecoration(color: suspended ? Colors.red[50] : const Color(0xFF1565C0).withOpacity(0.1), shape: BoxShape.circle),
                    child: u['fotoUrl'] != null ? ClipOval(child: Image.network(u['fotoUrl'], fit: BoxFit.cover)) : Icon(Icons.person_rounded, color: suspended ? Colors.red : const Color(0xFF1565C0), size: 24)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Flexible(child: Text(u['nama'] ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
                      if (suspended) ...[const SizedBox(width: 6), Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(10)), child: Text('Suspended', style: TextStyle(fontSize: 9, color: Colors.red[700], fontWeight: FontWeight.w700)))],
                    ]),
                    Text(u['email'] ?? '', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                    Text('${u["totalKelasSelesai"] ?? 0} kelas', style: TextStyle(fontSize: 10, color: Colors.grey[400])),
                  ])),
                  PopupMenuButton<String>(onSelected: (v) async {
                    if (v == 'suspend') await _service.suspendUser(u['uid']);
                    else if (v == 'aktif') await _service.aktifkanUser(u['uid']);
                  }, itemBuilder: (_) => [
                    PopupMenuItem(value: suspended ? 'aktif' : 'suspend',
                      child: Text(suspended ? 'Aktifkan Akun' : 'Suspend Akun', style: TextStyle(color: suspended ? Colors.green : Colors.red))),
                  ], child: const Icon(Icons.more_vert_rounded, color: Color(0xFF78909C))),
                ]));
            });
        })),
    ]));
}