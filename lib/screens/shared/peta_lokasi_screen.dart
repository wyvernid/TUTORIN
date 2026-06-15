import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class PetaLokasiScreen extends StatefulWidget {
  final LatLng? initialPosition;
  final bool pickMode;
  final String? judulKelas;
  const PetaLokasiScreen({super.key, this.initialPosition, this.pickMode = false, this.judulKelas});
  @override
  State<PetaLokasiScreen> createState() => _State();
}

class _State extends State<PetaLokasiScreen> {
  final _map = MapController();
  LatLng _pos = const LatLng(-7.9839, 113.6684);
  LatLng? _selected;
  bool _loading = true;
  String? _alamat;
  bool _loadingAlamat = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialPosition != null) {
      _pos = widget.initialPosition!; _selected = _pos; _loading = false;
      _ambilAlamat(_pos);
    } else { _getLocation(); }
  }

  Future<void> _getLocation() async {
    setState(() => _loading = true);
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.deniedForever) { setState(() => _loading = false); return; }
      final p = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() { _pos = LatLng(p.latitude, p.longitude); if (widget.pickMode) _selected = _pos; _loading = false; });
      _map.move(_pos, 15.0);
      if (widget.pickMode) _ambilAlamat(_pos);
    } catch (_) { setState(() => _loading = false); }
  }

  /// Reverse geocoding: lat/long -> alamat, menggunakan geocoder native OS (gratis, tanpa API key)
  Future<void> _ambilAlamat(LatLng point) async {
    setState(() => _loadingAlamat = true);
    try {
      final placemarks = await placemarkFromCoordinates(point.latitude, point.longitude);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final bagian = [p.street, p.subLocality, p.locality, p.subAdministrativeArea, p.administrativeArea]
            .where((e) => e != null && e.trim().isNotEmpty)
            .toSet() // hilangkan duplikat berurutan
            .join(', ');
        if (!mounted) return;
        setState(() {
          _alamat = bagian.isNotEmpty ? bagian : 'Alamat tidak ditemukan';
          _loadingAlamat = false;
        });
      } else {
        if (!mounted) return;
        setState(() { _alamat = 'Alamat tidak ditemukan'; _loadingAlamat = false; });
      }
    } catch (e) {
      debugPrint('GEOCODING ERROR: $e');
      if (!mounted) return;
      setState(() { _alamat = 'Gagal memuat alamat'; _loadingAlamat = false; });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.pickMode ? 'Pilih Lokasi Kelas' : 'Lokasi Kelas'),
      leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: () => Navigator.pop(context)),
      actions: widget.pickMode && _selected != null ? [
        TextButton(onPressed: () => Navigator.pop(context, {'latlng': _selected, 'alamat': _alamat}),
          child: const Text('Pilih', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)))] : null),
    body: _loading ? const Center(child: CircularProgressIndicator())
        : Stack(children: [
          FlutterMap(mapController: _map, options: MapOptions(
            initialCenter: _pos, initialZoom: 15.0,
            onTap: widget.pickMode ? (_, pt) {
              setState(() => _selected = pt);
              _ambilAlamat(pt);
            } : null),
            children: [
              TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.tutorin.app'),
              MarkerLayer(markers: [
                if (_selected != null) Marker(point: _selected!, width: 50, height: 58,
                  child: Column(children: [
                    Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFF1565C0), borderRadius: BorderRadius.circular(6)),
                      child: Text(widget.judulKelas ?? 'Lokasi', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    const Icon(Icons.location_pin, color: Colors.red, size: 30),
                  ])),
                if (widget.initialPosition == null) Marker(point: _pos, width: 18, height: 18,
                  child: Container(decoration: BoxDecoration(color: const Color(0xFF1565C0), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)))),
              ]),
            ]),
          if (widget.pickMode) Positioned(bottom: 80, left: 16, right: 16,
            child: Container(padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)]),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                Row(children: [
                  const Icon(Icons.touch_app_rounded, color: Color(0xFF1565C0), size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_selected != null
                      ? 'Dipilih: ${_selected!.latitude.toStringAsFixed(5)}, ${_selected!.longitude.toStringAsFixed(5)}'
                      : 'Tap pada peta untuk memilih lokasi',
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]))),
                ]),
                if (_selected != null) Padding(
                  padding: const EdgeInsets.only(top: 6, left: 26),
                  child: _loadingAlamat
                      ? Row(children: const [
                          SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2)),
                          SizedBox(width: 8),
                          Text('Mencari alamat...', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ])
                      : Text(_alamat ?? '', style: TextStyle(fontSize: 12, color: Colors.grey[800]), maxLines: 2, overflow: TextOverflow.ellipsis),
                ),
              ]))),
        ]),
    floatingActionButton: FloatingActionButton(backgroundColor: const Color(0xFF1565C0), mini: true,
      onPressed: _getLocation, child: const Icon(Icons.my_location_rounded, color: Colors.white, size: 20)),
  );
}