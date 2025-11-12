import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  User? get user => _user;
  bool get isLoggedIn => _user != null;

  AuthService() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  // === SIGN IN ===
  Future<String?> signInWithEmailAndPassword(
      String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      return "Email & Password tidak boleh kosong";
    }

    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      _user = result.user;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'Email tidak terdaftar';
        case 'wrong-password':
          return 'Password salah';
        case 'invalid-email':
          return 'Format email tidak valid';
        case 'user-disabled':
          return 'Akun telah dinonaktifkan';
        case 'too-many-requests':
          return 'Terlalu banyak percobaan. Coba lagi nanti';
        default:
          return 'Login gagal: ${e.message}';
      }
    } catch (e) {
      return "Error: $e";
    }
  }

  // === REGISTER ===
  Future<String?> registerWithEmailAndPassword(
      String username, String email, String password) async {
    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      return "Semua field wajib diisi";
    }

    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      await result.user!.updateDisplayName(username);
      await result.user!.reload();

      _user = _auth.currentUser;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'Email sudah terdaftar. Silakan login atau gunakan email lain';
        case 'invalid-email':
          return 'Format email tidak valid';
        case 'operation-not-allowed':
          return 'Registrasi tidak diizinkan';
        case 'weak-password':
          return 'Password terlalu lemah. Gunakan minimal 6 karakter';
        default:
          return 'Registrasi gagal: ${e.message}';
      }
    } catch (e) {
      return "Error: $e";
    }
  }

  // === LOGOUT ===
  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }
}
