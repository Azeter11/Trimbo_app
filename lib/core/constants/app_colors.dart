// app_colors.dart
// File ini berisi semua warna yang digunakan di seluruh aplikasi EduTask.
// Tujuan: agar warna mudah diganti di satu tempat tanpa ubah banyak file.

import 'package:flutter/material.dart';

class AppColors {
  // Konstruktor private agar class ini tidak bisa di-instansiasi
  AppColors._();

  // ========================
  // WARNA UTAMA (PRIMARY) — UNSUR UNGU & PUTIH
  // ========================

  /// Warna utama aplikasi — Ungu Royal (Vibrant & Modern)
  static const Color primary = Color(0xFF7C3AED);

  /// Warna primer lebih terang (untuk hover, background ringan)
  static const Color primaryLight = Color(0xFFEDE9FE);

  /// Warna primer lebih gelap (untuk teks di atas background primer)
  static const Color primaryDark = Color(0xFF5B21B6);

  // ========================
  // WARNA SEKUNDER
  // ========================

  /// Warna sekunder — Ungu Muda (Soft Lavender)
  static const Color secondary = Color(0xFFA78BFA);

  /// Warna sekunder lebih terang
  static const Color secondaryLight = Color(0xFFF5F3FF);

  // ========================
  // WARNA STATUS / SEMANTIK
  // ========================

  /// Hijau — untuk status sukses, tugas sudah dikerjakan
  static const Color success = Color(0xFF10B981);

  /// Hijau muda — background badge sukses
  static const Color successLight = Color(0xFFD1FAE5);

  /// Kuning/Amber — untuk peringatan, deadline dekat
  static const Color warning = Color(0xFFF59E0B);

  /// Kuning muda — background badge peringatan
  static const Color warningLight = Color(0xFFFEF3C7);

  /// Merah — untuk error, tugas belum dikerjakan
  static const Color error = Color(0xFFEF4444);

  /// Merah muda — background badge error
  static const Color errorLight = Color(0xFFFEE2E2);

  /// Biru info — untuk informasi umum
  static const Color info = Color(0xFF3B82F6);

  /// Biru muda — background badge info
  static const Color infoLight = Color(0xFFDBEAFE);

  // ========================
  // WARNA LATAR BELAKANG
  // ========================

  /// Background utama halaman — sedikit warm white untuk kesan bersih
  static const Color background = Color(0xFFFAFAFA);

  /// Background card / komponen
  static const Color cardBackground = Color(0xFFFFFFFF);

  /// Background surface kedua (misal: input field)
  static const Color surfaceSecondary = Color(0xFFF3F0FF); // Sedikit hint ungu

  // ========================
  // WARNA TEKS
  // ========================

  /// Teks utama — hampir hitam
  static const Color textPrimary = Color(0xFF0F172A);

  /// Teks sekunder — abu-abu gelap (subtitle, hint)
  static const Color textSecondary = Color(0xFF64748B);

  /// Teks tersier — abu-abu terang (placeholder)
  static const Color textTertiary = Color(0xFF94A3B8);

  /// Teks di atas warna primer (tombol, dll)
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ========================
  // WARNA BORDER
  // ========================

  /// Border default
  static const Color border = Color(0xFFE2E8F0);

  /// Border saat fokus/aktif
  static const Color borderActive = Color(0xFF4F46E5);

  // ========================
  // WARNA SHADOW
  // ========================

  /// Bayangan card — ungu transparan untuk kesan modern
  static const Color shadow = Color(0x1A7C3AED); // 10% opacity ungu

  // ========================
  // GRADIENTS
  // ========================

  /// Gradient utama aplikasi (Ungu ke Biru Muda) — Modern & Cerah
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7C3AED), Color(0xFF6366F1)], // Ungu ke Indigo
  );

  /// Gradient untuk elemen statis atau dekoratif
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF5F3FF), Color(0xFFFFFFFF)],
  );

  // ========================
  // WARNA GRAFIK (CHART)
  // ========================

  /// Warna-warna untuk bar chart / pie chart
  static const List<Color> chartColors = [
    Color(0xFF7C3AED), // Ungu
    Color(0xFF10B981), // Hijau
    Color(0xFFF59E0B), // Amber
    Color(0xFFEF4444), // Merah
    Color(0xFF6366F1), // Indigo
  ];

  // ========================
  // WARNA GRADE (NILAI)
  // ========================

  /// Warna badge berdasarkan rentang nilai
  static Color gradeColor(double score) {
    if (score >= 90) return success;
    if (score >= 80) return info;
    if (score >= 70) return warning;
    if (score >= 60) return Color(0xFFFF6B35);
    return error;
  }
}
