// splash_screen.dart
// Halaman pertama yang muncul saat aplikasi dibuka.
// Menampilkan logo + nama aplikasi, lalu cek status login.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_styles.dart';
import '../../../services/notification_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  // Controller animasi untuk efek fade-in logo
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Setup animasi fade-in
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );

    // Mulai animasi
    _animController.forward();

    // Cek login setelah 2 detik (animasi selesai)
    _initApp();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  /// Tunggu sebentar, lalu cek status login via AuthController.
  Future<void> _initApp() async {
    // Inisialisasi service notifikasi
    await Get.find<NotificationService>().initialize();
    
    await Future.delayed(const Duration(seconds: 3));
    // Panggil fungsi cek login secara eksplisit agar splash muncul saat logout juga
    Get.find<AuthController>().checkCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background gradient indigo ke ungu
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,   // Indigo
              AppColors.secondary, // Ungu
            ],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ====== IKON APLIKASI ======
              Container(
                width: 100.w,
                height: 100.h,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24.r),
                  child: Image.asset(
                    'assets/icons/TrimboIcon.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              // ====== NAMA APLIKASI ======
              Text(
                AppStrings.appName,
                style: AppStyles.headingXL.copyWith(
                  color: Colors.white,
                  fontSize: 36.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),

              SizedBox(height: 8.h),

              // ====== TAGLINE ======
              Text(
                AppStrings.appTagline,
                style: AppStyles.bodyL.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),

              SizedBox(height: 80.h),

              // ====== LOADING INDICATOR ======
              SizedBox(
                width: 24.w,
                height: 24.h,
                child: CircularProgressIndicator(
                  color: Colors.white.withOpacity(0.8),
                  strokeWidth: 2.5,
                ),
              ),

              SizedBox(height: 12.h),

              Text(
                AppStrings.splashLoading,
                style: AppStyles.bodyS.copyWith(
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
