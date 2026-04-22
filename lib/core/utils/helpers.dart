// helpers.dart
// File ini berisi fungsi-fungsi bantu (helper) yang dipakai di berbagai tempat.
// Contoh: format tanggal, generate kode kelas, hitung nilai, dll.

import 'dart:math';
import 'package:intl/intl.dart';

class Helpers {
  Helpers._();

  // ========================
  // FORMAT TANGGAL & WAKTU
  // ========================

  /// Format tanggal: "Senin, 14 Jan 2025"
  static String formatDate(DateTime date) {
    // Locale Indonesia
    return DateFormat('EEEE, dd MMM yyyy', 'id_ID').format(date);
  }

  /// Format tanggal singkat: "14 Jan 2025"
  static String formatDateShort(DateTime date) {
    return DateFormat('dd MMM yyyy', 'id_ID').format(date);
  }

  /// Format tanggal + waktu: "14 Jan 2025, 10:30"
  static String formatDateTime(DateTime date) {
    return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(date);
  }

  /// Format waktu saja: "10:30"
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  /// Format countdown timer: "05:30" dari total detik
  static String formatCountdown(int totalSeconds) {
    final minutes = totalSeconds ~/ 60; // Pembagian bulat
    final seconds = totalSeconds % 60; // Sisa detik

    // Padding dengan nol jika kurang dari 2 digit: 5 → "05"
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // ========================
  // GENERATE KODE KELAS
  // ========================

  /// Generate kode kelas acak 6 karakter (huruf kapital + angka).
  static String generateClassCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    // Menghindari karakter yang mirip: I, O, 0, 1
    final random = Random.secure();
    return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
  }

  // ========================
  // HITUNG NILAI
  // ========================

  /// Hitung nilai ujian: (jawaban benar / total soal) * 100.
  static double calculateScore(int correctAnswers, int totalQuestions) {
    if (totalQuestions == 0) return 0;
    return (correctAnswers / totalQuestions) * 100;
  }

  /// Konversi nilai angka ke grade huruf (A, B, C, D, E).
  static String scoreToGrade(double score) {
    if (score >= 90) return 'A';
    if (score >= 80) return 'B';
    if (score >= 70) return 'C';
    if (score >= 60) return 'D';
    return 'E';
  }

  /// Hitung rata-rata dari list nilai.
  static double calculateAverage(List<double> scores) {
    if (scores.isEmpty) return 0;
    final total = scores.reduce((a, b) => a + b);
    return total / scores.length;
  }

  // ========================
  // MANIPULASI TEKS
  // ========================

  /// Ambil inisial nama: "Ahmad Budi" → "AB"
  static String getInitials(String name) {
    if (name.trim().isEmpty) return '?';

    final words = name.trim().split(' ');
    if (words.length == 1) {
      // Ambil 2 huruf pertama jika hanya 1 kata
      return words[0].substring(0, min(2, words[0].length)).toUpperCase();
    }

    // Ambil huruf pertama dari 2 kata pertama
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }

  /// Potong teks jika terlalu panjang: "Pelajaran Mat..." (maxLength karakter)
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  // ========================
  // CEK DEADLINE
  // ========================

  /// Cek apakah deadline sudah lewat.
  static bool isDeadlinePassed(DateTime deadline) {
    return DateTime.now().isAfter(deadline);
  }

  /// Cek apakah deadline dalam 3 hari ke depan.
  static bool isDeadlineNear(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now);
    return difference.inDays <= 3 && difference.isNegative == false;
  }

  /// Hitung sisa waktu deadline dalam format yang mudah dibaca.
  static String getTimeRemaining(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now);

    if (difference.isNegative) return 'Waktu habis';
    if (difference.inDays > 0) return '${difference.inDays} hari lagi';
    if (difference.inHours > 0) return '${difference.inHours} jam lagi';
    if (difference.inMinutes > 0) return '${difference.inMinutes} menit lagi';
    return 'Sebentar lagi';
  }

  // ========================
  // FORMAT ANGKA
  // ========================

  /// Format angka: 1234567 → "1.234.567"
  static String formatNumber(int number) {
    return NumberFormat('#,###', 'id_ID').format(number);
  }

  /// Format nilai dengan 1 desimal: 85.567 → "85.6"
  static String formatScore(double score) {
    return score.toStringAsFixed(1);
  }
}
