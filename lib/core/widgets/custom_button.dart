// custom_button.dart
// Widget tombol yang dipakai ulang di seluruh aplikasi EduTask.
// Mendukung: tombol primer (solid), sekunder (outline), dan teks link.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';

// ========================
// TOMBOL PRIMER (SOLID)
// ========================

/// Tombol utama dengan background berwarna (primary color).
/// Dipakai untuk aksi utama seperti Login, Daftar, Simpan.
class PrimaryButton extends StatelessWidget {
  final String text;       // Teks di dalam tombol
  final VoidCallback? onPressed; // Fungsi yang dipanggil saat ditekan (null = disabled)
  final bool isLoading;    // Tampilkan spinner loading jika true
  final double? width;     // Lebar tombol (default: full width)
  final double? height;    // Tinggi tombol (default: 52)
  final Color? backgroundColor; // Override warna background
  final IconData? leadingIcon;   // Ikon sebelum teks (opsional)
  final Widget? leading;         // Custom widget ikon (misal: Image.asset)
  final double? fontSize;        // Ukuran font teks (opsional)

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.height,
    this.backgroundColor,
    this.leadingIcon,
    this.leading,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 52.h,
      child: ElevatedButton(
        // onPressed null = tombol disabled (abu-abu otomatis)
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,
          disabledBackgroundColor: AppColors.textTertiary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 0,
        ),
        child: isLoading
            // Tampilkan spinner saat loading
            ? SizedBox(
                width: 22.w,
                height: 22.h,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.textOnPrimary,
                ),
              )
            // Tampilkan teks (dengan ikon opsional)
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (leading != null) ...[
                    leading!,
                    SizedBox(width: 8.w),
                  ] else if (leadingIcon != null) ...[
                    Icon(leadingIcon, size: 18.sp, color: AppColors.textOnPrimary),
                    SizedBox(width: 8.w),
                  ],
                  Text(
                    text,
                    style: AppStyles.buttonText.copyWith(
                      fontSize: fontSize,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ========================
// TOMBOL OUTLINE (SEKUNDER)
// ========================

/// Tombol sekunder dengan border tanpa background.
/// Dipakai untuk aksi sekunder seperti Batal, Lihat Detail.
class OutlineButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final double? height;
  final Color? borderColor;
  final Color? textColor;
  final IconData? leadingIcon;
  final Widget? leading;
  final double? fontSize;

  const OutlineButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.height,
    this.borderColor,
    this.textColor,
    this.leadingIcon,
    this.leading,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    // Warna default dari parameter atau warna primer
    final effectiveBorderColor = borderColor ?? AppColors.primary;
    final effectiveTextColor = textColor ?? AppColors.primary;

    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 52.h,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: effectiveBorderColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 22.w,
                height: 22.h,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: effectiveTextColor,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (leading != null) ...[
                    leading!,
                    SizedBox(width: 8.w),
                  ] else if (leadingIcon != null) ...[
                    Icon(leadingIcon, size: 18.sp, color: effectiveTextColor),
                    SizedBox(width: 8.w),
                  ],
                  Text(
                    text,
                    style: AppStyles.buttonText.copyWith(
                      color: effectiveTextColor,
                      fontSize: fontSize,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ========================
// TOMBOL TEKS (LINK)
// ========================

/// Tombol teks tanpa border dan background.
/// Dipakai untuk link seperti "Lupa Password", "Daftar".
class TextLinkButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? color;
  final double? fontSize;

  const TextLinkButton({
    super.key,
    required this.text,
    this.onPressed,
    this.color,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Text(
        text,
        style: AppStyles.labelL.copyWith(
          color: color ?? AppColors.primary,
          fontSize: fontSize?.sp,
          decoration: TextDecoration.underline,
          decorationColor: color ?? AppColors.primary,
        ),
      ),
    );
  }
}

// ========================
// TOMBOL ICON BUNDAR
// ========================

/// Tombol bundar dengan ikon di tengah.
/// Dipakai untuk aksi seperti tombol back, close, tambah (+).
class CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? size;

  const CircleIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size ?? 44.w,
        height: size ?? 44.h,
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.primaryLight,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: iconColor ?? AppColors.primary,
          size: (size != null ? size! * 0.45 : 20).sp,
        ),
      ),
    );
  }
}
