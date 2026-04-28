import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/app_colors.dart';
import '../../data/models/parking_model.dart';
import '../../data/repositories/parking_repository.dart';
import '../../services/storage_service.dart';

/// Halaman edit parkiran (hanya oleh user yang menambahkan)
class EditParkingScreen extends StatefulWidget {
  final ParkingModel parking;

  const EditParkingScreen({super.key, required this.parking});

  @override
  State<EditParkingScreen> createState() => _EditParkingScreenState();
}

class _EditParkingScreenState extends State<EditParkingScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _capacityController;
  late String _type;
  File? _newImageFile;
  bool _isSubmitting = false;

  final ImagePicker _picker = ImagePicker();
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.parking.name);
    _addressController = TextEditingController(text: widget.parking.address);
    _capacityController =
        TextEditingController(text: widget.parking.capacity.toString());
    _type = widget.parking.type;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  /// Ambil foto baru
  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        setState(() => _newImageFile = File(pickedFile.path));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil foto: $e')),
      );
    }
  }

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
              leading:
                  const Icon(Icons.photo_library, color: AppColors.primary),
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

  /// Submit update
  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      String photoUrl = widget.parking.photoUrl;

      // Upload foto baru jika ada
      if (_newImageFile != null) {
        final fileName =
            'parking_${DateTime.now().millisecondsSinceEpoch}.jpg';
        photoUrl = await _storageService.uploadParkingPhoto(
          _newImageFile!,
          fileName,
        );
      }

      final updatedParking = widget.parking.copyWith(
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        type: _type,
        capacity: int.parse(_capacityController.text.trim()),
        photoUrl: photoUrl,
        updatedAt: Timestamp.now(),
      );

      await context.read<ParkingRepository>().updateParking(updatedParking);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Parkiran berhasil diperbarui!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui: $e'),
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
        title: const Text('Edit Parkiran'),
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
                    border: Border.all(color: AppColors.divider, width: 1.5),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _newImageFile != null
                        ? Image.file(
                            _newImageFile!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          )
                        : widget.parking.photoUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: widget.parking.photoUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo,
                                      size: 48,
                                      color: AppColors.textSecondary
                                          .withValues(alpha: 0.5)),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tap untuk mengubah foto',
                                    style: GoogleFonts.poppins(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Nama
              TextFormField(
                controller: _nameController,
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
              // Tipe
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
              const SizedBox(height: 32),
              // Tombol simpan
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
                      _isSubmitting ? 'Menyimpan...' : 'Perbarui Parkiran'),
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
