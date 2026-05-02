// app.dart
// Konfigurasi utama aplikasi: MaterialApp, GetX routing, dan dependency injection.
// Semua halaman dan controller didaftarkan di sini.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'routes.dart';
import '../core/constants/app_styles.dart';
import '../core/constants/app_strings.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';
import '../services/export_service.dart';
import '../services/skripsi_monitoring_service.dart';
import '../features/auth/controllers/auth_controller.dart';

// ====== IMPORT SCREENS AUTH ======
import '../features/auth/screens/splash_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_student_screen.dart';
import '../features/auth/screens/register_teacher_screen.dart';
import '../features/auth/screens/otp_screen.dart';
import '../features/auth/screens/forgot_password_screen.dart';

// ====== IMPORT SCREENS STUDENT ======
import '../features/student/screens/student_dashboard_screen.dart';
import '../features/student/screens/join_class_screen.dart';
import '../features/student/screens/class_detail_screen.dart';
import '../features/student/screens/exam_screen.dart';
import '../features/student/screens/result_screen.dart';
import '../features/student/screens/grade_report_screen.dart';
import '../features/student/screens/student_profile_screen.dart';
import '../features/student/screens/assignment_list_screen.dart';
import '../features/student/screens/chatbot_screen.dart';

// ====== IMPORT SCREENS TEACHER ======
import '../features/teacher/screens/teacher_dashboard_screen.dart';
import '../features/teacher/screens/create_class_screen.dart';
import '../features/teacher/screens/class_management_screen.dart';
import '../features/teacher/screens/create_assignment_screen.dart';
import '../features/teacher/screens/create_question_screen.dart';
import '../features/teacher/screens/student_grades_screen.dart';
import '../features/teacher/screens/analytics_screen.dart';
import '../features/teacher/screens/teacher_profile_screen.dart';
import '../features/teacher/screens/teacher_class_list_screen.dart';

class TrimboApp extends StatelessWidget {
  const TrimboApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      // Ukuran desain referensi (Figma atau desain di HP 375x812)
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: AppStrings.appName,
          debugShowCheckedModeBanner: false,

          // Tema aplikasi
          theme: AppStyles.lightTheme,

          // Route awal (splash screen)
          initialRoute: AppRoutes.splash,

          // Daftarkan semua halaman sebagai GetPage
          getPages: [
            // ====== AUTH ======
            GetPage(
              name: AppRoutes.splash,
              page: () => const SplashScreen(),
              // Binding: register AuthController + services saat splash dibuka
              binding: BindingsBuilder(() {
                // Daftarkan services sebagai singleton (permanent: true)
                Get.put(FirebaseAuthService(), permanent: true);
                Get.put(FirestoreService(), permanent: true);
                Get.put(NotificationService(), permanent: true);
                Get.put(ExportService(), permanent: true);
                Get.put(SkripsiMonitoringService(), permanent: true);
                // Daftarkan AuthController
                Get.put(AuthController(), permanent: true);
              }),
            ),
            GetPage(
              name: AppRoutes.login,
              page: () => const LoginScreen(),
              transition: Transition.fadeIn,
            ),
            GetPage(
              name: AppRoutes.registerStudent,
              page: () => const RegisterStudentScreen(),
              transition: Transition.rightToLeft,
            ),
            GetPage(
              name: AppRoutes.registerTeacher,
              page: () => const RegisterTeacherScreen(),
              transition: Transition.rightToLeft,
            ),
            GetPage(
              name: AppRoutes.otp,
              page: () => const OtpScreen(),
              transition: Transition.rightToLeft,
            ),
            GetPage(
              name: AppRoutes.forgotPassword,
              page: () => const ForgotPasswordScreen(),
              transition: Transition.rightToLeft,
            ),

            // ====== STUDENT ======
            GetPage(
              name: AppRoutes.studentDashboard,
              page: () => const StudentDashboardScreen(),
              transition: Transition.fadeIn,
            ),
            GetPage(
              name: AppRoutes.joinClass,
              page: () => const JoinClassScreen(),
              transition: Transition.rightToLeft,
            ),
            GetPage(
              name: AppRoutes.classDetail,
              page: () => const ClassDetailScreen(),
              transition: Transition.rightToLeft,
            ),
            GetPage(
              name: AppRoutes.exam,
              page: () => const ExamScreen(),
              // Mencegah user kembali ke halaman ujian setelah selesai
              transition: Transition.fade,
            ),
            GetPage(
              name: AppRoutes.result,
              page: () => const ResultScreen(),
              transition: Transition.zoom,
            ),
            GetPage(
              name: AppRoutes.gradeReport,
              page: () => const GradeReportScreen(),
              transition: Transition.rightToLeft,
            ),
            GetPage(
              name: AppRoutes.assignmentList,
              page: () => const AssignmentListScreen(),
              transition: Transition.rightToLeft,
            ),
            GetPage(
              name: AppRoutes.studentProfile,
              page: () => const StudentProfileScreen(),
              transition: Transition.rightToLeft,
            ),
            GetPage(
              name: AppRoutes.chatbot,
              page: () => const ChatbotScreen(),
              transition: Transition.rightToLeft,
            ),

            // ====== TEACHER ======
            GetPage(
              name: AppRoutes.teacherDashboard,
              page: () => const TeacherDashboardScreen(),
              transition: Transition.fadeIn,
            ),
            GetPage(
              name: AppRoutes.createClass,
              page: () => const CreateClassScreen(),
              transition: Transition.rightToLeft,
            ),
            GetPage(
              name: AppRoutes.classManagement,
              page: () => const ClassManagementScreen(),
              transition: Transition.rightToLeft,
            ),
            GetPage(
              name: AppRoutes.createAssignment,
              page: () => const CreateAssignmentScreen(),
              transition: Transition.rightToLeft,
            ),
            GetPage(
              name: AppRoutes.createQuestion,
              page: () => const CreateQuestionScreen(),
              transition: Transition.rightToLeft,
            ),
            GetPage(
              name: AppRoutes.studentGrades,
              page: () => const StudentGradesScreen(),
              transition: Transition.rightToLeft,
            ),
            GetPage(
              name: AppRoutes.analytics,
              page: () => const AnalyticsScreen(),
              transition: Transition.rightToLeft,
            ),
            GetPage(
              name: AppRoutes.teacherProfile,
              page: () => const TeacherProfileScreen(),
              transition: Transition.rightToLeft,
            ),
            GetPage(
              name: AppRoutes.teacherClassList,
              page: () => const TeacherClassListScreen(),
              transition: Transition.rightToLeft,
            ),
          ],
        );
      },
    );
  }
}
