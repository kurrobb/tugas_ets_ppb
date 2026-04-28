import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import '../../core/app_colors.dart';
import '../../core/location_utils.dart';

/// Halaman untuk memilih lokasi parkiran di peta
/// Mengembalikan LatLng yang dipilih user
class MapPickerScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;

  const MapPickerScreen({
    super.key,
    this.initialLat,
    this.initialLng,
  });

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  final MapController _mapController = MapController();
  LatLng? _selectedPosition;
  LatLng _mapCenter = const LatLng(-6.200000, 106.816666); // Jakarta default
  bool _isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialLat != null && widget.initialLng != null) {
      _selectedPosition = LatLng(widget.initialLat!, widget.initialLng!);
      _mapCenter = _selectedPosition!;
      _isLoadingLocation = false;
    } else {
      _getCurrentLocation();
    }
  }

  /// Mendapatkan lokasi saat ini
  Future<void> _getCurrentLocation() async {
    try {
      final position = await LocationUtils.getCurrentPosition();
      final latLng = LatLng(position.latitude, position.longitude);
      setState(() {
        _mapCenter = latLng;
        _selectedPosition = latLng;
        _isLoadingLocation = false;
      });
      _mapController.move(latLng, 16);
    } catch (e) {
      setState(() => _isLoadingLocation = false);
      debugPrint('Error getting location: $e');
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Lokasi'),
        actions: [
          // Tombol konfirmasi
          TextButton.icon(
            onPressed: _selectedPosition != null
                ? () => Navigator.of(context).pop(_selectedPosition)
                : null,
            icon: const Icon(Icons.check, color: Colors.white),
            label: Text(
              'Pilih',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _mapCenter,
              initialZoom: 16,
              onTap: (tapPosition, point) {
                setState(() => _selectedPosition = point);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.parkingfinder.parking_finder',
              ),
              // Marker lokasi yang dipilih
              if (_selectedPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedPosition!,
                      width: 50,
                      height: 50,
                      child: const Icon(
                        Icons.location_on,
                        color: AppColors.error,
                        size: 50,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          // Instruksi
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.touch_app, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tap di peta untuk memilih lokasi parkiran',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Koordinat yang dipilih
          if (_selectedPosition != null)
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 15,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.gps_fixed, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Lokasi Dipilih',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            'Lat: ${_selectedPosition!.latitude.toStringAsFixed(6)}',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Lng: ${_selectedPosition!.longitude.toStringAsFixed(6)}',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Tombol konfirmasi
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(_selectedPosition),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: const Text('Pilih'),
                    ),
                  ],
                ),
              ),
            ),
          // Loading
          if (_isLoadingLocation)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
      // FAB lokasi saat ini
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: _selectedPosition != null ? 100 : 0),
        child: FloatingActionButton.small(
          heroTag: 'mapPickerLocation',
          onPressed: _getCurrentLocation,
          backgroundColor: Colors.white,
          child: const Icon(Icons.my_location, color: AppColors.primary),
        ),
      ),
    );
  }
}
