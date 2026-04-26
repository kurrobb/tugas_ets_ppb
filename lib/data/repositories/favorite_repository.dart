import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Repository untuk mengelola favorit parkiran user
class FavoriteRepository extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<String> _favoriteIds = [];
  bool _isLoading = false;

  List<String> get favoriteIds => _favoriteIds;
  bool get isLoading => _isLoading;

  /// Memuat daftar favorit dari Firestore
  Future<void> loadFavorites(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final doc = await _firestore.collection('favorites').doc(userId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        _favoriteIds = List<String>.from(data['parkingIds'] ?? []);
      } else {
        _favoriteIds = [];
      }
    } catch (e) {
      debugPrint('Error loading favorites: $e');
      _favoriteIds = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Mengecek apakah parkiran sudah difavoritkan
  bool isFavorite(String parkingId) {
    return _favoriteIds.contains(parkingId);
  }

  /// Toggle favorit (tambah/hapus)
  Future<void> toggleFavorite(String userId, String parkingId) async {
    try {
      if (_favoriteIds.contains(parkingId)) {
        _favoriteIds.remove(parkingId);
      } else {
        _favoriteIds.add(parkingId);
      }
      notifyListeners();

      await _firestore.collection('favorites').doc(userId).set({
        'parkingIds': _favoriteIds,
      });
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      // Rollback on error
      if (_favoriteIds.contains(parkingId)) {
        _favoriteIds.remove(parkingId);
      } else {
        _favoriteIds.add(parkingId);
      }
      notifyListeners();
      rethrow;
    }
  }
}
