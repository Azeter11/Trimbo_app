// forgot_password_screen.dart
// Halaman lupa password dengan 3 langkah:
// Step 1: Input email → kirim link reset
// Step 2: Konfirmasi pengiriman
// Step 3: Sukses (arahkan ke login)

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

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // Step saat ini: 1 = input email, 2 = konfirmasi sukses
  int _currentStep = 1;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final AuthController controller = Get.find<AuthController>();

    return Obx(
      () => LoadingOverlay(
        isLoading: controller.isLoading.value,
        message: 'Mengirim email...',
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(AppStrings.forgotPasswordTitle),
            backgroundColor: AppColors.background,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              children: [
                SizedBox(height: 32.h),

                // Tampilkan halaman sesuai step
                if (_currentStep == 1)
                  _buildStep1(controller)
                else
                  _buildStep2(controller),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Step 1: Input email untuk kirim link reset password.
  Widget _buildStep1(AuthController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Ikon
        Container(
          width: 80.w,
          height: 80.h,
          decoration: BoxDecoration(
            color: AppColors.warningLight,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.lock_reset_rounded,
            size: 40.sp,
            color: AppColors.warning,
          ),
        ),

        SizedBox(height: 24.h),

        Text(AppStrings.forgotPasswordTitle, style: AppStyles.headingM),

        SizedBox(height: 8.h),

        Text(
          AppStrings.forgotPasswordStep1Subtitle,
          style: AppStyles.bodyM.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 36.h),

        // Form email
        Form(
          key: _formKey,
          child: CustomTextField(
            label: 'Alamat Email',
            hint: 'Masukkan email yang terdaftar',
            controller: controller.forgotEmailController,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.email,
            prefixIcon: Icon(
              Icons.email_outlined,
              color: AppColors.textSecondary,
              size: 20.sp,
            ),
          ),
        ),

        SizedBox(height: 24.h),

        // Tombol kirim
        PrimaryButton(
          text: AppStrings.forgotPasswordSendLink,
          onPressed: () async {
            if (!_formKey.currentState!.validate()) return;
            bool success = await controller.sendPasswordResetEmail();
            // Pindah ke step 2 jika berhasil
            if (success) {
              setState(() => _currentStep = 2);
            }
          },
          isLoading: controller.isLoading.value,
        ),
      ],
    );
  }

  /// Step 2: Konfirmasi sukses — email sudah dikirim.
  Widget _buildStep2(AuthController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Ikon sukses
        Container(
          width: 80.w,
          height: 80.h,
          decoration: BoxDecoration(
            color: AppColors.successLight,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.mark_email_read_rounded,
            size: 40.sp,
            color: AppColors.success,
          ),
        ),

        SizedBox(height: 24.h),

        Text('Email Terkirim!', style: AppStyles.headingM),

        SizedBox(height: 12.h),

        Text(
          'Link reset password telah dikirim ke:\n${controller.forgotEmailController.text}',
          style: AppStyles.bodyM.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 12.h),

        Text(
          'Periksa inbox atau folder spam Anda, lalu ikuti instruksi di email.',
          style: AppStyles.bodyS,
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 40.h),

        // Tombol kembali ke login
        PrimaryButton(
          text: 'Kembali ke Login',
          onPressed: () => Get.offAllNamed(AppRoutes.login),
        ),

        SizedBox(height: 16.h),

        // Kirim ulang
        TextLinkButton(
          text: 'Tidak menerima email? Kirim ulang',
          onPressed: () => setState(() => _currentStep = 1),
          color: AppColors.textSecondary,
        ),
      ],
    );
  }
}
