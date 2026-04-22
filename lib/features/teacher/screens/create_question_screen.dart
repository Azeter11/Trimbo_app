// create_question_screen.dart
// Halaman untuk membuat soal-soal ujian (step 2 dari pembuatan tugas).
// Fitur: list soal yang sudah dibuat, form tambah soal, pilih jawaban benar.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/assignment_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_textfield.dart';
import '../../../core/widgets/loading_overlay.dart';

class CreateQuestionScreen extends StatelessWidget {
  const CreateQuestionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AssignmentController controller = Get.find<AssignmentController>();

    return Obx(
      () => LoadingOverlay(
        isLoading: controller.isLoading.value,
        message: 'Menyimpan soal...',
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(AppStrings.createQuestionTitle),
            backgroundColor: AppColors.background,
            elevation: 0,
          ),
          body: Column(
            children: [
              // ====== LIST SOAL (scrollable) ======
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header info
                      _buildHeader(controller),

                      SizedBox(height: 20.h),

                      // List soal yang sudah dibuat
                      if (controller.questions.isNotEmpty) ...[
                        Text(
                          '${AppStrings.questionsList} (${controller.questions.length})',
                          style: AppStyles.headingS,
                        ),
                        SizedBox(height: 12.h),
                        ...controller.questions.asMap().entries.map(
                          (entry) => _QuestionCard(
                            index: entry.key,
                            question: entry.value,
                            onDelete: () =>
                                controller.deleteQuestion(entry.key),
                          ),
                        ),
                        SizedBox(height: 20.h),
                      ],

                      // Form tambah soal
                      _buildAddQuestionForm(controller),

                      SizedBox(height: 80.h),
                    ],
                  ),
                ),
              ),

              // ====== TOMBOL TERBITKAN (di bawah) ======
              _buildBottomBar(controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AssignmentController controller) {
    final assignment = controller.currentAssignment.value;
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(Icons.assignment_rounded, color: AppColors.primary, size: 24.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assignment?.title ?? '',
                  style: AppStyles.labelL.copyWith(color: AppColors.primary),
                ),
                Text(
                  '${controller.questions.length} soal ditambahkan',
                  style: AppStyles.bodyS.copyWith(color: AppColors.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddQuestionForm(AssignmentController controller) {
    return Form(
      key: controller.questionFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header form
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'Soal ${controller.questions.length + 1}',
                  style: AppStyles.labelS.copyWith(color: Colors.white),
                ),
              ),
              SizedBox(width: 10.w),
              Text(AppStrings.addQuestion, style: AppStyles.headingS),
            ],
          ),

          SizedBox(height: 16.h),

          // Teks pertanyaan
          CustomTextField(
            label: AppStrings.questionText,
            hint: AppStrings.questionTextHint,
            controller: controller.questionTextController,
            validator: Validators.required,
            maxLines: 4,
            textInputAction: TextInputAction.next,
          ),

          SizedBox(height: 16.h),

          // 4 pilihan jawaban
          ...[
            ('A', controller.optionAController, AppStrings.optionA),
            ('B', controller.optionBController, AppStrings.optionB),
            ('C', controller.optionCController, AppStrings.optionC),
            ('D', controller.optionDController, AppStrings.optionD),
          ].map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Row(
                children: [
                  // Badge huruf pilihan
                  Container(
                    width: 36.w,
                    height: 36.h,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Center(
                      child: Text(
                        item.$1,
                        style: AppStyles.labelL.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: CustomTextField(
                      label: item.$3,
                      hint: 'Masukkan pilihan ${item.$1}',
                      controller: item.$2,
                      validator: Validators.required,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // Pilih jawaban benar
          Text(AppStrings.correctAnswer, style: AppStyles.labelL),

          SizedBox(height: 8.h),

          Obx(
            () => Row(
              children: ['A', 'B', 'C', 'D'].map((option) {
                final isSelected =
                    controller.selectedCorrectAnswer.value == option;
                return Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        controller.selectedCorrectAnswer.value = option,
                    child: Container(
                      margin: EdgeInsets.only(
                        right: option != 'D' ? 8.w : 0,
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            option,
                            style: AppStyles.labelL.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                          if (isSelected)
                            Icon(Icons.check_rounded,
                                size: 14.sp, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          SizedBox(height: 20.h),

          // Tombol simpan soal
          PrimaryButton(
            text: AppStrings.saveQuestion,
            onPressed: controller.addQuestion,
            leadingIcon: Icons.add_rounded,
            isLoading: controller.isLoading.value,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(AssignmentController controller) {
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
      child: Obx(
        () => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Info jumlah soal
            Text(
              '${controller.questions.length} soal siap diterbitkan',
              style: AppStyles.bodyM.copyWith(color: AppColors.textSecondary),
            ),
            SizedBox(height: 10.h),
            PrimaryButton(
              text: AppStrings.assignmentPublishButton,
              onPressed: controller.publishAssignment,
              isLoading: controller.isLoading.value,
              backgroundColor: AppColors.success,
              leadingIcon: Icons.publish_rounded,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final int index;
  final dynamic question;
  final VoidCallback onDelete;

  const _QuestionCard({
    required this.index,
    required this.question,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.w),
      decoration: AppStyles.cardDecorationLight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nomor soal
          Container(
            width: 28.w,
            height: 28.h,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: AppStyles.labelS.copyWith(color: AppColors.primary),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question.questionText.length > 60
                      ? '${question.questionText.substring(0, 60)}...'
                      : question.questionText,
                  style: AppStyles.bodyM,
                ),
                SizedBox(height: 4.h),
                Text(
                  'Jawaban: ${question.correctAnswer}',
                  style: AppStyles.bodyS.copyWith(color: AppColors.success),
                ),
              ],
            ),
          ),
          // Tombol hapus
          GestureDetector(
            onTap: onDelete,
            child: Icon(
              Icons.delete_outline_rounded,
              color: AppColors.error,
              size: 20.sp,
            ),
          ),
        ],
      ),
    );
  }
}
