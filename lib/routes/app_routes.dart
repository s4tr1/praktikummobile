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

class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const course = '/course';
  static const quiz = '/quiz';
  static const quizDio = '/quiz-dio';
  static const translator = '/translator';
  static const translatorDio = '/translator-dio';
}

class AppPages {
  static final pages = [
    GetPage(name: AppRoutes.splash, page: () => const SplashView()),
    GetPage(name: AppRoutes.login, page: () => const LoginView()),
    GetPage(name: AppRoutes.register, page: () => const RegisterView()),
    GetPage(name: AppRoutes.home, page: () => const HomeView()),
    GetPage(name: AppRoutes.course, page: () => const CourseView()),
    GetPage(name: AppRoutes.quiz, page: () => const QuizView()),
    GetPage(name: AppRoutes.quizDio, page: () => const QuizViewDio()),
    GetPage(name: AppRoutes.translator, page: () => const TranslatorView()),
    GetPage(
        name: AppRoutes.translatorDio, page: () => const TranslatorViewDio()),
  ];
}
