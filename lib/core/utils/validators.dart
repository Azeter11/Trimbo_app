// validators.dart
// File ini berisi semua fungsi validasi untuk form input.
// Dikumpulkan di satu tempat agar mudah dipakai ulang dan diubah.

import '../constants/app_strings.dart';

class Validators {
  Validators._();

  // ========================
  // VALIDASI EMAIL
  // ========================

  /// Validasi format email. Mengembalikan pesan error atau null jika valid.
  static String? email(String? value) {
    // Cek apakah kosong
    if (value == null || value.trim().isEmpty) {
      return AppStrings.errorFieldRequired;
    }

    // Regex untuk format email standard
    final emailRegex = RegExp(r'^[\w\-\.]+@[\w\-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return AppStrings.errorInvalidEmail;
    }

    return null; // null berarti valid
  }

  // ========================
  // VALIDASI PASSWORD
  // ========================

  /// Validasi kata sandi minimal 8 karakter.
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.errorFieldRequired;
    }

    if (value.length < 8) {
      return AppStrings.errorPasswordTooShort;
    }

    return null;
  }

  /// Validasi konfirmasi password harus sama dengan password asli.
  static String? confirmPassword(String? value, String originalPassword) {
    // Validasi tidak kosong dulu
    final emptyCheck = password(value);
    if (emptyCheck != null) return emptyCheck;

    // Cek kecocokan
    if (value != originalPassword) {
      return AppStrings.errorPasswordNotMatch;
    }

    return null;
  }

  // ========================
  // VALIDASI NAMA
  // ========================

  /// Validasi nama tidak boleh kosong dan minimal 2 karakter.
  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.errorFieldRequired;
    }

    if (value.trim().length < 2) {
      return 'Nama minimal 2 karakter';
    }

    return null;
  }

  // ========================
  // VALIDASI KOLOM WAJIB
  // ========================

  /// Validasi kolom yang wajib diisi (tidak boleh kosong).
  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.errorFieldRequired;
    }
    return null;
  }

  // ========================
  // VALIDASI KODE KELAS
  // ========================

  /// Validasi kode kelas: 6 karakter huruf/angka kapital.
  static String? classCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.errorFieldRequired;
    }

    if (value.trim().length != 6) {
      return 'Kode kelas harus 6 karakter';
    }

    // Regex: hanya huruf kapital dan angka
    final codeRegex = RegExp(r'^[A-Z0-9]{6}$');
    if (!codeRegex.hasMatch(value.trim().toUpperCase())) {
      return 'Kode kelas hanya boleh huruf dan angka';
    }

    return null;
  }

  // ========================
  // VALIDASI OTP
  // ========================

  /// Validasi OTP harus 6 digit angka.
  static String? otp(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.errorFieldRequired;
    }

    if (value.length != 6) {
      return 'OTP harus 6 digit';
    }

    // Hanya boleh angka
    final otpRegex = RegExp(r'^\d{6}$');
    if (!otpRegex.hasMatch(value)) {
      return 'OTP hanya boleh berisi angka';
    }

    return null;
  }

  // ========================
  // VALIDASI NIDN (GURU)
  // ========================

  /// Validasi NUPTK harus 16 digit angka.
  static String? nuptk(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.errorFieldRequired;
    }

    final nuptkRegex = RegExp(r'^\d{16}$');
    if (!nuptkRegex.hasMatch(value.trim())) {
      return 'NUPTK harus 16 digit angka';
    }

    return null;
  }

  // ========================
  // VALIDASI DURASI
  // ========================

  /// Validasi durasi ujian: antara 1-180 menit.
  static String? duration(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.errorFieldRequired;
    }

    final minutes = int.tryParse(value);
    if (minutes == null) {
      return 'Masukkan angka yang valid';
    }

    if (minutes < 1 || minutes > 180) {
      return 'Durasi antara 1-180 menit';
    }

    return null;
  }
}
