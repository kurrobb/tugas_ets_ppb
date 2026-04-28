import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import '../../core/app_colors.dart';
import '../../data/models/parking_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/parking_repository.dart';
import '../../services/storage_service.dart';
import '../../services/notification_service.dart';
import 'map_picker_screen.dart';

/// Halaman tambah parkiran baru
class AddParkingScreen extends StatefulWidget {
  const AddParkingScreen({super.key});

  @override
  State<AddParkingScreen> createState() => _AddParkingScreenState();
}

class _AddParkingScreenState extends State<AddParkingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _capacityController = TextEditingController();
  String _type = 'both';
  File? _imageFile;
  double? _lat;
  double? _lng;
  bool _isSubmitting = false;

  final ImagePicker _picker = ImagePicker();
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    // Lokasi di-set via map picker, bukan auto GPS
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  /// Buka map picker untuk memilih lokasi parkiran
  Future<void> _openMapPicker() async {
    final result = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (_) => MapPickerScreen(
          initialLat: _lat,
          initialLng: _lng,
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _lat = result.latitude;
        _lng = result.longitude;
      });
    }
  }

  /// Ambil foto dari kamera atau galeri
  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        setState(() => _imageFile = File(pickedFile.path));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil foto: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  /// Menampilkan dialog pilih sumber gambar
  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: const Text('Kamera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primary),
              title: const Text('Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Submit form dan simpan ke Firestore
  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_lat == null || _lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lokasi belum tersedia. Tunggu GPS...'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final authRepo = context.read<AuthRepository>();
      String photoUrl = '';

      // Upload foto jika ada
      if (_imageFile != null) {
        try {
          // Cek apakah Storage aktif
          final storageReady = await _storageService.isStorageAvailable();
          if (storageReady) {
            final fileName =
                'parking_${DateTime.now().millisecondsSinceEpoch}.jpg';
            photoUrl = await _storageService.uploadParkingPhoto(
              _imageFile!,
              fileName,
            );
          } else {
            debugPrint('Firebase Storage not activated, skipping photo upload');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Firebase Storage belum aktif. Parkiran disimpan tanpa foto.'),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          }
        } catch (uploadError) {
          debugPrint('Warning: Photo upload failed: $uploadError');
          // Lanjutkan tanpa foto
        }
      }

      // Buat model parkiran
      final parking = ParkingModel(
        id: '',
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        lat: _lat!,
        lng: _lng!,
        type: _type,
        capacity: int.parse(_capacityController.text.trim()),
        status: 'unknown',
        photoUrl: photoUrl,
        addedBy: authRepo.user!.uid,
        updatedAt: Timestamp.now(),
      );

      // Simpan ke Firestore
      await context.read<ParkingRepository>().addParking(parking);

      // Kirim notifikasi
      await NotificationService().showParkingAddedNotification();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Parkiran berhasil ditambahkan!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menambahkan: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }

    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Parkiran'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Foto
              Text(
                'Foto Parkiran',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _showImageSourceDialog,
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.divider,
                      width: 1.5,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: _imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            _imageFile!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo,
                                size: 48,
                                color: AppColors.textSecondary.withValues(alpha: 0.5)),
                            const SizedBox(height: 8),
                            Text(
                              'Tap untuk mengambil foto',
                              style: GoogleFonts.poppins(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),
              // Nama parkiran
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nama Parkiran',
                  prefixIcon: Icon(Icons.local_parking),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama parkiran tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Alamat
              TextFormField(
                controller: _addressController,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Alamat',
                  prefixIcon: Icon(Icons.location_on),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Alamat tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Tipe kendaraan
              Text(
                'Tipe Kendaraan',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _typeChip('motor', 'Motor', Icons.two_wheeler),
                  const SizedBox(width: 8),
                  _typeChip('mobil', 'Mobil', Icons.directions_car),
                  const SizedBox(width: 8),
                  _typeChip('both', 'Keduanya', Icons.local_parking),
                ],
              ),
              const SizedBox(height: 16),
              // Kapasitas
              TextFormField(
                controller: _capacityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Kapasitas',
                  prefixIcon: Icon(Icons.event_seat),
                  hintText: 'Contoh: 50',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Kapasitas tidak boleh kosong';
                  }
                  if (int.tryParse(value.trim()) == null) {
                    return 'Masukkan angka yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Lokasi — pilih di peta
              Text(
                'Lokasi Parkiran',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _openMapPicker,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _lat != null
                          ? AppColors.primary.withValues(alpha: 0.3)
                          : AppColors.divider,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _lat != null ? Icons.location_on : Icons.add_location_alt,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _lat != null
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Lokasi dipilih',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    'Lat: ${_lat!.toStringAsFixed(6)}, Lng: ${_lng!.toStringAsFixed(6)}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                'Tap untuk pilih lokasi di peta',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                      ),
                      const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Tombol submit
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _handleSubmit,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                      _isSubmitting ? 'Menyimpan...' : 'Simpan Parkiran'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _typeChip(String value, String label, IconData icon) {
    final isSelected = _type == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _type = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.divider,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  color: isSelected ? Colors.white : AppColors.primary,
                  size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
