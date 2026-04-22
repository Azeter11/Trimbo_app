// student_grades_screen.dart
// Halaman laporan nilai siswa per tugas, untuk guru.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/teacher_controller.dart';
import '../../student/models/assignment_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_styles.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../services/export_service.dart';

class StudentGradesScreen extends StatelessWidget {
  const StudentGradesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TeacherController controller = Get.find<TeacherController>();
    final AssignmentModel assignment = Get.arguments as AssignmentModel;

    // Muat nilai saat halaman dibuka
    controller.loadAssignmentSubmissions(assignment.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.studentGradesTitle),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final submissions = controller.assignmentSubmissions;

        return SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info tugas
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: AppStyles.cardDecorationLight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      assignment.title,
                      style: AppStyles.headingS,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Deadline: ${Helpers.formatDateTime(assignment.deadline)}',
                      style: AppStyles.bodyS,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // Summary rata-rata
              if (submissions.isNotEmpty) ...[
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            Helpers.formatScore(
                              Helpers.calculateAverage(
                                  submissions.map((s) => s.score).toList()),
                            ),
                            style: AppStyles.headingL
                                .copyWith(color: AppColors.primary),
                          ),
                          Text(AppStrings.classAverage, style: AppStyles.bodyS),
                        ],
                      ),
                      Container(
                          width: 1, height: 40.h, color: AppColors.border),
                      Column(
                        children: [
                          Text(
                            '${submissions.length}',
                            style: AppStyles.headingL
                                .copyWith(color: AppColors.primary),
                          ),
                          Text('Pengumpulan', style: AppStyles.bodyS),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
              ],

              // Tombol export
              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      text: 'Export PDF',
                      height: 44.h,
                      fontSize: 12.sp,
                      onPressed: () async {
                        final exportService = ExportService();
                        final error = await exportService.exportToPdf(
                          submissions: submissions,
                          assignmentTitle: assignment.title,
                          className: 'ID Kelas: ${assignment.classId}',
                        );
                        if (error != null) {
                          Get.snackbar('Error', error,
                              backgroundColor: AppColors.error,
                              colorText: Colors.white);
                        }
                      },
                      backgroundColor: AppColors.error,
                      leadingIcon: Icons.picture_as_pdf_rounded,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: PrimaryButton(
                      text: 'Export Excel',
                      height: 44.h,
                      fontSize: 12.sp,
                      onPressed: () async {
                        final exportService = ExportService();
                        final error = await exportService.exportToExcel(
                          submissions: submissions,
                          assignmentTitle: assignment.title,
                          className: 'ID Kelas: ${assignment.classId}',
                        );
                        if (error != null) {
                          Get.snackbar('Error', error,
                              backgroundColor: AppColors.error,
                              colorText: Colors.white);
                        }
                      },
                      backgroundColor: AppColors.success,
                      leadingIcon: Icons.table_chart_rounded,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20.h),

              // Tabel nilai
              if (submissions.isEmpty)
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.w),
                    child: Column(
                      children: [
                        Icon(Icons.inbox_outlined,
                            size: 48.sp, color: AppColors.textTertiary),
                        SizedBox(height: 12.h),
                        Text('Belum ada siswa yang mengumpulkan',
                            style: AppStyles.bodyM
                                .copyWith(color: AppColors.textSecondary),
                            textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                )
              else ...[
                Text('Nilai Siswa', style: AppStyles.headingS),
                SizedBox(height: 12.h),

                // Header tabel
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: 36.w),
                      Expanded(
                        child: Text('Nama',
                            style:
                                AppStyles.labelS.copyWith(color: Colors.white)),
                      ),
                      SizedBox(
                        width: 44.w,
                        child: Text('Nilai',
                            style:
                                AppStyles.labelS.copyWith(color: Colors.white),
                            textAlign: TextAlign.center),
                      ),
                      SizedBox(
                        width: 48.w,
                        child: Text('Grade',
                            style:
                                AppStyles.labelS.copyWith(color: Colors.white),
                            textAlign: TextAlign.center),
                      ),
                    ],
                  ),
                ),

                // Baris data
                ...submissions.asMap().entries.map((entry) {
                  final i = entry.key;
                  final s = entry.value;
                  final scoreColor = AppColors.gradeColor(s.score);

                  return Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: i.isEven
                          ? AppColors.cardBackground
                          : AppColors.surfaceSecondary,
                      borderRadius: i == submissions.length - 1
                          ? BorderRadius.only(
                              bottomLeft: Radius.circular(8.r),
                              bottomRight: Radius.circular(8.r),
                            )
                          : null,
                    ),
                    child: Row(
                      children: [
                        // Nomor urut
                        SizedBox(
                          width: 36.w,
                          child: Text(
                            '${i + 1}',
                            style: AppStyles.bodyS,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        // Nama siswa
                        Expanded(
                          child: Text(s.studentName,
                              style: AppStyles.bodyM,
                              overflow: TextOverflow.ellipsis),
                        ),
                        // Nilai
                        SizedBox(
                          width: 44.w,
                          child: Text(
                            s.score.toStringAsFixed(1),
                            style: AppStyles.labelL.copyWith(color: scoreColor),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        // Grade
                        SizedBox(
                          width: 48.w,
                          child: Center(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 6.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: scoreColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                s.grade,
                                style: AppStyles.labelS
                                    .copyWith(color: scoreColor),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],

              SizedBox(height: 32.h),
            ],
          ),
        );
      }),
    );
  }
}
