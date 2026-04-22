// register_teacher_screen.dart
// Halaman pendaftaran akun guru baru.
// Form tambahan: NIDN dan Tempat Mengajar.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class RegisterTeacherScreen extends StatelessWidget {
  const RegisterTeacherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController controller = Get.find<AuthController>();

    return Obx(
      () => LoadingOverlay(
        isLoading: controller.isLoading.value,
        message: 'Membuat akun guru...',
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Daftar sebagai Guru'),
            backgroundColor: AppColors.background,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Form(
              key: controller.teacherRegisterFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.h),

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
                      color: AppColors.secondaryLight,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.school_rounded, size: 16.sp, color: AppColors.secondary),
                        SizedBox(width: 6.w),
                        Text(
                          'Akun Guru',
                          style: AppStyles.labelS.copyWith(color: AppColors.secondary),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 12.h),

                  Text(AppStrings.registerTitle, style: AppStyles.headingL),

                  SizedBox(height: 8.h),

                  Text(
                    'Isi data lengkap Anda untuk membuat akun guru',
                    style: AppStyles.bodyM.copyWith(color: AppColors.textSecondary),
                  ),

                  SizedBox(height: 28.h),

                  // Nama Lengkap
                  CustomTextField(
                    label: AppStrings.registerFullName,
                    hint: AppStrings.registerFullNameHint,
                    controller: controller.teacherNameController,
                    validator: Validators.fullName,
                    prefixIcon: Icon(Icons.person_outline_rounded, color: AppColors.textSecondary, size: 20.sp),
                    textInputAction: TextInputAction.next,
                  ),

                  SizedBox(height: 16.h),

                  // NIDN
                  CustomTextField(
                    label: AppStrings.registerNIDN,
                    hint: AppStrings.registerNIDNHint,
                    controller: controller.teacherNIDNController,
                    keyboardType: TextInputType.number,
                    validator: Validators.nidn,
                    maxLength: 10,
                    prefixIcon: Icon(Icons.badge_outlined, color: AppColors.textSecondary, size: 20.sp),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textInputAction: TextInputAction.next,
                  ),

                  SizedBox(height: 16.h),

                  // Tempat Mengajar
                  CustomTextField(
                    label: AppStrings.registerInstitution,
                    hint: AppStrings.registerInstitutionHint,
                    controller: controller.teacherInstitutionController,
                    validator: Validators.required,
                    prefixIcon: Icon(Icons.business_outlined, color: AppColors.textSecondary, size: 20.sp),
                    textInputAction: TextInputAction.next,
                  ),

                  SizedBox(height: 16.h),

                  // Email
                  CustomTextField(
                    label: AppStrings.registerEmail,
                    hint: AppStrings.registerEmailHint,
                    controller: controller.teacherEmailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                    prefixIcon: Icon(Icons.email_outlined, color: AppColors.textSecondary, size: 20.sp),
                    textInputAction: TextInputAction.next,
                  ),

                  SizedBox(height: 16.h),

                  // Password
                  PasswordTextField(
                    label: AppStrings.registerPassword,
                    controller: controller.teacherPasswordController,
                    validator: Validators.password,
                    textInputAction: TextInputAction.next,
                  ),

                  SizedBox(height: 16.h),

                  // Konfirmasi Password
                  PasswordTextField(
                    label: AppStrings.registerConfirmPassword,
                    controller: controller.teacherConfirmPasswordController,
                    validator: (v) => Validators.confirmPassword(
                      v, controller.teacherPasswordController.text,
                    ),
                    textInputAction: TextInputAction.done,
                  ),

                  SizedBox(height: 32.h),

                  PrimaryButton(
                    text: AppStrings.registerButton,
                    onPressed: controller.registerTeacher,
                    isLoading: controller.isLoading.value,
                  ),

                  SizedBox(height: 20.h),

                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppStrings.registerHaveAccount,
                          style: AppStyles.bodyM.copyWith(color: AppColors.textSecondary),
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
}
