// splash_screen.dart
// Halaman pertama yang muncul saat aplikasi dibuka.
// Menampilkan logo + nama aplikasi, lalu cek status login.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../app/routes.dart';
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
  /// Dilindungi dengan total timeout 15 detik sebagai safety net agar
  /// tidak pernah stuck di splash selamanya meski Firebase/jaringan bermasalah.
  Future<void> _initApp() async {
    // ====== SAFETY NET: Total timeout 15 detik ======
    // Jika dalam 15 detik app belum berpindah halaman (karena error apapun),
    // paksa redirect ke login agar penguji tidak stuck selamanya.
    Future.delayed(const Duration(seconds: 15), () {
      // Cek apakah widget masih mounted (belum di-navigate)
      if (mounted) {
        debugPrint("[SPLASH] Safety timeout triggered — force redirect to login");
        Get.offAllNamed(AppRoutes.login);
      }
    });

    try {
      // Inisialisasi service notifikasi dengan timeout agar tidak menghambat loading utama
      await Get.find<NotificationService>().initialize().timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint("[SPLASH] Gagal inisialisasi NotificationService: $e");
    }

    await Future.delayed(const Duration(seconds: 3));

    // Panggil fungsi cek login secara eksplisit agar splash muncul saat logout juga
    try {
      await Get.find<AuthController>().checkCurrentUser();
    } catch (e) {
      debugPrint("[SPLASH] Gagal checkCurrentUser: $e");
      if (mounted) {
        Get.offAllNamed(AppRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background gradient ungu
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary,   // Ungu
              AppColors.primaryDark, // Ungu Gelap
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
                width: 120.w,
                height: 120.h,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(32.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryDark.withOpacity(0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32.r),
                  child: Image.asset(
                    'assets/icons/TrimboIcon.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              SizedBox(height: 32.h),

              // ====== NAMA APLIKASI ======
              Text(
                AppStrings.appName,
                style: AppStyles.headingXL.copyWith(
                  color: Colors.white,
                  fontSize: 40.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),

              SizedBox(height: 8.h),

              // ====== TAGLINE ======
              Text(
                AppStrings.appTagline,
                style: AppStyles.bodyL.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16.sp,
                ),
              ),

              SizedBox(height: 80.h),

              // ====== LOADING INDICATOR ======
              SizedBox(
                width: 28.w,
                height: 28.h,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              ),

              SizedBox(height: 16.h),

              Text(
                AppStrings.splashLoading,
                style: AppStyles.bodyS.copyWith(
                  color: Colors.white.withOpacity(0.7),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
