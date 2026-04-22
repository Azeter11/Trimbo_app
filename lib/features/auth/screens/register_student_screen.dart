// register_student_screen.dart
// Halaman pendaftaran akun siswa baru.
// Form: Nama Lengkap, Email, Password, Konfirmasi Password.

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

class RegisterStudentScreen extends StatelessWidget {
  const RegisterStudentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController controller = Get.find<AuthController>();

    return Obx(
      () => LoadingOverlay(
        isLoading: controller.isLoading.value,
        message: 'Membuat akun...',
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Daftar sebagai Siswa'),
            backgroundColor: AppColors.background,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Form(
              key: controller.studentRegisterFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.h),

                  // ====== HEADER ======
                  _buildHeader(),

                  SizedBox(height: 32.h),

                  // ====== FORM SISWA ======
                  _buildStudentForm(controller),

                  SizedBox(height: 32.h),

                  // ====== TOMBOL DAFTAR ======
                  PrimaryButton(
                    text: AppStrings.registerButton,
                    onPressed: controller.registerStudent,
                    isLoading: controller.isLoading.value,
                  ),

                  SizedBox(height: 20.h),

                  // ====== LINK MASUK ======
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppStrings.registerHaveAccount,
                          style: AppStyles.bodyM.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        TextLinkButton(
                          text: AppStrings.registerLoginLink,
                          onPressed: () => Get.offNamed(AppRoutes.login),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mini logo
        Container(
          width: 56.w,
          height: 56.h,
          margin: EdgeInsets.only(bottom: 24.h),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
            ),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: Image.asset(
              'assets/icons/TrimboIcon.png',
              fit: BoxFit.cover,
            ),
          ),
        ),

        // Badge role
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.person_rounded, size: 16.sp, color: AppColors.primary),
              SizedBox(width: 6.w),
              Text(
                'Akun Siswa',
                style: AppStyles.labelS.copyWith(color: AppColors.primary),
              ),
            ],
          ),
        ),

        SizedBox(height: 12.h),

        Text(AppStrings.registerTitle, style: AppStyles.headingL),

        SizedBox(height: 8.h),

        Text(
          'Isi data diri Anda untuk membuat akun siswa',
          style: AppStyles.bodyM.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildStudentForm(AuthController controller) {
    return Column(
      children: [
        // Nama Lengkap
        CustomTextField(
          label: AppStrings.registerFullName,
          hint: AppStrings.registerFullNameHint,
          controller: controller.studentNameController,
          validator: Validators.fullName,
          prefixIcon: Icon(
            Icons.person_outline_rounded,
            color: AppColors.textSecondary,
            size: 20.sp,
          ),
          textInputAction: TextInputAction.next,
        ),

        SizedBox(height: 16.h),

        // Email
        CustomTextField(
          label: AppStrings.registerEmail,
          hint: AppStrings.registerEmailHint,
          controller: controller.studentEmailController,
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

        // Password
        PasswordTextField(
          label: AppStrings.registerPassword,
          controller: controller.studentPasswordController,
          validator: Validators.password,
          textInputAction: TextInputAction.next,
        ),

        SizedBox(height: 16.h),

        // Konfirmasi Password
        PasswordTextField(
          label: AppStrings.registerConfirmPassword,
          controller: controller.studentConfirmPasswordController,
          validator: (value) => Validators.confirmPassword(
            value,
            controller.studentPasswordController.text,
          ),
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }
}
