// auth_controller.dart
// Controller GetX untuk mengelola semua logika autentikasi.
// Menggunakan GetX: state management, navigasi, dan snackbar.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/widgets.dart';
import '../models/user_model.dart';
import '../../../services/firebase_auth_service.dart';
import '../../../app/routes.dart';
import '../../../core/constants/app_strings.dart';

class AuthController extends GetxController {
  // Inject service melalui GetX dependency injection
  final FirebaseAuthService _authService = Get.find<FirebaseAuthService>();

  // ========================
  // STATE (OBSERVABLE)
  // ========================
  // Variabel Rx akan otomatis memperbarui UI saat nilainya berubah

  /// Data user yang sedang login (null jika belum login)
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  /// Status loading (true saat ada proses async berlangsung)
  final RxBool isLoading = false.obs;

  // ========================
  // FORM CONTROLLERS
  // Dipakai di login & register screen
  // ========================

  // Login
  final TextEditingController loginEmailController = TextEditingController();
  final TextEditingController loginPasswordController = TextEditingController();
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  // Register siswa
  final TextEditingController studentNameController = TextEditingController();
  final TextEditingController studentEmailController = TextEditingController();
  final TextEditingController studentPasswordController = TextEditingController();
  final TextEditingController studentConfirmPasswordController = TextEditingController();
  final GlobalKey<FormState> studentRegisterFormKey = GlobalKey<FormState>();

  // Register guru
  final TextEditingController teacherNameController = TextEditingController();
  final TextEditingController teacherNIDNController = TextEditingController();
  final TextEditingController teacherInstitutionController = TextEditingController();
  final TextEditingController teacherEmailController = TextEditingController();
  final TextEditingController teacherPasswordController = TextEditingController();
  final TextEditingController teacherConfirmPasswordController = TextEditingController();
  final GlobalKey<FormState> teacherRegisterFormKey = GlobalKey<FormState>();

  // ========================
  // LIFECYCLE
  // ========================

@override
void onInit() {
  super.onInit();
}
  @override
  void onClose() {
    // Bersihkan semua controller saat widget dihapus dari memory
    loginEmailController.dispose();
    loginPasswordController.dispose();
    studentNameController.dispose();
    studentEmailController.dispose();
    studentPasswordController.dispose();
    studentConfirmPasswordController.dispose();
    teacherNameController.dispose();
    teacherNIDNController.dispose();
    teacherInstitutionController.dispose();
    teacherEmailController.dispose();
    teacherPasswordController.dispose();
    teacherConfirmPasswordController.dispose();
    super.onClose();
  }

  // ========================
  // CEK USER LOGIN
  // ========================

  /// Cek status login dari Firebase dan arahkan ke halaman yang sesuai.
  Future<void> checkCurrentUser() async {
    final firebaseUser = _authService.currentUser;

    if (firebaseUser != null) {
      // Ada sesi login, ambil data dari Firestore
      final userData = await _authService.getUserData(firebaseUser.uid);

      if (userData != null) {
        currentUser.value = userData;
        // Arahkan ke dashboard sesuai role
        _navigateByRole(userData);
      } else {
        // Data tidak ditemukan, arahkan ke login
        Get.offAllNamed(AppRoutes.login);
      }
    } else {
      // Belum login
      Get.offAllNamed(AppRoutes.login);
    }
  }

  // ========================
  // LOGIN
  // ========================

  /// Proses login dengan email dan password.
  Future<void> login() async {
    // Validasi form dulu
    if (!loginFormKey.currentState!.validate()) return;

    isLoading.value = true;

    try {
      final result = await _authService.login(
        email: loginEmailController.text,
        password: loginPasswordController.text,
      );

      if (result.error != null) {
        // Tampilkan pesan error menggunakan GetX snackbar
        _showErrorSnackbar(result.error!);
        return;
      }

      // Simpan data user
      currentUser.value = result.user;

      // Arahkan ke dashboard sesuai role
      _navigateByRole(result.user!);

    } finally {
      // Pastikan loading dimatikan meskipun ada error
      isLoading.value = false;
    }
  }

  // ========================
  // LOGIN DENGAN GOOGLE
  // ========================

  /// Proses login menggunakan Google Account.
  Future<void> loginWithGoogle() async {
    isLoading.value = true;

    try {
      final result = await _authService.signInWithGoogle();

      if (result.error != null) {
        _showErrorSnackbar(result.error!);
        return;
      }

      // Simpan data user
      currentUser.value = result.user;

      // Arahkan ke dashboard sesuai role
      _navigateByRole(result.user!);

    } finally {
      isLoading.value = false;
    }
  }

  // ========================
  // REGISTER SISWA
  // ========================

  /// Proses pendaftaran akun siswa baru.
  Future<void> registerStudent() async {
    if (!studentRegisterFormKey.currentState!.validate()) return;

    isLoading.value = true;

    try {
      final error = await _authService.registerStudent(
        fullName: studentNameController.text,
        email: studentEmailController.text,
        password: studentPasswordController.text,
      );

      if (error != null) {
        _showErrorSnackbar(error);
        return;
      }

      // Berhasil — arahkan ke halaman verifikasi email (OTP simulasi)
      _showSuccessSnackbar('Akun berhasil dibuat! Silakan verifikasi email Anda.');
      Get.offAllNamed(AppRoutes.otp, arguments: {
        'email': studentEmailController.text,
        'role': 'student',
      });

    } finally {
      isLoading.value = false;
    }
  }

  // ========================
  // REGISTER GURU
  // ========================

  /// Proses pendaftaran akun guru baru.
  Future<void> registerTeacher() async {
    if (!teacherRegisterFormKey.currentState!.validate()) return;

    isLoading.value = true;

    try {
      final error = await _authService.registerTeacher(
        fullName: teacherNameController.text,
        nidn: teacherNIDNController.text,
        institution: teacherInstitutionController.text,
        email: teacherEmailController.text,
        password: teacherPasswordController.text,
      );

      if (error != null) {
        _showErrorSnackbar(error);
        return;
      }

      _showSuccessSnackbar('Akun berhasil dibuat! Silakan verifikasi email Anda.');
      Get.offAllNamed(AppRoutes.otp, arguments: {
        'email': teacherEmailController.text,
        'role': 'teacher',
      });

    } finally {
      isLoading.value = false;
    }
  }

  // ========================
  // LUPA PASSWORD
  // ========================

  final TextEditingController forgotEmailController = TextEditingController();

  /// Kirim email reset password.
  Future<bool> sendPasswordResetEmail() async {
    if (forgotEmailController.text.trim().isEmpty) {
      _showErrorSnackbar('Masukkan email Anda terlebih dahulu');
      return false;
    }

    isLoading.value = true;

    try {
      final error = await _authService.sendPasswordResetEmail(
        forgotEmailController.text,
      );

      if (error != null) {
        _showErrorSnackbar(error);
        return false;
      }

      _showSuccessSnackbar('Link reset password telah dikirim ke email Anda.');
      return true;

    } finally {
      isLoading.value = false;
    }
  }

  // ========================
  // LOGOUT
  // ========================

  /// Proses logout dari aplikasi.
  Future<void> logout() async {
    isLoading.value = true;

    try {
      await _authService.logout();
      currentUser.value = null;

      // Arahkan ke halaman splash agar muncul logo lagi, lalu otomatis ke login
      Get.offAllNamed(AppRoutes.splash);

    } finally {
      isLoading.value = false;
    }
  }

  // ========================
  // NAVIGASI BERDASARKAN ROLE
  // ========================

  /// Arahkan pengguna ke dashboard sesuai role mereka.
  void _navigateByRole(UserModel user) {
    if (user.isStudent) {
      Get.offAllNamed(AppRoutes.studentDashboard);
    } else if (user.isTeacher) {
      Get.offAllNamed(AppRoutes.teacherDashboard);
    }
  }

  // ========================
  // HELPER SNACKBAR
  // ========================

  /// Tampilkan snackbar pesan error (merah).
  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Oops!',
      message,
      backgroundColor: const Color(0xFFEF4444),
      colorText: const Color(0xFFFFFFFF),
      icon: const Icon(Icons.error_outline, color: Colors.white),
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
    );
  }

  /// Tampilkan snackbar pesan sukses (hijau).
  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Berhasil!',
      message,
      backgroundColor: const Color(0xFF10B981),
      colorText: const Color(0xFFFFFFFF),
      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
    );
  }
}
