// loading_overlay.dart
// Widget overlay loading yang menutup seluruh layar saat proses berjalan.
// Dipakai saat login, register, submit tugas, dll agar user tidak bisa klik lain.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';

/// Overlay loading yang menutupi layar dengan efek blur ringan.
/// Gunakan di-stack di atas konten halaman.
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;   // Tampilkan overlay jika true
  final Widget child;     // Konten halaman di balik overlay
  final String? message;  // Pesan loading (opsional)

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Konten utama halaman
        child,

        // Overlay loading hanya ditampilkan jika isLoading = true
        if (isLoading)
          Container(
            // Menutupi seluruh layar
            width: double.infinity,
            height: double.infinity,
            // Warna semi-transparan agar konten di balik masih terlihat samar
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 40.w,
                  vertical: 32.h,
                ),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.15),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Sesuaikan ukuran dengan konten
                  children: [
                    // Spinner loading dengan container ungu muda
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 3,
                      ),
                    ),
                    // Pesan loading (jika ada)
                    if (message != null) ...[
                      SizedBox(height: 20.h),
                      Text(
                        message!,
                        style: AppStyles.bodyM.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ========================
// WIDGET EMPTY STATE
// ========================

/// Widget yang ditampilkan saat tidak ada data.
/// Contoh: kelas kosong, tidak ada tugas, dll.
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;   // Ikon
  final String title;    // Judul pesan
  final String? subtitle; // Sub-pesan (opsional)
  final Widget? action;  // Tombol aksi (opsional)

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ikon besar dengan efek shadow
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 52.sp,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 24.h),

            // Judul
            Text(
              title,
              style: AppStyles.headingS.copyWith(fontSize: 18.sp),
              textAlign: TextAlign.center,
            ),

            // Sub-judul (opsional)
            if (subtitle != null) ...[
              SizedBox(height: 10.h),
              Text(
                subtitle!,
                style: AppStyles.bodyM.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // Tombol aksi (opsional)
            if (action != null) ...[
              SizedBox(height: 28.h),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

// ========================
// WIDGET ERROR STATE
// ========================

/// Widget yang ditampilkan saat terjadi error.
class ErrorStateWidget extends StatelessWidget {
  final String message;      // Pesan error
  final VoidCallback? onRetry; // Aksi coba lagi

  const ErrorStateWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.error.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 52.sp,
                color: AppColors.error,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Terjadi Kesalahan',
              style: AppStyles.headingS.copyWith(fontSize: 18.sp),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10.h),
            Text(
              message,
              style: AppStyles.bodyM.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: 28.h),
              TextButton.icon(
                onPressed: onRetry,
                icon: Icon(Icons.refresh_rounded),
                label: const Text('Coba Lagi'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
