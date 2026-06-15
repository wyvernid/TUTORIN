import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/kelas_service.dart';
import '../../models/booking_model.dart';

class TutorRiwayatPembayaranScreen extends StatelessWidget {
  const TutorRiwayatPembayaranScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final service = KelasService();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Riwayat Pembayaran'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<List<BookingModel>>(
        stream: service.streamBookingTutor(uid),
        builder: (_, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // Filter hanya booking yang sudah dikonfirmasi atau selesai sebagai pendapatan
          final riwayat = snap.data!
              .where((b) => b.status == 'confirmed' || b.status == 'completed')
              .toList();

          if (riwayat.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.account_balance_wallet_outlined, size: 56, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Text('Belum ada riwayat pembayaran', style: TextStyle(color: Colors.grey[400], fontSize: 14)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: riwayat.length,
            itemBuilder: (_, i) {
              final b = riwayat[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 46, height: 46,
                      decoration: BoxDecoration(color: Colors.green[50], shape: BoxShape.circle),
                      child: const Icon(Icons.monetization_on_rounded, color: Colors.green, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(b.kelasJudul, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 2),
                          Text('Murid: ${b.studentNama}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                          const SizedBox(height: 2),
                          Text('${b.jadwalDipilih} · ${b.jamDipilih}', style: TextStyle(fontSize: 10, color: Colors.grey[400])),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('+ Rp${(b.nominal / 1000).toStringAsFixed(0)}.000', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.green)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                          child: Text(b.statusLabel, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.grey[600])),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}