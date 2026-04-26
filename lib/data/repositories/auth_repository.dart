import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';

/// Repository untuk autentikasi pengguna
class AuthRepository extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  UserModel? _userModel;
  bool _isLoading = false;
  bool _isPerformingAuthAction = false; // Guard untuk cegah race condition

  User? get user => _user;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;

  AuthRepository() {
    _user = _auth.currentUser;

    // Listen ke perubahan auth state
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      if (user != null && !_isPerformingAuthAction) {
        // Hanya auto-load kalau bukan sedang signUp/signIn
        _loadUserData();
      } else if (user == null) {
        _userModel = null;
      }
      notifyListeners();
    });

    if (_user != null) {
      _loadUserData();
    }
  }

  /// Memuat data user dari Firestore
  Future<void> _loadUserData() async {
    if (_user == null) return;
    try {
      final doc = await _firestore.collection('users').doc(_user!.uid).get();
      if (doc.exists) {
        _userModel = UserModel.fromFirestore(doc);
      } else {
        // Buat fallback dari data Auth
        _userModel = UserModel(
          id: _user!.uid,
          name: _user!.displayName ?? _user!.email?.split('@').first ?? 'User',
          email: _user!.email ?? '',
        );
        // Coba simpan ke Firestore (silent)
        try {
          await _firestore
              .collection('users')
              .doc(_user!.uid)
              .set(_userModel!.toMap());
        } catch (e) {
          debugPrint('Warning: Could not save user doc: $e');
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user data: $e');
      _userModel = UserModel(
        id: _user!.uid,
        name: _user!.displayName ?? _user!.email?.split('@').first ?? 'User',
        email: _user!.email ?? '',
      );
      notifyListeners();
    }
  }

  /// Login dengan email dan password
  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    _isPerformingAuthAction = true;
    notifyListeners();
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      _user = credential.user;
      await _loadUserData();
    } finally {
      _isLoading = false;
      _isPerformingAuthAction = false;
      notifyListeners();
    }
  }

  /// Register user baru
  Future<void> signUp(String name, String email, String password) async {
    _isLoading = true;
    _isPerformingAuthAction = true;
    notifyListeners();
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      _user = credential.user;

      // Simpan data user ke Firestore
      final userModel = UserModel(
        id: _user!.uid,
        name: name.trim(),
        email: email.trim(),
      );

      try {
        await _firestore
            .collection('users')
            .doc(_user!.uid)
            .set(userModel.toMap());
      } catch (firestoreError) {
        debugPrint('Warning: Firestore write failed: $firestoreError');
      }

      _userModel = userModel;
    } finally {
      _isLoading = false;
      _isPerformingAuthAction = false;
      notifyListeners();
    }
  }

  /// Logout
  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    _userModel = null;
    notifyListeners();
  }

  /// Mendapatkan pesan error yang user-friendly
  static String getErrorMessage(dynamic error) {
    String code = '';
    String message = '';

    if (error is FirebaseAuthException) {
      code = error.code;
      message = error.message ?? '';
    } else if (error is FirebaseException) {
      code = error.code;
      message = error.message ?? '';
    } else {
      message = error.toString();
    }

    debugPrint('Auth error - code: $code, message: $message');

    switch (code) {
      case 'user-not-found':
        return 'Email tidak terdaftar.';
      case 'wrong-password':
        return 'Password salah.';
      case 'invalid-credential':
        return 'Email atau password salah.';
      case 'email-already-in-use':
        return 'Email sudah digunakan.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'weak-password':
        return 'Password terlalu lemah (min. 6 karakter).';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi nanti.';
      case 'network-request-failed':
        return 'Tidak ada koneksi internet.';
      default:
        if (code.isNotEmpty) {
          return 'Error: $code';
        }
        return 'Terjadi kesalahan. Silakan coba lagi.';
    }
  }
}
