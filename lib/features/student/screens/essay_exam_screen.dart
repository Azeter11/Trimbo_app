// essay_exam_screen.dart
// Halaman untuk mengerjakan tugas essay, melihat soal dalam satu halaman,
// dan mengunggah file jawaban berupa PDF.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/essay_exam_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/loading_overlay.dart';

class EssayExamScreen extends StatelessWidget {
  const EssayExamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final EssayExamController controller = Get.put(EssayExamController());

    return Obx(() {
      if (controller.isLoadingQuestions.value) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }

      return LoadingOverlay(
        isLoading: controller.isSubmitting.value,
        message: 'Mengunggah file dan mengumpulkan jawaban...',
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(controller.assignment.title),
            backgroundColor: AppColors.background,
            elevation: 0,
          ),
          body: Column(
            children: [
              // Konten Soal Essay
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Soal Essay',
                        style: AppStyles.headingM,
                      ),
                      SizedBox(height: 16.h),
                      
                      // List Soal
                      if (controller.questions.isEmpty)
                        const Text('Tidak ada soal essay yang tersedia.')
                      else
                        ...controller.questions.map((q) => Padding(
                              padding: EdgeInsets.only(bottom: 16.h),
                              child: Container(
                                padding: EdgeInsets.all(16.w),
                                decoration: AppStyles.cardDecorationLight,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Soal ${q.orderNumber}',
                                      style: AppStyles.labelS.copyWith(color: AppColors.primary),
                                    ),
                                    SizedBox(height: 8.h),
                                    Text(
                                      q.questionText,
                                      style: AppStyles.bodyM,
                                    ),
                                    if (q.imageUrl != null) ...[
                                      SizedBox(height: 12.h),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8.r),
                                        child: Image.network(
                                          q.imageUrl!,
                                          width: double.infinity,
                                          fit: BoxFit.contain,
                                          loadingBuilder: (context, child, loadingProgress) {
                                            if (loadingProgress == null) return child;
                                            return Container(
                                              height: 150.h,
                                              width: double.infinity,
                                              color: AppColors.background,
                                              child: const Center(child: CircularProgressIndicator()),
                                            );
                                          },
                                          errorBuilder: (context, error, stackTrace) => Container(
                                            height: 150.h,
                                            width: double.infinity,
                                            color: AppColors.background,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.broken_image_rounded, color: AppColors.textTertiary, size: 30.sp),
                                                SizedBox(height: 4.h),
                                                Text('Gagal memuat gambar', style: AppStyles.bodyS.copyWith(color: AppColors.textTertiary)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            )),
                            
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),

              // Bagian Bawah: Upload PDF dan Kumpulkan
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Upload Jawaban (PDF)',
                      style: AppStyles.headingS,
                    ),
                    SizedBox(height: 12.h),

                    // Area pilih file
                    if (controller.selectedPdfFile.value == null)
                      GestureDetector(
                        onTap: controller.pickPdfFile,
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 24.h),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.primary, style: BorderStyle.solid),
                            borderRadius: BorderRadius.circular(12.r),
                            color: AppColors.primaryLight,
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.upload_file_rounded, size: 32.sp, color: AppColors.primary),
                              SizedBox(height: 8.h),
                              Text(
                                'Pilih File PDF',
                                style: AppStyles.labelL.copyWith(color: AppColors.primary),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(12.r),
                          color: AppColors.surfaceSecondary,
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.picture_as_pdf_rounded, color: Colors.red, size: 28.sp),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                controller.pdfFileName.value,
                                style: AppStyles.bodyM,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded),
                              onPressed: controller.clearSelectedFile,
                            ),
                          ],
                        ),
                      ),
                      
                    SizedBox(height: 24.h),

                    // Tombol Kumpulkan
                    PrimaryButton(
                      text: 'Kumpulkan Jawaban',
                      onPressed: controller.selectedPdfFile.value != null 
                          ? controller.showSubmitConfirmation 
                          : null, // Disable jika belum pilih file
                      backgroundColor: controller.selectedPdfFile.value != null 
                          ? AppColors.primary 
                          : AppColors.border,
                      leadingIcon: Icons.send_rounded,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
