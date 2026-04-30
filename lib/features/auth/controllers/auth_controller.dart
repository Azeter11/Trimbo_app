// auth_controller.dart
// Controller GetX untuk mengelola semua logika autentikasi.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';
import '../../../services/firebase_auth_service.dart';
import '../../../app/routes.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http; // Untuk upload ke Cloudinary
import 'dart:convert'; // Untuk membaca hasil upload
import 'dart:io';

class AuthController extends GetxController {
  final FirebaseAuthService _authService = Get.find<FirebaseAuthService>();

  // ========================
  // UPDATE PROFILE PICTURE (MENGGUNAKAN CLOUDINARY - ANTI BLOKIR)
  // ========================
  Future<void> updateProfilePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      isLoading.value = true;

      try {
        File file = File(pickedFile.path);
        String uid = currentUser.value!.uid;

        // 1. Ganti dengan data Cloudinary Anda
        // TODO: Masukkan Cloud Name dan Upload Preset Anda di sini!
        String cloudName = 'defhvwndv';
        String uploadPreset = 'trimbo';

        // 2. Kirim gambar ke Cloudinary
        var request = http.MultipartRequest(
            'POST',
            Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload')
        );
        request.fields['upload_preset'] = uploadPreset;
        request.files.add(await http.MultipartFile.fromPath('file', file.path));

        var response = await request.send();
        var responseData = await response.stream.bytesToString();
        var jsonResult = json.decode(responseData);

        // Jika berhasil di-upload ke Cloudinary (status 200)
        if (response.statusCode == 200) {

          // Dapatkan URL gambar permanen (HTTPS) dari Cloudinary
          String photoUrl = jsonResult['secure_url'];

          // 3. Simpan URL tersebut ke Firestore pengguna kita
          await FirebaseFirestore.instance.collection('users').doc(uid).update({
            'photoUrl': photoUrl,
          });

          // 4. Update UI secara real-time
          if (currentUser.value != null) {
            currentUser.value!.photoUrl = photoUrl;
            currentUser.refresh();
          }

          _showSuccessSnackbar('Foto profil berhasil diperbarui!');
        } else {
          _showErrorSnackbar('Gagal: ${jsonResult['error']['message']}');
        }

      } catch (e) {
        _showErrorSnackbar('Terjadi kesalahan koneksi internet: $e');
      } finally {
        isLoading.value = false;
      }
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
    final firebaseUser = _authService.currentUser;

    if (firebaseUser != null) {
      await firebaseUser.reload();
      final refreshedUser = _authService.currentUser;

      if (refreshedUser == null || !refreshedUser.emailVerified) {
        Get.offAllNamed(AppRoutes.login);
        return;
      }

      final userData = await _authService.getUserData(refreshedUser.uid);

      if (userData != null) {
        currentUser.value = userData;
        _navigateByRole(userData);
      } else {
        Get.offAllNamed(AppRoutes.login);
      }
    } else {
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