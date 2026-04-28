import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/location_utils.dart';
import '../../data/models/parking_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/parking_repository.dart';
import '../../data/repositories/favorite_repository.dart';
import '../widgets/custom_bottom_sheet.dart';
import 'parking_list_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';
import 'add_parking_screen.dart';
import 'parking_detail_screen.dart';

/// Halaman utama dengan bottom navigation (Peta, Daftar, Favorit, Profil)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _screens.addAll([
      const _MapTab(),
      const ParkingListScreen(),
      const FavoritesScreen(),
      const ProfileScreen(),
    ]);

    // Load data awal
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final authRepo = context.read<AuthRepository>();
        if (authRepo.user != null) {
          context.read<FavoriteRepository>().loadFavorites(authRepo.user!.uid);
        }
        context.read<ParkingRepository>().fetchParkings();
      } catch (e) {
        debugPrint('HomeScreen: Error loading initial data: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Peta',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            activeIcon: Icon(Icons.list_alt),
            label: 'Daftar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border),
            activeIcon: Icon(Icons.bookmark),
            label: 'Favorit',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

/// Tab Peta dengan OpenStreetMap (flutter_map)
class _MapTab extends StatefulWidget {
  const _MapTab();

  @override
  State<_MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<_MapTab> {
  final MapController _mapController = MapController();
  LatLng _currentPosition = const LatLng(-6.200000, 106.816666); // Jakarta default
  bool _isLoadingLocation = true;
  StreamSubscription? _parkingSubscription;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _listenToParkings();
  }

  /// Mendengarkan perubahan data parkiran secara realtime
  void _listenToParkings() {
    final parkingRepo = context.read<ParkingRepository>();
    _parkingSubscription = parkingRepo.getParkingsStream().listen((_) {
      if (mounted) setState(() {});
    });
  }

  /// Mendapatkan lokasi saat ini
  Future<void> _getCurrentLocation() async {
    try {
      final position = await LocationUtils.getCurrentPosition();
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;
      });
      _mapController.move(_currentPosition, 15);
    } catch (e) {
      setState(() => _isLoadingLocation = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mendapatkan lokasi: $e')),
      );
    }
  }

  /// Mendapatkan warna marker berdasarkan status
  Color _getMarkerColor(String status) {
    switch (status) {
      case 'kosong':
        return AppColors.statusKosong;
      case 'penuh':
        return AppColors.statusPenuh;
      default:
        return AppColors.statusUnknown;
    }
  }

  /// Membuat list marker dari data parkiran
  List<Marker> _buildMarkers(List<ParkingModel> parkings) {
    return parkings.map((parking) {
      final markerColor = _getMarkerColor(parking.status);

      return Marker(
        point: LatLng(parking.lat, parking.lng),
        width: 40,
        height: 40,
        child: GestureDetector(
          onTap: () {
            final distance = LocationUtils.formatDistance(
              LocationUtils.calculateDistance(
                _currentPosition.latitude,
                _currentPosition.longitude,
                parking.lat,
                parking.lng,
              ),
            );

            CustomBottomSheet.show(
              context,
              parking: parking,
              distance: distance,
              onViewDetail: () {
                Navigator.of(context).pop(); // tutup bottom sheet
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ParkingDetailScreen(parking: parking),
                  ),
                );
              },
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: markerColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: markerColor.withValues(alpha: 0.4),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Icon(
              Icons.local_parking,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      );
    }).toList();
  }

  @override
  void dispose() {
    _parkingSubscription?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final parkingRepo = context.watch<ParkingRepository>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Parking Finder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              parkingRepo.fetchParkings();
              _getCurrentLocation();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // OpenStreetMap
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition,
              initialZoom: 14,
            ),
            children: [
              // Tile layer (OpenStreetMap)
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.parkingfinder.parking_finder',
              ),
              // Marker lokasi user
              MarkerLayer(
                markers: [
                  Marker(
                    point: _currentPosition,
                    width: 24,
                    height: 24,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withValues(alpha: 0.3),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // Marker parkiran
              MarkerLayer(
                markers: _buildMarkers(parkingRepo.parkings),
              ),
            ],
          ),
          // Loading indicator
          if (_isLoadingLocation || parkingRepo.isLoading)
            Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text('Memuat...'),
                    ],
                  ),
                ),
              ),
            ),
          // Legend
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _legendItem(AppColors.statusKosong, 'Tersedia'),
                  const SizedBox(height: 4),
                  _legendItem(AppColors.statusPenuh, 'Penuh'),
                  const SizedBox(height: 4),
                  _legendItem(AppColors.statusUnknown, 'Unknown'),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tombol lokasiku
          FloatingActionButton.small(
            heroTag: 'myLocation',
            onPressed: _getCurrentLocation,
            backgroundColor: Colors.white,
            child: const Icon(Icons.my_location, color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          // Tombol tambah parkiran
          FloatingActionButton.extended(
            heroTag: 'addParking',
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddParkingScreen()),
              );
              // Refresh setelah menambahkan
              if (mounted) {
                context.read<ParkingRepository>().fetchParkings();
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Tambah Parkiran'),
          ),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}
