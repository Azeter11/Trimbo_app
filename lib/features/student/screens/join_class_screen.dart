// join_class_screen.dart
// Halaman untuk siswa bergabung ke kelas menggunakan kode 6 karakter.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/student_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_textfield.dart';
import '../../../core/widgets/loading_overlay.dart';

class JoinClassScreen extends StatefulWidget {
  const JoinClassScreen({super.key});

  @override
  State<JoinClassScreen> createState() => _JoinClassScreenState();
}

class _JoinClassScreenState extends State<JoinClassScreen> {
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final StudentController controller = Get.find<StudentController>();

    return Obx(
      () => LoadingOverlay(
        isLoading: controller.isLoading.value,
        message: 'Mencari kelas...',
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(AppStrings.joinClassTitle),
            backgroundColor: AppColors.background,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(height: 24.h),

                  // ====== ILUSTRASI ======
                  Container(
                    width: 100.w,
                    height: 100.h,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.group_add_rounded,
                      size: 48.sp,
                      color: AppColors.primary,
                    ),
                  ),

                  SizedBox(height: 24.h),

                  Text(AppStrings.joinClassTitle, style: AppStyles.headingM),

                  SizedBox(height: 8.h),

                  Text(
                    AppStrings.joinClassSubtitle,
                    style: AppStyles.bodyM.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 40.h),

                  // ====== INPUT KODE KELAS ======
                  CustomTextField(
                    label: AppStrings.classCodeLabel,
                    hint: AppStrings.classCodeHint,
                    controller: _codeController,
                    // Validator kode kelas: 6 karakter huruf/angka
                    validator: Validators.classCode,
                    prefixIcon: Icon(
                      Icons.vpn_key_rounded,
                      color: AppColors.textSecondary,
                      size: 20.sp,
                    ),
                    // Auto uppercase saat mengetik
                    inputFormatters: [
                      UpperCaseTextFormatter(),
                      LengthLimitingTextInputFormatter(6),
                      // Hanya huruf dan angka
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[A-Z0-9]'),
                      ),
                    ],
                    textInputAction: TextInputAction.done,
                  ),

                  SizedBox(height: 24.h),

                  // ====== TOMBOL GABUNG ======
                  PrimaryButton(
                    text: AppStrings.joinClassButton,
                    onPressed: () => _joinClass(controller),
                    isLoading: controller.isLoading.value,
                    leadingIcon: Icons.login_rounded,
                  ),

                  SizedBox(height: 32.h),

                  // ====== PANDUAN ======
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: AppColors.infoLight,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.help_outline_rounded,
                                color: AppColors.info, size: 18.sp),
                            SizedBox(width: 8.w),
                            Text(
                              'Cara mendapatkan kode kelas:',
                              style: AppStyles.labelL.copyWith(
                                color: AppColors.info,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          '1. Minta kode kelas dari guru Anda\n'
                          '2. Kode terdiri dari 6 huruf/angka kapital\n'
                          '3. Contoh: ABC123 atau XY789Z',
                          style: AppStyles.bodyM.copyWith(
                            color: AppColors.info,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Proses bergabung ke kelas.
  Future<void> _joinClass(StudentController controller) async {
    if (!_formKey.currentState!.validate()) return;

    final error = await controller.joinClass(_codeController.text);

    if (error != null) {
      Get.snackbar(
        'Gagal',
        error,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        margin: EdgeInsets.all(16.w),
      );
    } else {
      Get.snackbar(
        'Berhasil!',
        AppStrings.joinClassSuccess,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        margin: EdgeInsets.all(16.w),
      );
      Get.back(); // Kembali ke dashboard
    }
  }
}

/// TextInputFormatter untuk mengubah input menjadi huruf kapital secara otomatis.
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
