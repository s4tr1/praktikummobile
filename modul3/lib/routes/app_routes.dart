import 'package:get/get.dart';
import '../views/user/user_dashboard.dart';
import '../views/user/course_list.dart';
import '../views/user/course_detail.dart';
import '../views/user/quiz_page.dart';
import '../views/user/certificate_page.dart';

class AppRoutes {
  static const dashboard = '/dashboard';
  static const courses = '/courses';
  static const courseDetail = '/courseDetail';
  static const quiz = '/quiz';
  static const certificate = '/certificate';

  static final routes = [
    GetPage(name: dashboard, page: () => const UserDashboard()),
    GetPage(name: courses, page: () => const CourseListPage()),
    GetPage(name: courseDetail, page: () => const CourseDetailPage()),
    GetPage(name: quiz, page: () => const QuizPage()),
    GetPage(name: certificate, page: () => const CertificatePage()),
  ];
}
