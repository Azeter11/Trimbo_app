// routes.dart
// File ini mendefinisikan semua nama route (halaman) di aplikasi EduTask.
// Menggunakan GetX untuk navigasi: Get.toNamed(AppRoutes.login)

class AppRoutes {
  AppRoutes._();

  // ========================
  // AUTH ROUTES
  // ========================
  static const String splash = '/';
  static const String login = '/login';
  static const String registerStudent = '/register/student';
  static const String registerTeacher = '/register/teacher';
  static const String otp = '/otp';
  static const String forgotPassword = '/forgot-password';

  // ========================
  // STUDENT ROUTES
  // ========================
  static const String studentDashboard = '/student/dashboard';
  static const String joinClass = '/student/join-class';
  static const String classDetail = '/student/class-detail';
  static const String assignmentList = '/student/assignments';
  static const String exam = '/student/exam';
  static const String result = '/student/result';
  static const String gradeReport = '/student/grades';
  static const String studentProfile = '/student/profile';
  static const String chatbot = '/student/chatbot';

  // ========================
  // TEACHER ROUTES
  // ========================
  static const String teacherDashboard = '/teacher/dashboard';
  static const String createClass = '/teacher/create-class';
  static const String classManagement = '/teacher/class-management';
  static const String createAssignment = '/teacher/create-assignment';
  static const String createQuestion = '/teacher/create-question';
  static const String studentGrades = '/teacher/student-grades';
  static const String analytics = '/teacher/analytics';
  static const String teacherProfile = '/teacher/profile';
  static const String teacherClassList = '/teacher/classes';
}
