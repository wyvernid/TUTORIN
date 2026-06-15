import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_file/open_file.dart';
import '../../services/storage_service.dart';

class TutorUploadPortofolioScreen extends StatefulWidget {
  const TutorUploadPortofolioScreen({super.key});

  @override
  State<TutorUploadPortofolioScreen> createState() => _State();
}

class _State extends State<TutorUploadPortofolioScreen> {
  File? _pdfFile;
  bool _isUploading = false;
  bool _isLoadingData = true;
  String? _existingPortofolioUrl;
  
  final _storage = StorageService();

  @override
  void initState() {
    super.initState();
    _loadPortofolioTerdahulu();
  }

  Future<void> _loadPortofolioTerdahulu() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists && mounted) {
        setState(() {
          _existingPortofolioUrl = doc.data()?['portofolioUrl'];
        });
      }
    } catch (e) {
      debugPrint('Gagal memuat data portofolio: $e');
    } finally {
      if (mounted) setState(() => _isLoadingData = false);
    }
  }

  // Mengambil nama file dari URL Supabase (memotong string URL-nya)
  String get _uploadedFileName {
    if (_existingPortofolioUrl == null) return '';
    try {
      // Hapus bagian query param (?updatedAt=...)
      final urlWithoutQuery = _existingPortofolioUrl!.split('?').first;
      // Ambil bagian teks paling belakang setelah garis miring terakhir
      return Uri.decodeComponent(urlWithoutQuery.split('/').last);
    } catch (e) {
      return 'Dokumen_Portofolio.pdf';
    }
  }

  Future<void> _bukaPortofolioRemote() async {
    if (_existingPortofolioUrl == null) return;
    final url = Uri.parse(_existingPortofolioUrl!);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw 'Tidak bisa membuka tautan';
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuka file: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _bukaPortofolioLokal() async {
    if (_pdfFile == null) return;
    try {
      final result = await OpenFile.open(_pdfFile!.path);
      if (result.type != ResultType.done && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('HP kamu tidak memiliki aplikasi pembaca PDF.'), backgroundColor: Colors.orange),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuka file lokal: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _pilihPdf() async {
    final file = await _storage.ambilFilePdf();
    if (file != null) {
      setState(() => _pdfFile = file);
    }
  }

  void _batalPilih() {
    setState(() => _pdfFile = null);
  }

  void _upload() async {
    if (_pdfFile == null) return;
    setState(() => _isUploading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final namaFile = 'portofolio_${DateTime.now().millisecondsSinceEpoch}.pdf';
      
      final url = await _storage.uploadPortofolioPdf(uid, namaFile, _pdfFile!);

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'portofolioUrl': url
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Portofolio berhasil diperbarui!'), backgroundColor: Colors.green),
      );
      
      setState(() {
        _existingPortofolioUrl = url;
        _pdfFile = null;
      });
      
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal upload: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fileNameLokal = _pdfFile?.path.split('/').last ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Upload Portofolio'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoadingData 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Portofolio Tutor',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1565C0)),
                ),
                const SizedBox(height: 8),
                Text(
                  'Upload CV, sertifikat, atau dokumen pengalaman mengajar untuk meyakinkan calon murid. Wajib dalam format PDF.',
                  style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.5),
                ),
                const SizedBox(height: 32),
                
                // KONDISI 1: SUDAH ADA DATA DI DATABASE
                if (_existingPortofolioUrl != null && _pdfFile == null) ...[
                  GestureDetector(
                    onTap: _bukaPortofolioRemote,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.green[300]!, width: 2),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: Colors.green[50], shape: BoxShape.circle),
                            child: const Icon(Icons.picture_as_pdf_rounded, size: 48, color: Colors.green),
                          ),
                          const SizedBox(height: 16),
                          const Text('Portofolio Aktif', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.green)),
                          const SizedBox(height: 4),
                          
                          // -- MENAMPILKAN NAMA FILE YANG SUDAH DI-UPLOAD --
                          Text(
                            _uploadedFileName, 
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1565C0))
                          ),
                          
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Ketuk untuk melihat dokumen ', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                              const Icon(Icons.open_in_new_rounded, size: 14, color: Colors.grey),
                            ],
                          ),
                          const SizedBox(height: 24),
                          OutlinedButton.icon(
                            onPressed: _pilihPdf, 
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: const Text('Ganti File Portofolio'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF1565C0),
                              side: const BorderSide(color: Color(0xFF1565C0)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] 
                
                // KONDISI 2: SEDANG MEMILIH FILE LOKAL
                else if (_pdfFile != null) ...[
                  GestureDetector(
                    onTap: _bukaPortofolioLokal, 
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF1565C0), width: 2),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.picture_as_pdf_rounded, size: 56, color: Colors.red[400]),
                          const SizedBox(height: 16),
                          Text(
                            fileNameLokal,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1565C0)),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Ketuk untuk baca file sebelum diupload ', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                              const Icon(Icons.visibility_rounded, size: 12, color: Colors.grey),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton.icon(
                        onPressed: _isUploading ? null : _pilihPdf,
                        icon: const Icon(Icons.search_rounded, size: 18),
                        label: const Text('Pilih File Lain'),
                      ),
                      if (_existingPortofolioUrl != null && !_isUploading) ...[
                        const SizedBox(width: 16),
                        TextButton.icon(
                          onPressed: _batalPilih,
                          icon: Icon(Icons.close_rounded, size: 18, color: Colors.grey[600]),
                          label: Text('Batal', style: TextStyle(color: Colors.grey[600])),
                        ),
                      ]
                    ],
                  )
                ]
                
                // KONDISI 3: BELUM PUNYA DATA SAMA SEKALI
                else ...[
                  GestureDetector(
                    onTap: _pilihPdf,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey[300]!, width: 1),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.upload_file_rounded, size: 56, color: const Color(0xFF1565C0).withOpacity(0.5)),
                          const SizedBox(height: 16),
                          const Text(
                            'Ketuk untuk mencari file PDF',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black87),
                          ),
                          const SizedBox(height: 8),
                          Text('Max ukuran file: 5 MB', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 40),
                
                // TOMBOL UPLOAD UTAMA
                if (_pdfFile != null) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isUploading ? null : _upload,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        backgroundColor: const Color(0xFF1565C0),
                        disabledBackgroundColor: Colors.grey[300],
                      ),
                      child: _isUploading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(
                              _existingPortofolioUrl != null ? 'Simpan Update Portofolio' : 'Upload Portofolio', 
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)
                            ),
                    ),
                  ),
                ],
              ],
            ),
          ),
    );
  }
}