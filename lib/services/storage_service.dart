import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<bool> isStorageAvailable() async {
    try {
      await _storage.ref().listAll();
      return true;
    } catch (e) {
      debugPrint('Firebase Storage not available: $e');
      return false;
    }
  }

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

  Future<void> deletePhoto(String photoUrl) async {
    try {
      if (photoUrl.isEmpty) return;
      final ref = _storage.refFromURL(photoUrl);
      await ref.delete();
    } catch (e) {
      debugPrint('Error deleting photo: $e');
    }
  }
}
