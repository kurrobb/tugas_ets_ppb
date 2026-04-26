import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/location_utils.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/parking_repository.dart';
import '../../data/repositories/favorite_repository.dart';
import '../widgets/parking_card.dart';
import 'parking_detail_screen.dart';

/// Halaman favorit - menampilkan parkiran yang di-bookmark user
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  double? _userLat;
  double? _userLng;

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

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

  @override
  Widget build(BuildContext context) {
    final favoriteRepo = context.watch<FavoriteRepository>();
    final parkingRepo = context.watch<ParkingRepository>();
    final authRepo = context.watch<AuthRepository>();

    // Filter parkiran yang ada di favorites
    final favoriteParkings = parkingRepo.parkings
        .where((p) => favoriteRepo.favoriteIds.contains(p.id))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorit'),
        automaticallyImplyLeading: false,
      ),
      body: favoriteRepo.isLoading
          ? const Center(child: CircularProgressIndicator())
          : favoriteParkings.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bookmark_border,
                          size: 80,
                          color: AppColors.textSecondary.withValues(alpha: 0.4)),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada favorit',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Bookmark parkiran di halaman detail',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: favoriteParkings.length,
                  itemBuilder: (context, index) {
                    final parking = favoriteParkings[index];
                    String? distanceStr;
                    if (_userLat != null && _userLng != null) {
                      final dist = LocationUtils.calculateDistance(
                        _userLat!, _userLng!, parking.lat, parking.lng,
                      );
                      distanceStr = LocationUtils.formatDistance(dist);
                    }

                    return ParkingCard(
                      parking: parking,
                      distance: distanceStr,
                      isFavorite: true,
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
                            builder: (_) =>
                                ParkingDetailScreen(parking: parking),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
