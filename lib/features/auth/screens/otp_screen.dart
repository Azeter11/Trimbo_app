// otp_screen.dart
// Halaman tunggu verifikasi email setelah registrasi.
// Fitur: Animasi menunggu, cek status otomatis setiap 3 detik, tombol kirim ulang link.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../app/routes.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  bool _isVerified = false;
  Timer? _timer;

  // Ambil data dari arguments navigasi
  late final String _email;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, String>? ?? {};
    _email = args['email'] ?? '';

    // Mulai timer untuk cek status emailVerified setiap 3 detik
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _checkEmailVerified();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Mengecek apakah email sudah diverifikasi di Firebase.
  Future<void> _checkEmailVerified() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.reload();
      if (user.emailVerified) {
        _timer?.cancel();
        setState(() => _isVerified = true);

        // Munculkan snackbar sukses
        Get.snackbar(
          AppStrings.verificationSuccessTitle,
          AppStrings.verificationSuccessSubtitle,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );

        // Tunggu sebentar lalu arahkan ke login
        Future.delayed(const Duration(seconds: 3), () {
          Get.offAllNamed(AppRoutes.login);
        });
      }
    }
  }

  /// Mengirim ulang email verifikasi.
  Future<void> _resendEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      await user?.sendEmailVerification();

      Get.snackbar(
        'Email Terkirim',
        'Link verifikasi baru telah dikirim ke $_email',
        backgroundColor: AppColors.info,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Gagal Mengirim',
        'Coba lagi dalam beberapa saat.',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.verificationTitle),
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false, // Jangan bisa back manual
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ====== IKON / ANIMASI ======
            _isVerified ? _buildSuccessIcon() : _buildWaitingIcon(),

            SizedBox(height: 32.h),

            Text(
              _isVerified
                  ? AppStrings.verificationSuccessTitle
                  : AppStrings.verificationTitle,
              style: AppStyles.headingM,
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 16.h),

            Text(
              _isVerified
                  ? AppStrings.verificationSuccessSubtitle
                  : '${AppStrings.verificationSubtitle}\n$_email',
              style: AppStyles.bodyM.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),

            if (!_isVerified) ...[
              SizedBox(height: 24.h),

              Text(
                AppStrings.verificationWaitMessage,
                style: AppStyles.bodyS.copyWith(fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 48.h),

              // Loading indicator
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),

              SizedBox(height: 16.h),

              Text(
                AppStrings.verificationCheckStatus,
                style: AppStyles.labelL.copyWith(color: AppColors.primary),
              ),

              SizedBox(height: 60.h),

              // Tutup ke login jika ingin ganti email
              TextLinkButton(
                text: 'Gunakan email lain?',
                onPressed: () => Get.offAllNamed(AppRoutes.login),
                color: AppColors.textSecondary,
              ),

              SizedBox(height: 8.h),

              TextLinkButton(
                text: AppStrings.verificationResend,
                onPressed: _resendEmail,
              ),
            ],

            if (_isVerified) ...[
              SizedBox(height: 40.h),
              PrimaryButton(
                text: 'Masuk Sekarang',
                onPressed: () => Get.offAllNamed(AppRoutes.login),
              ),
            ],

            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _buildWaitingIcon() {
    return Container(
      width: 120.w,
      height: 120.h,
      decoration: const BoxDecoration(
        color: AppColors.primaryLight,
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.mark_email_unread_rounded,
            size: 60.sp,
            color: AppColors.primary,
          ),
          // Ring animasi
          SizedBox(
            width: 90.w,
            height: 90.h,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return Container(
      width: 120.w,
      height: 120.h,
      decoration: const BoxDecoration(
        color: AppColors.successLight,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.check_circle_rounded,
        size: 80.sp,
        color: AppColors.success,
      ),
    );
  }
}
