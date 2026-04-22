// create_assignment_screen.dart
// Step 1 dari pembuatan tugas: isi info tugas (judul, deskripsi, deadline, durasi).

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/assignment_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_textfield.dart';
import '../../../core/widgets/loading_overlay.dart';

class CreateAssignmentScreen extends StatelessWidget {
  const CreateAssignmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AssignmentController controller = Get.find<AssignmentController>();
    final args = Get.arguments as Map<String, dynamic>;
    final String classId = args['classId'] ?? '';
    final String teacherId = args['teacherId'] ?? '';

    return Obx(
      () => LoadingOverlay(
        isLoading: controller.isLoading.value,
        message: 'Menyimpan tugas...',
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(AppStrings.createAssignmentTitle),
            backgroundColor: AppColors.background,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Form(
              key: controller.assignmentFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step indicator
                  _buildStepIndicator(1),

                  SizedBox(height: 24.h),

                  // Judul Tugas
                  CustomTextField(
                    label: AppStrings.assignmentTitle,
                    hint: AppStrings.assignmentTitleHint,
                    controller: controller.titleController,
                    validator: Validators.required,
                    prefixIcon: Icon(Icons.title_rounded,
                        color: AppColors.textSecondary, size: 20.sp),
                    textInputAction: TextInputAction.next,
                  ),

                  SizedBox(height: 16.h),

                  // Deskripsi
                  CustomTextField(
                    label: AppStrings.assignmentDescription,
                    hint: AppStrings.assignmentDescriptionHint,
                    controller: controller.descController,
                    validator: Validators.required,
                    maxLines: 3,
                    textInputAction: TextInputAction.next,
                  ),

                  SizedBox(height: 16.h),

                  // Deadline picker
                  _buildDeadlinePicker(context, controller),

                  SizedBox(height: 16.h),

                  // Durasi slider
                  _buildDurationSlider(controller),

                  SizedBox(height: 32.h),

                  // Tombol lanjut ke step 2
                  PrimaryButton(
                    text: AppStrings.assignmentNextButton,
                    onPressed: () =>
                        controller.saveAssignmentInfo(classId, teacherId),
                    isLoading: controller.isLoading.value,
                    leadingIcon: Icons.arrow_forward_rounded,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int step) {
    return Row(
      children: [
        // Step 1
        _StepDot(number: 1, label: 'Info Tugas', isActive: step >= 1),
        Expanded(
          child: Container(
            height: 2,
            color: step >= 2 ? AppColors.primary : AppColors.border,
          ),
        ),
        // Step 2
        _StepDot(number: 2, label: 'Buat Soal', isActive: step >= 2),
      ],
    );
  }

  Widget _buildDeadlinePicker(
      BuildContext context, AssignmentController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.assignmentDeadlineLabel, style: AppStyles.labelL),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: () => controller.pickDeadline(context),
          child: Obx(
            () => Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: AppColors.surfaceSecondary,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_rounded,
                      color: AppColors.textSecondary, size: 20.sp),
                  SizedBox(width: 12.w),
                  Text(
                    controller.selectedDeadline.value != null
                        ? Helpers.formatDateTime(
                            controller.selectedDeadline.value!)
                        : 'Pilih tanggal dan waktu...',
                    style: AppStyles.bodyM.copyWith(
                      color: controller.selectedDeadline.value != null
                          ? AppColors.textPrimary
                          : AppColors.textTertiary,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_drop_down_rounded,
                      color: AppColors.textSecondary),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDurationSlider(AssignmentController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppStrings.assignmentDurationLabel,
                  style: AppStyles.labelL),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  '${controller.durationMinutes.value} menit',
                  style:
                      AppStyles.labelL.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
        Obx(
          () => Slider(
            value: controller.durationMinutes.value.toDouble(),
            min: 10,
            max: 180,
            divisions: 34, // (180-10)/5 = 34
            activeColor: AppColors.primary,
            inactiveColor: AppColors.border,
            onChanged: (value) =>
                controller.durationMinutes.value = value.toInt(),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('10 menit', style: AppStyles.bodyS),
            Text('180 menit', style: AppStyles.bodyS),
          ],
        ),
      ],
    );
  }
}

class _StepDot extends StatelessWidget {
  final int number;
  final String label;
  final bool isActive;

  const _StepDot(
      {required this.number, required this.label, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 32.w,
          height: 32.h,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.border,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$number',
              style: AppStyles.labelL.copyWith(
                color: isActive ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ),
        ),
        SizedBox(height: 4.h),
        Text(label,
            style: AppStyles.bodyS.copyWith(
                color: isActive
                    ? AppColors.primary
                    : AppColors.textSecondary)),
      ],
    );
  }
}
