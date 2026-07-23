// login_screen.dart
// Halaman login untuk masuk ke aplikasi EduTask.
// Fitur: validasi form, loading state, navigasi ke register & lupa password.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_textfield.dart';
import '../../../core/widgets/loading_overlay.dart';
import '../../../app/routes.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ambil controller yang sudah terdaftar di GetX
    final AuthController controller = Get.find<AuthController>();

    return Obx(
      () => LoadingOverlay(
        isLoading: controller.isLoading.value,
        message: 'Sedang masuk...',
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Form(
                key: controller.loginFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 48.h),

                    // ====== HEADER ======
                    _buildHeader(),

                    SizedBox(height: 40.h),

                    // ====== FORM LOGIN ======
                    _buildLoginForm(controller),

                    SizedBox(height: 24.h),

                    // ====== TOMBOL LOGIN ======
                    PrimaryButton(
                      text: AppStrings.loginButton,
                      onPressed: controller.login,
                      isLoading: controller.isLoading.value,
                    ),

                    SizedBox(height: 16.h),

                    // ====== LINK LUPA PASSWORD ======
                    Center(
                      child: TextLinkButton(
                        text: AppStrings.loginForgotPassword,
                        onPressed: () => Get.toNamed(AppRoutes.forgotPassword),
                        color: AppColors.textSecondary,
                      ),
                    ),

                    SizedBox(height: 40.h),

                    // ====== DIVIDER ======
                    Row(
                      children: [
                        Expanded(child: Divider(color: AppColors.border)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Text(
                            'atau',
                            style: AppStyles.bodyS,
                          ),
                        ),
                        Expanded(child: Divider(color: AppColors.border)),
                      ],
                    ),

                    SizedBox(height: 24.h),

                    // ====== TOMBOL GOOGLE ======
                    OutlineButton(
                      text: 'Masuk dengan Google',
                      onPressed: controller.loginWithGoogle,
                      leading: const _GoogleIcon(size: 20),
                      borderColor: AppColors.border,
                      textColor: AppColors.textPrimary,
                    ),

                    SizedBox(height: 24.h),

                    // ====== TOMBOL DAFTAR ======
                    _buildRegisterSection(),

                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Widget bagian header (logo + judul)
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mini logo
        Container(
          width: 64.w,
          height: 64.h,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.r),
            child: Image.asset(
              'assets/icons/TrimboIcon.png',
              fit: BoxFit.cover,
            ),
          ),
        ),

        SizedBox(height: 32.h),

        // Judul
        Text(AppStrings.loginTitle, style: AppStyles.headingL),

        SizedBox(height: 8.h),

        // Sub-judul
        Text(
          AppStrings.loginSubtitle,
          style: AppStyles.bodyM.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  /// Widget form input email dan password
  Widget _buildLoginForm(AuthController controller) {
    return Column(
      children: [
        // Input Email
        CustomTextField(
          label: AppStrings.loginEmail,
          hint: AppStrings.loginEmailHint,
          controller: controller.loginEmailController,
          keyboardType: TextInputType.emailAddress,
          validator: Validators.email,
          prefixIcon: Icon(
            Icons.email_outlined,
            color: AppColors.textSecondary,
            size: 20.sp,
          ),
          textInputAction: TextInputAction.next,
        ),

        SizedBox(height: 16.h),

        // Input Password
        PasswordTextField(
          label: AppStrings.loginPassword,
          controller: controller.loginPasswordController,
          validator: Validators.password,
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }

  /// Widget bagian link daftar akun baru
  Widget _buildRegisterSection() {
    return Column(
      children: [
        // Label
        Center(
          child: Text(
            'Belum punya akun? Daftar sebagai:',
            style: AppStyles.bodyM.copyWith(color: AppColors.textSecondary),
          ),
        ),

        SizedBox(height: 12.h),

        // Dua tombol: Siswa dan Guru
        Row(
          children: [
            // Tombol daftar sebagai siswa
            Expanded(
              child: OutlineButton(
                text: AppStrings.registerAsStudent,
                onPressed: () => Get.toNamed(AppRoutes.registerStudent),
                leadingIcon: Icons.person_outline_rounded,
              ),
            ),

            SizedBox(width: 12.w),

            // Tombol daftar sebagai guru
            Expanded(
              child: OutlineButton(
                text: AppStrings.registerAsTeacher,
                onPressed: () => Get.toNamed(AppRoutes.registerTeacher),
                leadingIcon: Icons.school_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ========================
// GOOGLE ICON (Image Asset)
// ========================

/// Widget ikon Google menggunakan file PNG resmi agar tampil lebih profesional.
class _GoogleIcon extends StatelessWidget {
  final double size;
  const _GoogleIcon({this.size = 20});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/icons/icon_google.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}
