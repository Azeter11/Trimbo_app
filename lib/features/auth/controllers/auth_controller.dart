// auth_controller.dart
// Controller GetX untuk mengelola semua logika autentikasi.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';
import '../../../services/firebase_auth_service.dart';
import '../../../services/firebase_storage_service.dart';
import '../../../app/routes.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class AuthController extends GetxController {
  final FirebaseAuthService _authService = Get.find<FirebaseAuthService>();

  // ========================
  // UPDATE PROFILE PICTURE (FIREBASE STORAGE)
  // Menggunakan Firebase Storage untuk konsistensi
  // ========================
  Future<void> updateProfilePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75, // Kompres agar upload lebih cepat
      maxWidth: 512,
      maxHeight: 512,
    );

    if (pickedFile != null) {
      isLoading.value = true;

      try {
        File file = File(pickedFile.path);
        String uid = currentUser.value!.uid;

        // Generate nama file unik
        String fileName = 'profile_${uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';

        // Upload ke Firebase Storage menggunakan service
        String? photoUrl = await FirebaseStorageService.uploadImage(
          fileName: fileName,
          file: file,
          folder: 'profile_images',
        );

        if (photoUrl != null) {
          // Simpan URL ke Firestore
          await FirebaseFirestore.instance.collection('users').doc(uid).update({
            'photoUrl': photoUrl,
          });

          // Update state lokal agar UI langsung berubah
          currentUser.value = currentUser.value!.copyWith(photoUrl: photoUrl);

          _showSuccessSnackbar('Foto profil berhasil diperbarui!');
        } else {
          _showErrorSnackbar('Gagal mengupload foto profil. Coba lagi.');
        }

      } catch (e) {
        _showErrorSnackbar('Terjadi kesalahan: $e');
      } finally {
        isLoading.value = false;
      }
    }
  }

  // ========================
  // UPDATE PROFILE DATA (NAMA, DLL)
  // ========================
  Future<void> updateProfileData({required String fullName, String? nuptk, String? institution}) async {
    if (currentUser.value == null) return;
    isLoading.value = true;
    try {
      String uid = currentUser.value!.uid;
      Map<String, dynamic> updateData = {'fullName': fullName};
      if (nuptk != null) updateData['nuptk'] = nuptk;
      if (institution != null) updateData['institution'] = institution;

      await FirebaseFirestore.instance.collection('users').doc(uid).update(updateData);
      
      currentUser.value = currentUser.value!.copyWith(
        fullName: fullName,
        nuptk: nuptk,
        institution: institution,
      );

      _showSuccessSnackbar('Profil berhasil diperbarui!');
    } catch (e) {
      _showErrorSnackbar('Gagal memperbarui profil: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ========================
  // STATE (OBSERVABLE)
  // ========================
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;

  // ========================
  // FORM CONTROLLERS
  // ========================
  final TextEditingController loginEmailController = TextEditingController();
  final TextEditingController loginPasswordController = TextEditingController();
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  final TextEditingController studentNameController = TextEditingController();
  final TextEditingController studentEmailController = TextEditingController();
  final TextEditingController studentPasswordController = TextEditingController();
  final TextEditingController studentConfirmPasswordController = TextEditingController();
  final GlobalKey<FormState> studentRegisterFormKey = GlobalKey<FormState>();

  final TextEditingController teacherNameController = TextEditingController();
  final TextEditingController teacherNUPTKController = TextEditingController();
  final TextEditingController teacherInstitutionController = TextEditingController();
  final TextEditingController teacherEmailController = TextEditingController();
  final TextEditingController teacherPasswordController = TextEditingController();
  final TextEditingController teacherConfirmPasswordController = TextEditingController();
  final GlobalKey<FormState> teacherRegisterFormKey = GlobalKey<FormState>();

  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmNewPasswordController = TextEditingController();
  final GlobalKey<FormState> changePasswordFormKey = GlobalKey<FormState>();

  // ========================
  // LIFECYCLE
  // ========================
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    loginEmailController.dispose();
    loginPasswordController.dispose();
    studentNameController.dispose();
    studentEmailController.dispose();
    studentPasswordController.dispose();
    studentConfirmPasswordController.dispose();
    teacherNameController.dispose();
    teacherNUPTKController.dispose();
    teacherInstitutionController.dispose();
    teacherEmailController.dispose();
    teacherPasswordController.dispose();
    teacherConfirmPasswordController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmNewPasswordController.dispose();
    super.onClose();
  }

  // ========================
  // CEK USER LOGIN
  // ========================
  Future<void> checkCurrentUser() async {
    try {
      final firebaseUser = _authService.currentUser;

      if (firebaseUser != null) {
        // Beri timeout agar tidak menggantung selamanya jika ada kendala koneksi/autentikasi (seperti SHA mismatch)
        await firebaseUser.reload().timeout(const Duration(seconds: 5));
        final refreshedUser = _authService.currentUser;

        if (refreshedUser == null || !refreshedUser.emailVerified) {
          Get.offAllNamed(AppRoutes.login);
          return;
        }

        final userData = await _authService
            .getUserData(refreshedUser.uid)
            .timeout(const Duration(seconds: 5));

        if (userData != null) {
          currentUser.value = userData;
          _navigateByRole(userData);
        } else {
          Get.offAllNamed(AppRoutes.login);
        }
      } else {
        Get.offAllNamed(AppRoutes.login);
      }
    } catch (e) {
      // Jika terjadi error/timeout koneksi, arahkan ke login agar pengguna tidak stuck di splash screen
      debugPrint("Error checkCurrentUser: $e");
      Get.offAllNamed(AppRoutes.login);
    }
  }

  // ========================
  // LOGIN
  // ========================
  Future<void> login() async {
    if (!loginFormKey.currentState!.validate()) return;
    isLoading.value = true;

    try {
      final result = await _authService.login(
        email: loginEmailController.text,
        password: loginPasswordController.text,
      );

      if (result.error != null) {
        _showErrorSnackbar(result.error!);
        return;
      }

      final firebaseUser = _authService.currentUser;
      if (firebaseUser != null && !firebaseUser.emailVerified) {
        _showErrorSnackbar('Email belum diverifikasi.');
        Get.offAllNamed(AppRoutes.otp, arguments: {
          'email': loginEmailController.text,
          'role': result.user?.role ?? 'student',
        });
        return;
      }

      currentUser.value = result.user;
      _navigateByRole(result.user!);

    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginWithGoogle() async {
    isLoading.value = true;
    try {
      final result = await _authService.signInWithGoogle();
      if (result.error != null) {
        _showErrorSnackbar(result.error!);
        return;
      }
      currentUser.value = result.user;
      _navigateByRole(result.user!);
    } finally {
      isLoading.value = false;
    }
  }

  // ========================
  // REGISTER
  // ========================
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
      _showSuccessSnackbar('Silakan verifikasi email Anda.');
      Get.offAllNamed(AppRoutes.otp, arguments: {'email': studentEmailController.text, 'role': 'student'});
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> registerTeacher() async {
    if (!teacherRegisterFormKey.currentState!.validate()) return;
    isLoading.value = true;
    try {
      final error = await _authService.registerTeacher(
        fullName: teacherNameController.text,
        nuptk: teacherNUPTKController.text,
        institution: teacherInstitutionController.text,
        email: teacherEmailController.text,
        password: teacherPasswordController.text,
      );
      if (error != null) {
        _showErrorSnackbar(error);
        return;
      }
      _showSuccessSnackbar('Silakan verifikasi email Anda.');
      Get.offAllNamed(AppRoutes.otp, arguments: {'email': teacherEmailController.text, 'role': 'teacher'});
    } finally {
      isLoading.value = false;
    }
  }

  // ========================
  // LUPA & GANTI PASSWORD
  // ========================
  final TextEditingController forgotEmailController = TextEditingController();

  Future<bool> sendPasswordResetEmail() async {
    if (forgotEmailController.text.trim().isEmpty) return false;
    isLoading.value = true;
    try {
      final error = await _authService.sendPasswordResetEmail(forgotEmailController.text);
      if (error != null) {
        _showErrorSnackbar(error);
        return false;
      }
      _showSuccessSnackbar('Link reset password dikirim.');
      return true;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changePassword() async {
    if (!changePasswordFormKey.currentState!.validate()) return;
    isLoading.value = true;
    try {
      final error = await _authService.changePassword(
        currentPassword: currentPasswordController.text,
        newPassword: newPasswordController.text,
      );
      if (error != null) {
        _showErrorSnackbar(error);
        return;
      }
      _showSuccessSnackbar('Kata sandi berhasil diubah!');
      currentPasswordController.clear();
      newPasswordController.clear();
      confirmNewPasswordController.clear();
      Get.back();
    } finally {
      isLoading.value = false;
    }
  }

  // ========================
  // LOGOUT
  // ========================
  Future<void> logout() async {
    isLoading.value = true;
    try {
      await _authService.logout();
      currentUser.value = null;
      Get.offAllNamed(AppRoutes.splash);
    } finally {
      isLoading.value = false;
    }
  }

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
  void _showErrorSnackbar(String message) {
    Get.snackbar('Oops!', message,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        icon: const Icon(Icons.error_outline, color: Colors.white),
        snackPosition: SnackPosition.TOP, margin: const EdgeInsets.all(16));
  }

  void _showSuccessSnackbar(String message) {
    Get.snackbar('Berhasil!', message,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle_outline, color: Colors.white),
        snackPosition: SnackPosition.TOP, margin: const EdgeInsets.all(16));
  }
}