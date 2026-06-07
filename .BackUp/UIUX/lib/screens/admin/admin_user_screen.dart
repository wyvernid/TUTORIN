import 'package:flutter/material.dart';

class AdminUserScreen extends StatelessWidget {
  const AdminUserScreen({super.key});

  static final List<Map<String, dynamic>> _users = [
    {'name': 'Nafisa Nurin', 'email': 'nafisa@example.com', 'role': 'Student', 'classes': 18, 'status': 'active', 'joined': 'Jan 2026'},
    {'name': 'Budi Santoso', 'email': 'budi@example.com', 'role': 'Student', 'classes': 3, 'status': 'active', 'joined': 'Feb 2026'},
    {'name': 'Rafi Maulana', 'email': 'rafi@example.com', 'role': 'Student', 'classes': 7, 'status': 'active', 'joined': 'Mar 2026'},
    {'name': 'Sari Dewi', 'email': 'sari@example.com', 'role': 'Student', 'classes': 5, 'status': 'suspended', 'joined': 'Apr 2026'},
    {'name': 'Hendra Wijaya', 'email': 'hendra@example.com', 'role': 'Student', 'classes': 1, 'status': 'active', 'joined': 'Apr 2026'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Kelola Pengguna'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(icon: const Icon(Icons.search_rounded), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Cari pengguna...',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF1565C0), size: 20),
                filled: true, fillColor: const Color(0xFFF5F7FA),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _users.length,
              itemBuilder: (ctx, i) {
                final u = _users[i];
                final isSuspended = u['status'] == 'suspended';
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: isSuspended ? Border.all(color: Colors.red[100]!) : null,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 5)],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: isSuspended ? Colors.red[50] : const Color(0xFF1565C0).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.person_rounded,
                            color: isSuspended ? Colors.red : const Color(0xFF1565C0), size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            Text(u['name'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                            const SizedBox(width: 6),
                            if (isSuspended)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(10)),
                                child: Text('Suspended', style: TextStyle(fontSize: 9, color: Colors.red[700], fontWeight: FontWeight.w700)),
                              ),
                          ]),
                          Text(u['email'], style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                          const SizedBox(height: 3),
                          Text('${u['classes']} kelas · Bergabung ${u['joined']}',
                              style: TextStyle(fontSize: 10, color: Colors.grey[400])),
                        ]),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (v) {},
                        itemBuilder: (_) => [
                          const PopupMenuItem(value: 'detail', child: Text('Lihat Detail')),
                          PopupMenuItem(
                            value: 'suspend',
                            child: Text(isSuspended ? 'Aktifkan Akun' : 'Suspend Akun',
                                style: TextStyle(color: isSuspended ? Colors.green : Colors.red)),
                          ),
                        ],
                        child: const Icon(Icons.more_vert_rounded, color: Color(0xFF78909C)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
