import "package:get/get.dart";
import '../views/splash_view.dart';
import '../views/login_view.dart';
import '../views/register_view.dart';
import '../views/home_view.dart';
import '../views/course_view.dart';
import '../views/quiz_view.dart';
import '../views/quiz_view_dio.dart';
import '../views/translator_view.dart';
import '../views/translator_view_dio.dart';

// Admin views
import '../views/admin_login_view.dart';
import '../views/admin_dashboard_view.dart';
import '../views/quiz_management_view.dart';
import '../views/quiz_form_view.dart';
import '../views/user_progress_view.dart';

// ADD THIS
import '../views/branch_location_view.dart';

class AppRoutes {
  // User routes
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const course = '/course';
  static const quiz = '/quiz';
  static const quizDio = '/quiz-dio';
  static const translator = '/translator';
  static const translatorDio = '/translator-dio';

  // Admin routes
  static const adminLogin = '/admin/login';
  static const adminDashboard = '/admin/dashboard';
  static const quizManagement = '/admin/quiz-management';
  static const quizForm = '/admin/quiz-form';
  static const userProgress = '/admin/user-progress';

  // NEW ROUTE for branch location
  static const branchLocation = '/branch-location';
}

class AppPages {
  static final pages = [
    // User pages
    GetPage(name: AppRoutes.splash, page: () => const SplashView()),
    GetPage(name: AppRoutes.login, page: () => const LoginView()),
    GetPage(name: AppRoutes.register, page: () => const RegisterView()),
    GetPage(name: AppRoutes.home, page: () => const HomeView()),
    GetPage(name: AppRoutes.course, page: () => const CourseView()),
    GetPage(name: AppRoutes.quiz, page: () => const QuizView()),
    GetPage(name: AppRoutes.quizDio, page: () => const QuizViewDio()),
    GetPage(name: AppRoutes.translator, page: () => const TranslatorView()),
    GetPage(name: AppRoutes.translatorDio, page: () => const TranslatorViewDio()),

    // Admin pages
    GetPage(name: AppRoutes.adminLogin, page: () => const AdminLoginView()),
    GetPage(name: AppRoutes.adminDashboard, page: () => const AdminDashboardView()),
    GetPage(name: AppRoutes.quizManagement, page: () => const QuizManagementView()),
    GetPage(name: AppRoutes.quizForm, page: () => const QuizFormView()),
    GetPage(name: AppRoutes.userProgress, page: () => const UserProgressView()),

    // NEW PAGE
    GetPage(
      name: AppRoutes.branchLocation,
      page: () => const BranchLocationView(),
    ),
  ];
}
