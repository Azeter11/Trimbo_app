// class_detail_screen.dart
// Halaman detail kelas yang diikuti siswa.
// Tab 1: Daftar tugas dengan status. Tab 2: Info kelas.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/student_controller.dart';
import '../../student/models/class_model.dart';
import '../../student/models/assignment_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_styles.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/widgets/loading_overlay.dart';

class ClassDetailScreen extends StatefulWidget {
  const ClassDetailScreen({super.key});

  @override
  State<ClassDetailScreen> createState() => _ClassDetailScreenState();
}

class _ClassDetailScreenState extends State<ClassDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<AssignmentModel> _assignments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAssignments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAssignments() async {
    final StudentController controller = Get.find<StudentController>();

    // Gunakan arguments atau fallback ke selectedClass dari controller
    final ClassModel? classData = Get.arguments is ClassModel
        ? Get.arguments as ClassModel
        : controller.selectedClass.value;

    if (classData == null) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      return;
    }

    final assignments = await controller.getClassAssignments(classData.id);
    if (mounted) {
      setState(() {
        _assignments = assignments;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final StudentController controller = Get.find<StudentController>();

    // Gunakan arguments atau fallback ke selectedClass dari controller
    final ClassModel? initialClassData = Get.arguments is ClassModel
        ? Get.arguments as ClassModel
        : controller.selectedClass.value;

    // Jika data tidak ada (akibat bug navigasi atau hot restart), tampilkan error placeholder
    if (initialClassData == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detail Kelas'),
          backgroundColor: AppColors.primary,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded,
                  size: 64.sp, color: AppColors.error),
              SizedBox(height: 16.h),
              const Text('Data kelas tidak ditemukan'),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: () => Get.back(),
                child: const Text('Kembali'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() => LoadingOverlay(
        isLoading: controller.isLoading.value,
        message: 'Sedang memproses...',
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            // ====== SLIVER APP BAR ======
            SliverAppBar(
              expandedHeight: 160.h,
              pinned: true,
              backgroundColor: AppColors.primary,
              iconTheme: const IconThemeData(color: Colors.white),
              flexibleSpace: FlexibleSpaceBar(
                background: Obx(() {
                  final classData = controller.selectedClass.value ?? initialClassData;
                  return Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.primary, AppColors.secondary],
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(24.w, 80.h, 24.w, 20.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            classData.name,
                            style: AppStyles.headingM.copyWith(color: Colors.white),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Oleh ${classData.teacherName}',
                            style: AppStyles.bodyM.copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
                labelStyle: AppStyles.labelL.copyWith(fontSize: 13.sp),
                tabs: const [
                  Tab(text: 'Daftar Tugas'),
                  Tab(text: 'Info Kelas'),
                ],
              ),
            ),
          ],
  
          // ====== BODY (TAB VIEWS) ======
          body: TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: Daftar Tugas
              _buildAssignmentsTab(controller),
  
              // Tab 2: Info Kelas
              _buildInfoTab(controller, initialClassData),
            ],
          ),
        ),
      )),
    );
  }

  /// Tab daftar tugas dengan status pengerjaan.
  Widget _buildAssignmentsTab(StudentController controller) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_assignments.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.assignment_outlined,
                  size: 64.sp, color: AppColors.textTertiary),
              SizedBox(height: 16.h),
              Text(
                AppStrings.noAssignmentsYet,
                style: AppStyles.bodyM.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAssignments,
      color: AppColors.primary,
      child: Obx(() {
        // Trigger rebuild saat ada perubahan nilai/submission di controller
        final _ = controller.mySubmissions.length;
        
        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: _assignments.length,
          itemBuilder: (context, index) {
            final assignment = _assignments[index];
            final hasSubmitted = controller.hasSubmitted(assignment.id);
            final isExpired = assignment.isExpired;

            return _AssignmentCard(
              assignment: assignment,
              hasSubmitted: hasSubmitted,
              isExpired: isExpired,
              onTap: () {
                if (hasSubmitted) {
                  // Sudah dikerjakan → tampilkan nilai
                  final submission = controller.getSubmission(assignment.id);
                  if (submission != null) {
                    Get.snackbar(
                      'Sudah Dikerjakan',
                      'Nilai Anda: ${submission.score.toStringAsFixed(1)} (${submission.grade})',
                      backgroundColor: AppColors.success,
                      colorText: Colors.white,
                    );
                  }
                } else if (isExpired) {
                  // Deadline lewat
                  Get.snackbar(
                    'Waktu Habis',
                    'Batas waktu pengumpulan sudah lewat',
                    backgroundColor: AppColors.error,
                    colorText: Colors.white,
                  );
                } else {
                  // Buka ujian
                  controller.openExam(assignment);
                }
              },
            );
          },
        );
      }),
    );
  }

  /// Tab informasi kelas.
  Widget _buildInfoTab(StudentController controller, ClassModel initialClassData) {
    return Obx(() {
      final classData = controller.selectedClass.value ?? initialClassData;
      return SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Deskripsi kelas
            _InfoSection(
              title: 'Deskripsi',
              content: classData.description,
              icon: Icons.description_outlined,
            ),

            SizedBox(height: 16.h),

            // Kode kelas
            _InfoSection(
              title: AppStrings.classCode,
              content: classData.classCode,
              icon: Icons.vpn_key_rounded,
              isCode: true,
            ),

            SizedBox(height: 16.h),

            // Dibuat oleh
            _InfoSection(
              title: AppStrings.classCreatedBy,
              content: classData.teacherName,
              icon: Icons.person_outlined,
            ),

            SizedBox(height: 16.h),

            // Jumlah siswa
            _InfoSection(
              title: AppStrings.classTotalStudents,
              content: '${classData.totalStudents} siswa',
              icon: Icons.people_outlined,
            ),

            SizedBox(height: 32.h),

            // Tombol Keluar Kelas
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => controller.leaveClass(classData),
                icon: const Icon(Icons.exit_to_app_rounded, color: AppColors.error),
                label: Text(
                  'Keluar Dari Kelas',
                  style: AppStyles.labelL.copyWith(color: AppColors.error),
                ),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  side: const BorderSide(color: AppColors.error),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      );
    });
  }
}

class _AssignmentCard extends StatelessWidget {
  final AssignmentModel assignment;
  final bool hasSubmitted;
  final bool isExpired;
  final VoidCallback onTap;

  const _AssignmentCard({
    required this.assignment,
    required this.hasSubmitted,
    required this.isExpired,
    required this.onTap,
  });

  /// Tentukan warna dan teks status.
  ({Color color, Color bgColor, String text, IconData icon}) get _status {
    if (hasSubmitted) {
      return (
        color: AppColors.success,
        bgColor: AppColors.successLight,
        text: AppStrings.assignmentCompleted,
        icon: Icons.check_circle_rounded,
      );
    }
    if (isExpired) {
      return (
        color: AppColors.textSecondary,
        bgColor: AppColors.surfaceSecondary,
        text: AppStrings.assignmentExpired,
        icon: Icons.cancel_rounded,
      );
    }
    return (
      color: AppColors.error,
      bgColor: AppColors.errorLight,
      text: AppStrings.assignmentNotStarted,
      icon: Icons.radio_button_unchecked_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = _status;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: AppStyles.cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    assignment.title,
                    style: AppStyles.headingS,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Badge status
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: status.bgColor,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(status.icon, size: 12.sp, color: status.color),
                      SizedBox(width: 4.w),
                      Text(
                        status.text,
                        style: AppStyles.labelS.copyWith(color: status.color),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 10.h),

            // Info baris bawah
            Row(
              children: [
                Icon(Icons.timer_outlined,
                    size: 14.sp, color: AppColors.textSecondary),
                SizedBox(width: 4.w),
                Text('${assignment.durationMinutes} mnt',
                    style: AppStyles.bodyS),
                SizedBox(width: 10.w),
                Icon(Icons.quiz_outlined,
                    size: 14.sp, color: AppColors.textSecondary),
                SizedBox(width: 4.w),
                Text('${assignment.totalQuestions} soal',
                    style: AppStyles.bodyS),
                const Spacer(),
                // Deadline
                Flexible(
                  child: Text(
                    Helpers.getTimeRemaining(assignment.deadline),
                    style: AppStyles.bodyS.copyWith(
                      color: Helpers.isDeadlineNear(assignment.deadline)
                          ? AppColors.warning
                          : AppColors.textSecondary,
                      fontWeight: Helpers.isDeadlineNear(assignment.deadline)
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;
  final bool isCode;

  const _InfoSection({
    required this.title,
    required this.content,
    required this.icon,
    this.isCode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: AppStyles.cardDecorationLight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, size: 18.sp, color: AppColors.primary),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppStyles.labelS),
                SizedBox(height: 4.h),
                Text(
                  content,
                  style: isCode
                      ? AppStyles.headingS.copyWith(
                          color: AppColors.primary,
                          letterSpacing: 3,
                        )
                      : AppStyles.bodyM,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
