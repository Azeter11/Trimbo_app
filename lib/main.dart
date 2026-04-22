// main.dart
// Entry point utama aplikasi EduTask.
// Inisialisasi Firebase, plugin, dan jalankan aplikasi.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app/app.dart';

/// Fungsi utama yang dijalankan pertama kali saat app dibuka.
Future<void> main() async {
  // Pastikan Flutter sudah siap sebelum inisialisasi plugin
  WidgetsFlutterBinding.ensureInitialized();

  // ====== INISIALISASI FIREBASE ======
  // Harus dilakukan sebelum menggunakan Firebase Auth, Firestore, dsb.
  await Firebase.initializeApp();

  // ====== INISIALISASI LOCALE INDONESIA ======
  // Agar DateFormat menggunakan nama bulan/hari bahasa Indonesia
  await initializeDateFormatting('id_ID', null);

  // ====== SETTING UI SISTEM ======
  // Status bar transparan agar header gradient terlihat lebih mulus
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Paksa orientasi portrait saja (tidak bisa landscape)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ====== JALANKAN APLIKASI ======
  runApp(const TrimboApp());
}
