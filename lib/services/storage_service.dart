import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

/// Service untuk upload file ke Firebase Storage
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Cek apakah Firebase Storage aktif
  Future<bool> isStorageAvailable() async {
    try {
      // Coba list root — kalau bucket tidak ada, akan throw error
      await _storage.ref().listAll();
      return true;
    } catch (e) {
      debugPrint('Firebase Storage not available: $e');
      return false;
    }
  }

  /// Upload foto parkiran ke Firebase Storage dan return URL
  Future<String> uploadParkingPhoto(File imageFile, String fileName) async {
    try {
      final ref = _storage.ref().child('parkings/$fileName');
      final uploadTask = await ref.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading photo: $e');
      rethrow;
    }
  }

  /// Menghapus foto dari Firebase Storage berdasarkan URL
  Future<void> deletePhoto(String photoUrl) async {
    try {
      if (photoUrl.isEmpty) return;
      final ref = _storage.refFromURL(photoUrl);
      await ref.delete();
    } catch (e) {
      debugPrint('Error deleting photo: $e');
      // Non-critical, silakan dilanjutkan
    }
  }
}

