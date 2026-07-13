// preview_imported_questions_screen.dart
// Layar preview soal yang berhasil diimpor dari file Word (.docx).
// Menampilkan daftar soal dalam format read-only setelah tersimpan di database.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/assignment_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../models/question_model.dart';

class PreviewImportedQuestionsScreen extends StatelessWidget {
  const PreviewImportedQuestionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>;
    final List<QuestionModel> importedQuestions =
        args['importedQuestions'] as List<QuestionModel>;
    final int failedCount = args['failedCount'] as int? ?? 0;
    final int totalAttempted = importedQuestions.length + failedCount;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Hasil Import Soal'),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // ====== RINGKASAN IMPORT ======
          _buildSummaryCard(importedQuestions.length, failedCount, totalAttempted),

          // ====== DAFTAR SOAL ======
          Expanded(
            child: importedQuestions.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                    itemCount: importedQuestions.length,
                    itemBuilder: (context, index) {
                      return _QuestionPreviewCard(
                        index: index,
                        question: importedQuestions[index],
                      );
                    },
                  ),
          ),

          // ====== TOMBOL KEMBALI ======
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(int successCount, int failedCount, int totalAttempted) {
    return Container(
      margin: EdgeInsets.all(20.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.upload_file_rounded,
                  color: Colors.white,
                  size: 28.sp,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Import Selesai',
                      style: AppStyles.headingS.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '$totalAttempted soal terdeteksi dari dokumen',
                      style: AppStyles.bodyS.copyWith(
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              _buildStatChip(
                icon: Icons.check_circle_rounded,
                label: '$successCount Berhasil',
                color: AppColors.success,
              ),
              SizedBox(width: 10.w),
              if (failedCount > 0)
                _buildStatChip(
                  icon: Icons.error_rounded,
                  label: '$failedCount Gagal',
                  color: AppColors.error,
                ),
            ],
          ),
          if (failedCount > 0) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: Colors.white.withOpacity(0.9), size: 16.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Soal yang gagal mungkin memiliki format yang tidak sesuai aturan. Anda dapat menambahkannya secara manual.',
                      style: AppStyles.bodyS.copyWith(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 11.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16.sp),
          SizedBox(width: 6.w),
          Text(
            label,
            style: AppStyles.labelS.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.quiz_outlined,
            size: 64.sp,
            color: AppColors.textTertiary,
          ),
          SizedBox(height: 16.h),
          Text(
            'Tidak ada soal yang berhasil diimpor',
            style: AppStyles.bodyM.copyWith(color: AppColors.textSecondary),
          ),
          SizedBox(height: 8.h),
          Text(
            'Pastikan format dokumen sesuai dengan aturan penulisan',
            style: AppStyles.bodyS.copyWith(color: AppColors.textTertiary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: PrimaryButton(
        text: 'Kembali ke Pembuatan Soal',
        onPressed: () => Get.back(),
        leadingIcon: Icons.arrow_back_rounded,
      ),
    );
  }
}

/// Kartu preview satu soal (read-only).
class _QuestionPreviewCard extends StatelessWidget {
  final int index;
  final QuestionModel question;

  const _QuestionPreviewCard({
    required this.index,
    required this.question,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Nomor soal
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'Soal ${index + 1}',
                  style: AppStyles.labelS.copyWith(color: Colors.white),
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_rounded,
                        color: AppColors.success, size: 14.sp),
                    SizedBox(width: 4.w),
                    Text(
                      'Tersimpan',
                      style: AppStyles.labelS.copyWith(
                        color: AppColors.success,
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Teks pertanyaan
          Text(
            question.questionText,
            style: AppStyles.bodyM.copyWith(fontWeight: FontWeight.w500),
          ),

          SizedBox(height: 12.h),

          // Pilihan A-D
          ...['A', 'B', 'C', 'D'].map((letter) {
            final isCorrect = question.correctAnswer == letter;
            final optionText = question.getOptionText(letter);

            return Container(
              margin: EdgeInsets.only(bottom: 6.h),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: isCorrect
                    ? AppColors.successLight
                    : AppColors.surfaceSecondary,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: isCorrect ? AppColors.success : AppColors.border,
                  width: isCorrect ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28.w,
                    height: 28.h,
                    decoration: BoxDecoration(
                      color: isCorrect ? AppColors.success : AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Center(
                      child: isCorrect
                          ? Icon(Icons.check_rounded,
                              color: Colors.white, size: 16.sp)
                          : Text(
                              letter,
                              style: AppStyles.labelS.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      optionText,
                      style: AppStyles.bodyM.copyWith(
                        color: isCorrect
                            ? AppColors.success
                            : AppColors.textPrimary,
                        fontWeight:
                            isCorrect ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
