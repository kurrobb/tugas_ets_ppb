import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/app_colors.dart';
import '../../core/location_utils.dart';
import '../../data/models/parking_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/parking_repository.dart';
import '../../data/repositories/favorite_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/status_badge.dart';
import 'edit_parking_screen.dart';

/// Halaman detail parkiran
class ParkingDetailScreen extends StatefulWidget {
  final ParkingModel parking;

  const ParkingDetailScreen({super.key, required this.parking});

  @override
  State<ParkingDetailScreen> createState() => _ParkingDetailScreenState();
}

class _ParkingDetailScreenState extends State<ParkingDetailScreen> {
  late ParkingModel _parking;
  double? _userLat;
  double? _userLng;
  bool _isUpdatingStatus = false;
  String _adderName = '...';

  @override
  void initState() {
    super.initState();
    _parking = widget.parking;
    _loadLocation();
    _loadAdderName();
  }

  /// Memuat nama user yang menambahkan parkiran ini
  Future<void> _loadAdderName() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_parking.addedBy)
          .get();
      if (doc.exists && mounted) {
        final data = doc.data();
        final name = data?['name'] as String? ?? '';
        final email = data?['email'] as String? ?? '';
        setState(() {
          _adderName = name.isNotEmpty
              ? name
              : email.isNotEmpty
                  ? email.split('@').first
                  : 'Pengguna';
        });
      } else if (mounted) {
        setState(() => _adderName = 'Pengguna');
      }
    } catch (e) {
      debugPrint('Error loading adder name: $e');
      if (mounted) setState(() => _adderName = 'Pengguna');
    }
  }

  /// Memuat lokasi pengguna untuk menampilkan jarak
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

  /// Quick update status parkiran
  Future<void> _updateStatus(String status) async {
    setState(() => _isUpdatingStatus = true);
    try {
      await context
          .read<ParkingRepository>()
          .updateParkingStatus(_parking.id, status);
      setState(() {
        _parking = _parking.copyWith(status: status);
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == 'kosong'
                ? 'Ditandai sebagai Tersedia'
                : 'Ditandai sebagai Penuh',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal update status: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
    setState(() => _isUpdatingStatus = false);
  }

  /// Konfirmasi hapus parkiran
  Future<void> _deleteParking() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Parkiran'),
        content: Text('Yakin ingin menghapus "${_parking.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await context.read<ParkingRepository>().deleteParking(_parking.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Parkiran berhasil dihapus'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authRepo = context.watch<AuthRepository>();
    final favoriteRepo = context.watch<FavoriteRepository>();
    final isOwner = authRepo.user?.uid == _parking.addedBy;
    final isFav = favoriteRepo.isFavorite(_parking.id);

    String? distanceStr;
    if (_userLat != null && _userLng != null) {
      final dist = LocationUtils.calculateDistance(
        _userLat!, _userLng!, _parking.lat, _parking.lng,
      );
      distanceStr = LocationUtils.formatDistance(dist);
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar dengan foto
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            actions: [
              // Tombol bookmark
              IconButton(
                icon: Icon(
                  isFav ? Icons.bookmark : Icons.bookmark_border,
                  color: isFav ? AppColors.accent : Colors.white,
                ),
                onPressed: () {
                  if (authRepo.user != null) {
                    favoriteRepo.toggleFavorite(
                      authRepo.user!.uid,
                      _parking.id,
                    );
                  }
                },
              ),
              // Menu edit/delete (hanya owner)
              if (isOwner)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              EditParkingScreen(parking: _parking),
                        ),
                      ).then((updated) {
                        if (updated == true) {
                          // Refresh data
                          context.read<ParkingRepository>().fetchParkings();
                          Navigator.of(context).pop();
                        }
                      });
                    } else if (value == 'delete') {
                      _deleteParking();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: AppColors.error),
                          SizedBox(width: 8),
                          Text('Hapus',
                              style: TextStyle(color: AppColors.error)),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _parking.photoUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: _parking.photoUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.primary,
                        child: const Icon(Icons.local_parking,
                            size: 80, color: Colors.white),
                      ),
                    )
                  : Container(
                      color: AppColors.primary,
                      child: const Icon(Icons.local_parking,
                          size: 80, color: Colors.white),
                    ),
            ),
          ),
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama dan status
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _parking.name,
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      StatusBadge(status: _parking.status, fontSize: 13),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Alamat
                  _infoRow(Icons.location_on, _parking.address),
                  const SizedBox(height: 8),
                  // Jarak
                  if (distanceStr != null)
                    _infoRow(Icons.directions_walk, 'Jarak: $distanceStr'),
                  const SizedBox(height: 8),
                  // Tipe kendaraan
                  _infoRow(Icons.two_wheeler, 'Tipe: ${_parking.typeLabel}'),
                  const SizedBox(height: 8),
                  // Kapasitas
                  _infoRow(
                      Icons.event_seat, 'Kapasitas: ${_parking.capacity}'),
                  const SizedBox(height: 8),
                  // Koordinat
                  _infoRow(Icons.gps_fixed,
                      'Lat: ${_parking.lat.toStringAsFixed(6)}, Lng: ${_parking.lng.toStringAsFixed(6)}'),
                  const SizedBox(height: 8),
                  // Ditambahkan oleh
                  _infoRow(Icons.person, 'Ditambahkan oleh: $_adderName'),

                  const SizedBox(height: 24),
                  // Quick update status buttons
                  Text(
                    'Update Status',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isUpdatingStatus
                              ? null
                              : () => _updateStatus('kosong'),
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Tandai Kosong'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.statusKosong,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isUpdatingStatus
                              ? null
                              : () => _updateStatus('penuh'),
                          icon: const Icon(Icons.cancel),
                          label: const Text('Tandai Penuh'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.statusPenuh,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
