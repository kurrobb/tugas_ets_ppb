import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/parking_model.dart';

/// Repository untuk CRUD data parkiran
class ParkingRepository extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<ParkingModel> _parkings = [];
  bool _isLoading = false;
  String _filterStatus = 'semua';

  List<ParkingModel> get parkings => _parkings;
  bool get isLoading => _isLoading;
  String get filterStatus => _filterStatus;

  /// Mendapatkan parkiran berdasarkan filter status
  List<ParkingModel> get filteredParkings {
    if (_filterStatus == 'semua') return _parkings;
    return _parkings.where((p) => p.status == _filterStatus).toList();
  }

  /// Set filter status
  void setFilter(String status) {
    _filterStatus = status;
    notifyListeners();
  }

  /// Mengambil semua data parkiran dari Firestore (realtime)
  Stream<List<ParkingModel>> getParkingsStream() {
    return _firestore
        .collection('parkings')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      _parkings = snapshot.docs
          .map((doc) => ParkingModel.fromFirestore(doc))
          .toList();
      notifyListeners();
      return _parkings;
    });
  }

  /// Mengambil semua data parkiran (one-time fetch)
  Future<void> fetchParkings() async {
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _firestore
          .collection('parkings')
          .orderBy('updatedAt', descending: true)
          .get();
      _parkings = snapshot.docs
          .map((doc) => ParkingModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error fetching parkings: $e');
      rethrow;
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Menambahkan parkiran baru ke Firestore
  Future<String> addParking(ParkingModel parking) async {
    try {
      final docRef = await _firestore
          .collection('parkings')
          .add(parking.toMap());
      await fetchParkings();
      return docRef.id;
    } catch (e) {
      debugPrint('Error adding parking: $e');
      rethrow;
    }
  }

  /// Mengupdate data parkiran di Firestore
  Future<void> updateParking(ParkingModel parking) async {
    try {
      await _firestore
          .collection('parkings')
          .doc(parking.id)
          .update(parking.toMap());
      await fetchParkings();
    } catch (e) {
      debugPrint('Error updating parking: $e');
      rethrow;
    }
  }

  /// Mengupdate status parkiran saja (quick update)
  Future<void> updateParkingStatus(String parkingId, String status) async {
    try {
      await _firestore.collection('parkings').doc(parkingId).update({
        'status': status,
        'updatedAt': Timestamp.now(),
      });
      await fetchParkings();
    } catch (e) {
      debugPrint('Error updating parking status: $e');
      rethrow;
    }
  }

  /// Menghapus parkiran dari Firestore
  Future<void> deleteParking(String parkingId) async {
    try {
      await _firestore.collection('parkings').doc(parkingId).delete();
      _parkings.removeWhere((p) => p.id == parkingId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting parking: $e');
      rethrow;
    }
  }

  /// Mendapatkan parkiran yang ditambahkan oleh user tertentu
  Future<List<ParkingModel>> getUserParkings(String userId) async {
    try {
      // Filter dari data lokal untuk menghindari kebutuhan composite index
      if (_parkings.isNotEmpty) {
        return _parkings.where((p) => p.addedBy == userId).toList();
      }
      // Fallback: query sederhana tanpa orderBy (tidak butuh index)
      final snapshot = await _firestore
          .collection('parkings')
          .where('addedBy', isEqualTo: userId)
          .get();
      return snapshot.docs
          .map((doc) => ParkingModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error fetching user parkings: $e');
      return []; // Return empty list instead of rethrow to prevent crash
    }
  }

  /// Mendapatkan parkiran berdasarkan ID
  Future<ParkingModel?> getParkingById(String parkingId) async {
    try {
      final doc = await _firestore
          .collection('parkings')
          .doc(parkingId)
          .get();
      if (doc.exists) {
        return ParkingModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching parking by id: $e');
      rethrow;
    }
  }
}
