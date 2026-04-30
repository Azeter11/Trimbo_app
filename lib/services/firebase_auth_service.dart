// firebase_auth_service.dart
// Service untuk menangani semua operasi autentikasi menggunakan Firebase Auth.
// Termasuk: login, register, logout, reset password, verifikasi email.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../features/auth/models/user_model.dart';

class FirebaseAuthService {
  // Instansi Firebase Auth & Firestore (singleton)
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // ========================
  // GETTER
  // ========================

  /// Ambil user yang sedang login (null jika belum login)
  User? get currentUser => _auth.currentUser;

  /// Stream status login (berguna untuk auto-redirect)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ========================
  // REGISTER SISWA
  // ========================

  /// Daftarkan akun siswa baru ke Firebase.
  /// Mengembalikan pesan error atau null jika berhasil.
  Future<String?> registerStudent({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      // 1. Buat akun di Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // 2. Kirim email verifikasi
      await credential.user?.sendEmailVerification();

      // 3. Simpan data tambahan ke Firestore (koleksi 'users')
      final userModel = UserModel(
        uid: credential.user!.uid,
        fullName: fullName.trim(),
        email: email.trim(),
        role: 'student',
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(userModel.toMap());

      return null; // null = sukses

    } on FirebaseAuthException catch (e) {
      // Konversi kode error Firebase ke pesan yang ramah pengguna
      return _handleAuthError(e.code);
    } catch (e) {
      return 'Terjadi kesalahan. Silakan coba lagi.';
    }
  }

  // ========================
  // REGISTER GURU
  // ========================

  /// Daftarkan akun guru baru ke Firebase.
  Future<String?> registerTeacher({
    required String fullName,
    required String nuptk,
    required String institution,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      await credential.user?.sendEmailVerification();

      final userModel = UserModel(
        uid: credential.user!.uid,
        fullName: fullName.trim(),
        email: email.trim(),
        role: 'teacher',
        nuptk: nuptk.trim(),
        institution: institution.trim(),
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(userModel.toMap());

      return null;

    } on FirebaseAuthException catch (e) {
      return _handleAuthError(e.code);
    } catch (e) {
      return 'Terjadi kesalahan. Silakan coba lagi.';
    }
  }

  // ========================
  // LOGIN
  // ========================

  /// Login dengan email dan password.
  /// Mengembalikan UserModel jika berhasil, atau error string jika gagal.
  Future<({UserModel? user, String? error})> login({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Login ke Firebase Auth
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // 2. Ambil data user dari Firestore
      final doc = await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .get();

      if (!doc.exists) {
        return (user: null, error: 'Data akun tidak ditemukan');
      }

      final userModel = UserModel.fromMap(doc.data()!, credential.user!.uid);
      return (user: userModel, error: null);

    } on FirebaseAuthException catch (e) {
      return (user: null, error: _handleAuthError(e.code));
    } catch (e) {
      return (user: null, error: 'Terjadi kesalahan. Silakan coba lagi.');
    }
  }

  // ========================
  // LOGIN DENGAN GOOGLE
  // ========================

  /// Login menggunakan Google Account.
  /// Memastikan akun Google sudah terdaftar di Firestore.
  Future<({UserModel? user, String? error})> signInWithGoogle() async {
    try {
      // 1. Inisialisasi proses sign in di perangkat
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return (user: null, error: 'Proses login dibatalkan');
      }

      // 3. Ambil detail autentikasi Google
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 4. Buat kredensial Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 5. Sign in ke Firebase Auth
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        return (user: null, error: 'Gagal mendapatkan data user');
      }

      // 6. CEK DATABASE (Firestore)
      // Apakah UID ini sudah terdaftar di koleksi 'users'?
      final doc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (!doc.exists) {
        // JIKA TIDAK TERDAFTAR:
        // Logout paksa karena akun Google ini belum melewati registrasi aplikasi
        await _auth.signOut();
        await _googleSignIn.signOut();
        
        return (user: null, error: 'Akun Google Anda belum terdaftar di aplikasi ini. Silakan daftar terlebih dahulu menggunakan email Google Anda.');
      }

      // JIKA TERDAFTAR: Ambil data dan lanjutkan
      final userModel = UserModel.fromMap(doc.data()!, firebaseUser.uid);
      return (user: userModel, error: null);

    } on FirebaseAuthException catch (e) {
      return (user: null, error: _handleAuthError(e.code));
    } catch (e) {
      print('Google Login Error: $e');
      return (user: null, error: 'Terjadi kesalahan saat login Google.');
    }
  }

  // ========================
  // LOGOUT
  // ========================

  /// Logout dari Firebase Auth dan Google Sign In.
  Future<void> logout() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  // ========================
  // LUPA PASSWORD
  // ========================

  /// Kirim email reset password ke alamat yang diberikan.
  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null; // null = berhasil

    } on FirebaseAuthException catch (e) {
      return _handleAuthError(e.code);
    } catch (e) {
      return 'Terjadi kesalahan. Silakan coba lagi.';
    }
  }

  // ========================
  // AMBIL DATA USER
  // ========================

  /// Ambil data UserModel dari Firestore berdasarkan UID.
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      return UserModel.fromMap(doc.data()!, uid);
    } catch (e) {
      return null;
    }
  }

  // ========================
  // GANTI PASSWORD
  // ========================

  /// Ubah password pengguna yang sedang login.
  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 'Tidak ada sesi login';

      // Re-authenticate dulu (wajib untuk operasi sensitif)
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Ubah password
      await user.updatePassword(newPassword);
      return null;

    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        return 'Kata sandi lama tidak benar';
      }
      return _handleAuthError(e.code);
    } catch (e) {
      return 'Terjadi kesalahan. Silakan coba lagi.';
    }
  }

  // ========================
  // HANDLE ERROR FIREBASE
  // ========================

  /// Konversi kode error Firebase ke pesan bahasa Indonesia yang ramah.
  String _handleAuthError(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Format email tidak valid';
      case 'user-disabled':
        return 'Akun ini telah dinonaktifkan';
      case 'user-not-found':
        return 'Akun tidak ditemukan';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email atau kata sandi salah';
      case 'email-already-in-use':
        return 'Email sudah terdaftar';
      case 'weak-password':
        return 'Kata sandi terlalu lemah (minimal 8 karakter)';
      case 'network-request-failed':
        return 'Tidak ada koneksi internet';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi nanti.';
      default:
        return 'Terjadi kesalahan. Silakan coba lagi.';
    }
  }
}
