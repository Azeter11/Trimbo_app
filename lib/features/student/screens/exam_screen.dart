// exam_screen.dart
// Halaman ujian fullscreen — FITUR UTAMA EduTask.
// Termasuk: timer, navigasi soal, anti-cheat, auto-submit.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/exam_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/loading_overlay.dart';

class ExamScreen extends StatelessWidget {
  const ExamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ExamController controller = Get.put(ExamController());

    return Obx(() {
      // Tampilkan loading saat soal sedang diambil dari Firestore
      if (controller.isLoadingQuestions.value) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }

      // Tampilkan halaman persiapan sebelum ujian dimulai
      if (!controller.examStarted.value) {
        return _PreparationPage(controller: controller);
      }

      // Tampilkan halaman ujian aktif
      return _ExamPage(controller: controller);
    });
  }
}

// ========================
// HALAMAN PERSIAPAN
// ========================

/// Halaman info sebelum ujian dimulai.
class _PreparationPage extends StatelessWidget {
  final ExamController controller;

  const _PreparationPage({required this.controller});

  @override
  Widget build(BuildContext context) {
    final assignment = controller.assignment;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Persiapan Ujian'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ====== INFO TUGAS ======
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: AppStyles.cardDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(assignment.title, style: AppStyles.headingM),

                  SizedBox(height: 8.h),

                  Text(
                    assignment.description,
                    style: AppStyles.bodyM.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Info grid: jumlah soal dan durasi
                  Row(
                    children: [
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.quiz_rounded,
                          label: 'Jumlah Soal',
                          value: '${controller.questions.length} soal',
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.timer_rounded,
                          label: 'Durasi',
                          value: '${assignment.durationMinutes} menit',
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // ====== INSTRUKSI ======
            Text('Instruksi Ujian', style: AppStyles.headingS),

            SizedBox(height: 12.h),

            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.warningLight,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.warning.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  _InstructionItem(
                    icon: Icons.wifi_rounded,
                    text: 'Pastikan koneksi internet stabil',
                  ),
                  _InstructionItem(
                    icon: Icons.fullscreen_rounded,
                    text: 'Jangan keluar dari aplikasi saat ujian',
                  ),
                  _InstructionItem(
                    icon: Icons.timer_rounded,
                    text: 'Waktu terus berjalan meski keluar layar',
                  ),
                  _InstructionItem(
                    icon: Icons.warning_rounded,
                    text: 'Keluar 3x → jawaban dikumpulkan otomatis',
                  ),
                  _InstructionItem(
                    icon: Icons.save_rounded,
                    text: 'Jawaban tersimpan otomatis saat berpindah soal',
                  ),
                ],
              ),
            ),

            SizedBox(height: 32.h),

            // ====== TOMBOL MULAI ======
            PrimaryButton(
              text: AppStrings.examStartButton,
              onPressed: controller.startExam,
              leadingIcon: Icons.play_arrow_rounded,
            ),

            SizedBox(height: 12.h),

            // Peringatan tidak bisa pause
            Center(
              child: Text(
                'Setelah mulai, ujian tidak dapat di-pause',
                style: AppStyles.bodyS.copyWith(color: AppColors.textTertiary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ========================
// HALAMAN UJIAN AKTIF
// ========================

/// Halaman ujian fullscreen dengan soal dan timer.
class _ExamPage extends StatelessWidget {
  final ExamController controller;

  const _ExamPage({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        if (controller.questions.isEmpty) {
          return const Center(
            child: Text('Tidak ada soal yang tersedia'),
          );
        }

        final currentIndex = controller.currentQuestionIndex.value;
        final currentQuestion = controller.questions[currentIndex];
        final questionNumber = currentIndex + 1;
        final totalQuestions = controller.questions.length;
        final isLastQuestion = currentIndex == totalQuestions - 1;

        return LoadingOverlay(
          isLoading: controller.isSubmitting.value,
          message: 'Mengumpulkan jawaban...',
          child: SafeArea(
            child: Column(
              children: [
                // ====== APP BAR CUSTOM ======
                _buildTopBar(questionNumber, totalQuestions, controller),

                // ====== KONTEN SOAL ======
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nomor soal
                        Text(
                          'Soal $questionNumber dari $totalQuestions',
                          style: AppStyles.labelS.copyWith(
                            color: AppColors.primary,
                          ),
                        ),

                        SizedBox(height: 16.h),

                        // Teks pertanyaan
                        Text(
                          currentQuestion.questionText,
                          style: AppStyles.questionText,
                        ),

                        SizedBox(height: 24.h),

                        // Pilihan jawaban A, B, C, D
                        ...['A', 'B', 'C', 'D'].map((option) {
                          final optionText = currentQuestion.getOptionText(option);
                          final isSelected = controller.getSelectedAnswer(questionNumber) == option;

                          return _buildAnswerCard(
                            option: option,
                            text: optionText,
                            isSelected: isSelected,
                            onTap: () => controller.selectAnswer(questionNumber, option),
                          );
                        }),

                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                ),

                // ====== NAVIGASI BAWAH ======
                _buildBottomNavigation(
                  controller: controller,
                  currentIndex: currentIndex,
                  totalQuestions: totalQuestions,
                  isLastQuestion: isLastQuestion,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  /// AppBar kustom dengan nomor soal dan timer.
  Widget _buildTopBar(int current, int total, ExamController controller) {
    return Obx(() {
      final isWarning = controller.isTimerWarning;

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Nomor soal
            Text(
              '$current/$total',
              style: AppStyles.headingS,
            ),

            const Spacer(),

            // Timer
            Row(
              children: [
                Icon(
                  Icons.timer_rounded,
                  size: 18.sp,
                  color: isWarning ? AppColors.error : AppColors.textSecondary,
                ),
                SizedBox(width: 4.w),
                Text(
                  controller.formattedTime,
                  // Warna merah jika kurang dari 1 menit
                  style: isWarning
                      ? AppStyles.timerWarning
                      : AppStyles.timerNormal,
                ),
              ],
            ),

            SizedBox(width: 16.w),

            // Indikator jumlah peringatan
            if (controller.warningCount.value > 0)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.errorLight,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  '⚠️ ${controller.warningCount.value}/3',
                  style: AppStyles.labelS.copyWith(color: AppColors.error),
                ),
              ),
          ],
        ),
      );
    });
  }

  /// Card pilihan jawaban (A, B, C, atau D).
  Widget _buildAnswerCard({
    required String option,
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  )
                ],
        ),
        child: Row(
          children: [
            // Huruf pilihan
            Container(
              width: 36.w,
              height: 36.h,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  option,
                  style: AppStyles.headingS.copyWith(
                    color: isSelected ? Colors.white : AppColors.primary,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),

            SizedBox(width: 12.w),

            // Teks pilihan
            Expanded(
              child: Text(
                text,
                style: AppStyles.answerText.copyWith(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),

            // Ikon centang jika dipilih
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 20.sp,
              ),
          ],
        ),
      ),
    );
  }

  /// Navigasi bawah: dot indicator + tombol sebelumnya/berikutnya/selesai.
  Widget _buildBottomNavigation({
    required ExamController controller,
    required int currentIndex,
    required int totalQuestions,
    required bool isLastQuestion,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ====== DOT INDICATOR ======
          _buildDotIndicator(controller, totalQuestions, currentIndex),

          SizedBox(height: 16.h),

          // ====== TOMBOL NAVIGASI ======
          Row(
            children: [
              // Tombol Sebelumnya
              if (currentIndex > 0) ...[
                Expanded(
                  child: OutlineButton(
                    text: AppStrings.examPrev,
                    onPressed: controller.previousQuestion,
                    height: 44.h,
                    leadingIcon: Icons.arrow_back_rounded,
                  ),
                ),
                SizedBox(width: 12.w),
              ],

              // Tombol Berikutnya atau Selesai
              Expanded(
                child: isLastQuestion
                    ? PrimaryButton(
                        text: AppStrings.examFinish,
                        onPressed: controller.showSubmitConfirmation,
                        height: 44.h,
                        backgroundColor: AppColors.success,
                        leadingIcon: Icons.check_rounded,
                      )
                    : PrimaryButton(
                        text: AppStrings.examNext,
                        onPressed: controller.nextQuestion,
                        height: 44.h,
                        leadingIcon: Icons.arrow_forward_rounded,
                      ),
              ),
            ],
          ),

          // Tombol selesai lebih awal (bukan di soal terakhir)
          if (!isLastQuestion) ...[
            SizedBox(height: 8.h),
            TextLinkButton(
              text: AppStrings.examSubmitEarly,
              onPressed: controller.showSubmitConfirmation,
              color: AppColors.textSecondary,
            ),
          ],
        ],
      ),
    );
  }

  /// Dot indicator menunjukkan soal yang sudah dijawab (•) dan belum (○).
  Widget _buildDotIndicator(
    ExamController controller,
    int total,
    int current,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(total, (index) {
          final questionNumber = index + 1;
          final isAnswered = controller.isAnswered(questionNumber);
          final isCurrent = index == current;

          return GestureDetector(
            onTap: () => controller.goToQuestion(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.symmetric(horizontal: 3.w),
              width: isCurrent ? 24.w : 10.w,
              height: 10.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.r),
                color: isCurrent
                    ? AppColors.primary
                    : isAnswered
                        ? AppColors.success
                        : AppColors.border,
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ========================
// HELPER WIDGETS
// ========================

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24.sp),
          SizedBox(height: 8.h),
          Text(label, style: AppStyles.bodyS),
          SizedBox(height: 4.h),
          Text(value, style: AppStyles.labelL.copyWith(color: color)),
        ],
      ),
    );
  }
}

class _InstructionItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InstructionItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18.sp, color: AppColors.warning),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              text,
              style: AppStyles.bodyM.copyWith(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
