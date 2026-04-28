import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/location_utils.dart';
import '../../data/models/parking_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/parking_repository.dart';
import '../../data/repositories/favorite_repository.dart';
import '../widgets/parking_card.dart';
import 'parking_detail_screen.dart';

/// Halaman daftar parkiran dengan filter status dan pencarian
class ParkingListScreen extends StatefulWidget {
  const ParkingListScreen({super.key});

  @override
  State<ParkingListScreen> createState() => _ParkingListScreenState();
}

class _ParkingListScreenState extends State<ParkingListScreen> {
  double? _userLat;
  double? _userLng;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Memuat lokasi pengguna untuk perhitungan jarak
  Future<void> _loadLocation() async {
    try {
      final position = await LocationUtils.getCurrentPosition();
      if (mounted) {
        setState(() {
          _userLat = position.latitude;
          _userLng = position.longitude;
        });
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  /// Filter parkiran berdasarkan search query
  List<ParkingModel> _filterBySearch(List<ParkingModel> parkings) {
    if (_searchQuery.isEmpty) return parkings;
    final query = _searchQuery.toLowerCase();
    return parkings.where((p) {
      return p.name.toLowerCase().contains(query) ||
          p.address.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final parkingRepo = context.watch<ParkingRepository>();
    final favoriteRepo = context.watch<FavoriteRepository>();
    final authRepo = context.watch<AuthRepository>();
    final parkings = _filterBySearch(parkingRepo.filteredParkings);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Parkiran'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Cari parkiran...',
                hintStyle: GoogleFonts.poppins(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          // Filter chips
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'Semua',
                    isSelected: parkingRepo.filterStatus == 'semua',
                    onTap: () => parkingRepo.setFilter('semua'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Tersedia',
                    isSelected: parkingRepo.filterStatus == 'kosong',
                    onTap: () => parkingRepo.setFilter('kosong'),
                    color: AppColors.statusKosong,
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Penuh',
                    isSelected: parkingRepo.filterStatus == 'penuh',
                    onTap: () => parkingRepo.setFilter('penuh'),
                    color: AppColors.statusPenuh,
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Unknown',
                    isSelected: parkingRepo.filterStatus == 'unknown',
                    onTap: () => parkingRepo.setFilter('unknown'),
                    color: AppColors.statusUnknown,
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          // Result count
          if (_searchQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    '${parkings.length} hasil ditemukan',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          // List
          Expanded(
            child: parkingRepo.isLoading
                ? _buildSkeletonLoader()
                : parkings.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _searchQuery.isNotEmpty
                                  ? Icons.search_off
                                  : Icons.local_parking,
                              size: 64,
                              color: AppColors.textSecondary.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? 'Tidak ditemukan "$_searchQuery"'
                                  : 'Belum ada parkiran',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => parkingRepo.fetchParkings(),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: parkings.length,
                          itemBuilder: (context, index) {
                            final parking = parkings[index];
                            String? distanceStr;
                            if (_userLat != null && _userLng != null) {
                              final dist = LocationUtils.calculateDistance(
                                _userLat!,
                                _userLng!,
                                parking.lat,
                                parking.lng,
                              );
                              distanceStr =
                                  LocationUtils.formatDistance(dist);
                            }

                            return ParkingCard(
                              parking: parking,
                              distance: distanceStr,
                              isFavorite:
                                  favoriteRepo.isFavorite(parking.id),
                              onFavoriteToggle: () {
                                if (authRepo.user != null) {
                                  favoriteRepo.toggleFavorite(
                                    authRepo.user!.uid,
                                    parking.id,
                                  );
                                }
                              },
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ParkingDetailScreen(
                                      parking: parking,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  /// Skeleton loader saat data sedang dimuat
  Widget _buildSkeletonLoader() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 150,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 80,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Widget filter chip custom
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? chipColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? chipColor : AppColors.divider,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
