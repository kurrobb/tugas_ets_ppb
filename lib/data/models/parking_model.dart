import 'package:cloud_firestore/cloud_firestore.dart';

class ParkingModel {
  final String id;
  final String name;
  final String address;
  final double lat;
  final double lng;
  final String type;
  final int capacity;
  final String status;
  final String photoUrl;
  final String addedBy;
  final String addedByName;
  final Timestamp updatedAt;

  ParkingModel({
    required this.id,
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    required this.type,
    required this.capacity,
    required this.status,
    required this.photoUrl,
    required this.addedBy,
    this.addedByName = '',
    required this.updatedAt,
  });

  factory ParkingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ParkingModel(
      id: doc.id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      lat: (data['lat'] ?? 0).toDouble(),
      lng: (data['lng'] ?? 0).toDouble(),
      type: data['type'] ?? 'both',
      capacity: data['capacity'] ?? 0,
      status: data['status'] ?? 'unknown',
      photoUrl: data['photoUrl'] ?? '',
      addedBy: data['addedBy'] ?? '',
      addedByName: data['addedByName'] ?? '',
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'lat': lat,
      'lng': lng,
      'type': type,
      'capacity': capacity,
      'status': status,
      'photoUrl': photoUrl,
      'addedBy': addedBy,
      'addedByName': addedByName,
      'updatedAt': updatedAt,
    };
  }

  ParkingModel copyWith({
    String? id,
    String? name,
    String? address,
    double? lat,
    double? lng,
    String? type,
    int? capacity,
    String? status,
    String? photoUrl,
    String? addedBy,
    String? addedByName,
    Timestamp? updatedAt,
  }) {
    return ParkingModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      type: type ?? this.type,
      capacity: capacity ?? this.capacity,
      status: status ?? this.status,
      photoUrl: photoUrl ?? this.photoUrl,
      addedBy: addedBy ?? this.addedBy,
      addedByName: addedByName ?? this.addedByName,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get typeLabel {
    switch (type) {
      case 'motor':
        return 'Motor';
      case 'mobil':
        return 'Mobil';
      case 'both':
        return 'Motor & Mobil';
      default:
        return type;
    }
  }

  String get statusLabel {
    switch (status) {
      case 'kosong':
        return 'Tersedia';
      case 'penuh':
        return 'Penuh';
      default:
        return 'Tidak Diketahui';
    }
  }
}
