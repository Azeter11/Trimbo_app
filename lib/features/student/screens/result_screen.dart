// result_screen.dart
// Halaman hasil ujian setelah submit.
// Fitur: animasi count-up nilai, statistik benar/salah/skip, tombol kembali.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_styles.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../app/routes.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  // Ambil data hasil ujian dari arguments navigasi
  late final double score;
  late final int correct;
  late final int wrong;
  late final int skipped;
  late final int totalQuestions;
  late final String assignmentTitle;
  late final bool isEliminatedByCheat;

  // Nilai yang ditampilkan (animasi count-up dari 0 ke nilai asli)
  double _displayedScore = 0;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();

    // Ambil data dari Get.arguments
    final args = Get.arguments as Map<String, dynamic>;
    score = (args['score'] as num).toDouble();
    correct = args['correct'] as int;
    wrong = args['wrong'] as int;
    skipped = args['skipped'] as int;
    totalQuestions = args['totalQuestions'] as int;
    assignmentTitle = args['assignmentTitle'] as String;
    isEliminatedByCheat = args['isEliminatedByCheat'] as bool? ?? false;

    // Setup animasi count-up untuk nilai
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Animasi nilai dari 0 ke nilai asli
    final animation = Tween<double>(begin: 0, end: score).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    animation.addListener(() {
      setState(() => _displayedScore = animation.value);
    });

    // Delay sedikit sebelum animasi mulai
    Future.delayed(const Duration(milliseconds: 300), () {
      _animController.forward();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  /// Tentukan warna berdasarkan nilai.
  Color get _scoreColor => AppColors.gradeColor(score);

  /// Tentukan emoji berdasarkan nilai.
  String get _scoreEmoji {
    if (isEliminatedByCheat) return '🚫';
    if (score >= 90) return '🏆';
    if (score >= 80) return '⭐';
    if (score >= 70) return '👍';
    if (score >= 60) return '📝';
    return '💪';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            children: [
              SizedBox(height: 24.h),

              // ====== EMOJI & JUDUL ======
              Text(_scoreEmoji, style: TextStyle(fontSize: 64.sp)),

              SizedBox(height: 16.h),

              Text(AppStrings.resultTitle, style: AppStyles.headingM),

              SizedBox(height: 4.h),

              Text(
                assignmentTitle,
                style: AppStyles.bodyM.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 32.h),

              // ====== NILAI BESAR (COUNT-UP) ======
              Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: _scoreColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Container(
                  width: 140.w,
                  height: 140.h,
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _scoreColor.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        // Animasi nilai dari 0 → nilai asli
                        _displayedScore.toStringAsFixed(0),
                        style: AppStyles.scoreLarge.copyWith(
                          color: _scoreColor,
                          fontSize: 52.sp,
                        ),
                      ),
                      Text(
                        // Grade huruf
                        Helpers.scoreToGrade(score),
                        style: AppStyles.headingS.copyWith(color: _scoreColor),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 32.h),

              // ====== STATISTIK ======
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: AppStyles.cardDecoration,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(
                      label: AppStrings.resultCorrect,
                      value: '$correct',
                      color: AppColors.success,
                      icon: Icons.check_circle_rounded,
                    ),
                    _Divider(),
                    _StatItem(
                      label: AppStrings.resultWrong,
                      value: '$wrong',
                      color: AppColors.error,
                      icon: Icons.cancel_rounded,
                    ),
                    _Divider(),
                    _StatItem(
                      label: AppStrings.resultSkipped,
                      value: '$skipped',
                      color: AppColors.textSecondary,
                      icon: Icons.remove_circle_outline_rounded,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // Info total soal
              Text(
                'Total: $totalQuestions soal',
                style: AppStyles.bodyS,
              ),

              SizedBox(height: 32.h),

              // ====== PESAN MOTIVASI / ELIMINASI ======
              if (isEliminatedByCheat)
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppColors.errorLight,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: AppColors.error.withOpacity(0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.gpp_bad_rounded,
                          color: AppColors.error, size: 24.sp),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          'Ujian dihentikan karena keluar layar 3x.\n'
                          'Nilai 0 telah dicatat oleh sistem.',
                          style: AppStyles.bodyM
                              .copyWith(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    _getMotivationMessage(),
                    style: AppStyles.bodyM.copyWith(color: AppColors.primary),
                    textAlign: TextAlign.center,
                  ),
                ),

              SizedBox(height: 32.h),

              // ====== TOMBOL ======
              PrimaryButton(
                text: AppStrings.resultBackToClass,
                onPressed: () => Get.offAllNamed(AppRoutes.studentDashboard),
                leadingIcon: Icons.home_rounded,
              ),

              SizedBox(height: 12.h),

              OutlineButton(
                text: AppStrings.myGrades,
                onPressed: () => Get.offNamed(AppRoutes.gradeReport),
                leadingIcon: Icons.bar_chart_rounded,
              ),

              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  /// Pesan motivasi berdasarkan nilai.
  String _getMotivationMessage() {
    if (isEliminatedByCheat) {
      return '⚠️ Peringatan: Perilaku kecurangan telah direkam. Patuhi aturan ujian pada kesempatan berikutnya.';
    }
    if (score >= 90) return '🎉 Luar biasa! Pertahankan prestasi ini!';
    if (score >= 80) return '👏 Bagus sekali! Sedikit lagi menuju sempurna!';
    if (score >= 70) return '💪 Cukup baik! Terus belajar dan berlatih!';
    if (score >= 60) return '📚 Tidak apa-apa! Pelajari kembali materi yang salah.';
    return '🌱 Jangan menyerah! Setiap kegagalan adalah batu loncatan.';
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24.sp),
        SizedBox(height: 6.h),
        Text(
          value,
          style: AppStyles.headingM.copyWith(color: color),
        ),
        SizedBox(height: 4.h),
        Text(label, style: AppStyles.bodyS),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 60.h,
      color: AppColors.border,
    );
  }
}
