// student_dashboard_screen.dart
// Dashboard utama untuk siswa: sapaan, shortcut kelas/tugas/nilai, deadline mendekat.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../controllers/student_controller.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_styles.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/widgets/loading_overlay.dart';
import '../../../app/routes.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  // Test Banner Ad Unit ID (Safe untuk Development & Testing)
  final String _adUnitId = 'ca-app-pub-3940256099942544/9214589741';

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: _adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('Ad failed to load: $error');
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final StudentController controller = Get.put(StudentController());
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() => RefreshIndicator(
        onRefresh: controller.loadDashboardData,
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            // ====== HEADER ======
            SliverToBoxAdapter(
              child: _buildHeader(authController, controller),
            ),

            // ====== SHORTCUT CARDS ======
            SliverToBoxAdapter(
              child: _buildShortcutCards(controller),
            ),

            // ====== DEADLINE MENDEKAT ======
            SliverToBoxAdapter(
              child: _buildUpcomingDeadlines(controller),
            ),

            // ====== KELAS SAYA ======
            SliverToBoxAdapter(
              child: _buildMyClasses(controller),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 80.h)),
          ],
        ),
      )),

      // FAB untuk join kelas
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.joinClass),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'Gabung Kelas',
          style: AppStyles.buttonText.copyWith(fontSize: 13.sp),
        ),
      ),
      bottomNavigationBar: _isAdLoaded && _bannerAd != null
          ? SafeArea(
              child: Container(
                width: double.infinity,
                height: _bannerAd!.size.height.toDouble(),
                alignment: Alignment.center,
                child: AdWidget(ad: _bannerAd!),
              ),
            )
          : null,
    );
  }

  /// Widget header dengan sapaan, nama siswa, dan foto profil.
  Widget _buildHeader(AuthController auth, StudentController controller) {
    final user = auth.currentUser.value;
    final userName = user?.fullName ?? 'Siswa';
    final initials = user?.initials ?? '?';
    final photoUrl = user?.photoUrl; // Ambil URL foto profil

    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 56.h, 24.w, 32.h),
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.studentDashboardGreeting,
                  style: AppStyles.bodyM.copyWith(color: Colors.white.withOpacity(0.8)),
                ),
                SizedBox(height: 4.h),
                Text(
                  userName.split(' ').first, // Tampilkan nama depan saja
                  style: AppStyles.headingL.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 26.sp,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6.h),
                Text(
                  AppStrings.studentDashboardSubtitle,
                  style: AppStyles.bodyS.copyWith(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          ),

          // ======== BAGIAN AVATAR DI DASHBOARD ========
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.studentProfile),
            child: Container(
              width: 52.w,
              height: 52.h,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryDark.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              // Cek apakah user sudah punya foto profil
              child: (photoUrl != null && photoUrl.isNotEmpty)
                  ? ClipOval(
                child: Image.network(
                  photoUrl,
                  fit: BoxFit.cover,
                  width: 52.w,
                  height: 52.h,
                  // Jika gambar gagal dimuat, kembalikan ke inisial nama
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Text(
                        initials,
                        style: AppStyles.headingS.copyWith(
                          color: Colors.white,
                          fontSize: 20.sp,
                        ),
                      ),
                    );
                  },
                ),
              )
              // Jika belum ada foto, tampilkan inisial nama
                  : Center(
                child: Text(
                  initials,
                  style: AppStyles.headingS.copyWith(
                    color: Colors.white,
                    fontSize: 20.sp,
                  ),
                ),
              ),
            ),
          ),
          // ======== AKHIR BAGIAN AVATAR ========
        ],
      ),
    );
  }

  /// Widget 3 shortcut card: Kelas, Tugas, Nilai.
  Widget _buildShortcutCards(StudentController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: Row(
        children: [
          // Kelas Saya
          Expanded(
            child: _ShortcutCard(
              icon: Icons.class_rounded,
              label: AppStrings.myClasses,
              value: '${controller.myClasses.length}',
              color: AppColors.primary,
              onTap: () {
                if (controller.myClasses.isNotEmpty) {
                  if (controller.myClasses.length == 1) {
                    controller.openClassDetail(controller.myClasses.first);
                  } else {
                    Get.snackbar(
                      'Pilih Kelas',
                      'Silakan pilih salah satu kelas dari daftar di bawah',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: AppColors.primary,
                      colorText: Colors.white,
                    );
                  }
                } else {
                  Get.toNamed(AppRoutes.joinClass);
                }
              },
            ),
          ),
          SizedBox(width: 12.w),

          // Tugas
          Expanded(
            child: _ShortcutCard(
              icon: Icons.assignment_rounded,
              label: AppStrings.myAssignments,
              value: '${controller.allAssignments.length}',
              color: AppColors.warning,
              onTap: () => Get.toNamed(AppRoutes.assignmentList),
            ),
          ),
          SizedBox(width: 12.w),

          // Nilai
          Expanded(
            child: _ShortcutCard(
              icon: Icons.grade_rounded,
              label: AppStrings.myGrades,
              value: controller.mySubmissions.isEmpty
                  ? '-'
                  : Helpers.formatScore(controller.averageScore),
              color: AppColors.success,
              onTap: () => Get.toNamed(AppRoutes.gradeReport),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget list tugas dengan deadline mendekat (dalam 3 hari).
  Widget _buildUpcomingDeadlines(StudentController controller) {
    final upcoming = controller.upcomingDeadlines;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.alarm_rounded, size: 18.sp, color: AppColors.warning),
              ),
              SizedBox(width: 12.w),
              Text(AppStrings.upcomingDeadlines, style: AppStyles.headingS),
            ],
          ),

          SizedBox(height: 16.h),

          if (upcoming.isEmpty)
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: AppStyles.cardDecorationLight,
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(Icons.check_circle_outline_rounded,
                        color: AppColors.success, size: 20.sp),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      AppStrings.noUpcomingDeadlines,
                      style: AppStyles.bodyM.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            )
          else
            ...upcoming.map((assignment) => _DeadlineCard(
              assignment: assignment,
              onTap: () => controller.openExam(assignment),
            )),

          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  /// Widget list kelas yang diikuti.
  Widget _buildMyClasses(StudentController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8.h),
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.school_rounded, size: 18.sp, color: AppColors.primary),
              ),
              SizedBox(width: 12.w),
              Text('Kelas Saya', style: AppStyles.headingS),
            ],
          ),

          SizedBox(height: 16.h),

          if (controller.myClasses.isEmpty)
            Center(
              child: Column(
                children: [
                  SizedBox(height: 24.h),
                  Container(
                    padding: EdgeInsets.all(24.w),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.class_outlined,
                        size: 48.sp, color: AppColors.primary.withOpacity(0.5)),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Belum ada kelas',
                    style: AppStyles.bodyM.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Tekan tombol + di bawah untuk bergabung ke kelas',
                    style: AppStyles.bodyS.copyWith(fontSize: 12.sp),
                  ),
                ],
              ),
            )
          else
            ...controller.myClasses.map((classData) => _ClassCard(
              classData: classData,
              onTap: () => controller.openClassDetail(classData),
            )),
          
          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}

// ========================
// SUB-WIDGETS
// ========================

class _ShortcutCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;

  const _ShortcutCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(icon, color: color, size: 24.sp),
            ),
            SizedBox(height: 12.h),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: AppStyles.headingM.copyWith(
                  color: color,
                  fontSize: 20.sp,
                ),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: AppStyles.bodyS.copyWith(
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _DeadlineCard extends StatelessWidget {
  final dynamic assignment;
  final VoidCallback onTap;

  const _DeadlineCard({required this.assignment, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.warningLight,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.warning.withOpacity(0.2), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(Icons.assignment_late_rounded,
                  color: AppColors.warning, size: 20.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    assignment.title,
                    style: AppStyles.labelL.copyWith(fontSize: 15.sp),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Deadline: ${Helpers.getTimeRemaining(assignment.deadline)}',
                    style: AppStyles.bodyS.copyWith(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 14.sp, color: AppColors.warning),
          ],
        ),
      ),
    );
  }
}

class _ClassCard extends StatelessWidget {
  final dynamic classData;
  final VoidCallback onTap;

  const _ClassCard({required this.classData, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: AppStyles.cardDecoration,
        child: Row(
          children: [
            Container(
              width: 52.w,
              height: 52.h,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(Icons.class_rounded,
                  color: AppColors.primary, size: 24.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    classData.name,
                    style: AppStyles.labelL.copyWith(fontSize: 15.sp),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Oleh ${classData.teacherName}',
                    style: AppStyles.bodyS.copyWith(fontSize: 12.sp),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColors.surfaceSecondary,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(Icons.arrow_forward_ios_rounded,
                  size: 14.sp, color: AppColors.textTertiary),
            ),
          ],
        ),
      ),
    );
  }
}