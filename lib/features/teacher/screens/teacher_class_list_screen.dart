// teacher_class_list_screen.dart
// Halaman untuk menampilkan semua kelas yang dimiliki guru.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/teacher_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_styles.dart';

class TeacherClassListScreen extends StatelessWidget {
  const TeacherClassListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TeacherController controller = Get.find<TeacherController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Semua Kelas Saya'),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
      ),
      body: Obx(() {
        final classes = controller.myClasses;

        if (classes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.class_outlined, size: 64.sp, color: AppColors.textTertiary),
                SizedBox(height: 16.h),
                Text('Belum ada kelas', style: AppStyles.headingS.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(20.w),
          itemCount: classes.length,
          itemBuilder: (context, index) {
            final classData = classes[index];
            return GestureDetector(
              onTap: () => controller.openClassManagement(classData),
              child: Container(
                margin: EdgeInsets.only(bottom: 12.h),
                padding: EdgeInsets.all(16.w),
                decoration: AppStyles.cardDecoration,
                child: Row(
                  children: [
                    Container(
                      width: 48.w,
                      height: 48.h,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(Icons.class_rounded, color: AppColors.primary, size: 24.sp),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(classData.name, style: AppStyles.labelL, maxLines: 1, overflow: TextOverflow.ellipsis),
                          SizedBox(height: 2.h),
                          Row(
                            children: [
                              Icon(Icons.people_outlined, size: 14.sp, color: AppColors.textSecondary),
                              SizedBox(width: 4.w),
                              Text('${classData.totalStudents} siswa', style: AppStyles.bodyS),
                              SizedBox(width: 8.w),
                              Flexible(
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight,
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                  child: Text(
                                    classData.classCode,
                                    style: AppStyles.labelS.copyWith(color: AppColors.primary, fontFamily: 'monospace'),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded, size: 14.sp, color: AppColors.textTertiary),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
