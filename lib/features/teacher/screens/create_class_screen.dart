// create_class_screen.dart
// Halaman buat kelas baru oleh guru.
// Setelah berhasil, tampilkan dialog dengan kode kelas.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/teacher_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_textfield.dart';
import '../../../core/widgets/loading_overlay.dart';

class CreateClassScreen extends StatelessWidget {
  const CreateClassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TeacherController controller = Get.find<TeacherController>();

    return Obx(
      () => LoadingOverlay(
        isLoading: controller.isLoading.value,
        message: 'Membuat kelas...',
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(AppStrings.createClassTitle),
            backgroundColor: AppColors.background,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Form(
              key: controller.createClassFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ilustrasi kecil
                  Center(
                    child: Container(
                      width: 80.w,
                      height: 80.h,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.add_circle_rounded,
                        size: 40.sp,
                        color: AppColors.primary,
                      ),
                    ),
                  ),

                  SizedBox(height: 24.h),

                  Text(AppStrings.createClassTitle, style: AppStyles.headingM),

                  SizedBox(height: 8.h),

                  Text(
                    'Isi informasi kelas yang akan dibuat',
                    style: AppStyles.bodyM.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),

                  SizedBox(height: 32.h),

                  // Nama Kelas
                  CustomTextField(
                    label: AppStrings.createClassName,
                    hint: AppStrings.createClassNameHint,
                    controller: controller.classNameController,
                    validator: Validators.required,
                    prefixIcon: Icon(
                      Icons.class_outlined,
                      color: AppColors.textSecondary,
                      size: 20.sp,
                    ),
                    textInputAction: TextInputAction.next,
                  ),

                  SizedBox(height: 16.h),

                  // Deskripsi
                  CustomTextField(
                    label: AppStrings.createClassDescription,
                    hint: AppStrings.createClassDescriptionHint,
                    controller: controller.classDescController,
                    validator: Validators.required,
                    maxLines: 4,
                    prefixIcon: Icon(
                      Icons.description_outlined,
                      color: AppColors.textSecondary,
                      size: 20.sp,
                    ),
                    textInputAction: TextInputAction.done,
                  ),

                  SizedBox(height: 32.h),

                  // Tombol buat kelas
                  PrimaryButton(
                    text: AppStrings.createClassButton,
                    onPressed: () => _createClass(context, controller),
                    leadingIcon: Icons.add_rounded,
                  ),

                  SizedBox(height: 16.h),

                  // Catatan: kode kelas auto-generate
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppColors.infoLight,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline_rounded,
                            color: AppColors.info, size: 18.sp),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            'Kode kelas akan dibuat otomatis setelah kelas dibuat.',
                            style: AppStyles.bodyS.copyWith(
                              color: AppColors.info,
                            ),
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

  /// Buat kelas dan tampilkan dialog kode kelas.
  Future<void> _createClass(
    BuildContext context,
    TeacherController controller,
  ) async {
    final result = await controller.createClass();

    // Jika error
    if (result.error != null) {
      Get.snackbar(
        'Gagal',
        result.error!,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    // Jika berhasil (ada kode kelas)
    if (result.classCode != null) {
      _showSuccessDialog(result.classCode!);
    }
  }

  /// Dialog yang menampilkan kode kelas setelah berhasil dibuat.
  void _showSuccessDialog(String classCode) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(AppStrings.createClassSuccessTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ikon sukses
            Icon(
              Icons.check_circle_rounded,
              color: AppColors.success,
              size: 48.sp,
            ),

            SizedBox(height: 16.h),

            Text(
              AppStrings.createClassCodeLabel,
              style: AppStyles.bodyM.copyWith(color: AppColors.textSecondary),
            ),

            SizedBox(height: 8.h),

            // Kode kelas dengan tombol copy
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
              child: Text(
                classCode,
                style: AppStyles.headingL.copyWith(
                  color: AppColors.primary,
                  letterSpacing: 4,
                ),
              ),
            ),

            SizedBox(height: 12.h),

            // Tombol copy
            TextButton.icon(
              onPressed: () {
                // Copy ke clipboard
                Clipboard.setData(ClipboardData(text: classCode));
                Get.snackbar(
                  'Disalin!',
                  AppStrings.createClassCodeCopied,
                  backgroundColor: AppColors.success,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 2),
                );
              },
              icon: Icon(Icons.copy_rounded, size: 16.sp),
              label: const Text(AppStrings.createClassCopyCode),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Get.back(); // Tutup dialog
              Get.back(); // Kembali ke dashboard
            },
            child: const Text('Selesai'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}
