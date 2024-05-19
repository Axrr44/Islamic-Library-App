import '../pages/books_page.dart';
import '../pages/main_page.dart';
import '../pages/notification_page.dart';
import '../pages/quran_aya_page.dart';
import '../pages/quran_sura_page.dart';
import '../pages/rest_password_page.dart';
import '../pages/sgin_in.dart';
import '../pages/sign_up.dart';
import '../pages/tafseer_page.dart';

class AppRoutes{



  static const MAIN_ROUTES = "/main-page";
  static const SGIN_IN_ROUTES = "/sign-in-page";
  static const SGIN_UP_ROUTES = "/sign-up-page";
  static const PASSWORD_RESET_ROUTES = "/password-rest-page";
  static const NOTIFICATION_ROUTES = "/notification-page";
  static const QURAN_SURA_ROUTES = "/quran-sura-page";
  static const QURAN_AYA_ROUTES = "/quran-aya-page";
  static const BOOKS_ROUTES = "/books-page";
  static const TAFSEER_ROUTES = "/tafseer-page";

  static final ROUTES = {SGIN_IN_ROUTES: (context) => SignIn(),
    SGIN_UP_ROUTES: (context) => SignUp(),
    MAIN_ROUTES: (context) => const MainPage(),
    PASSWORD_RESET_ROUTES: (context) => RestPasswordPage(),
    NOTIFICATION_ROUTES: (context) => const NotificationPage(),
    QURAN_SURA_ROUTES: (context) => const QuranSuraPage(),
    BOOKS_ROUTES: (context) => const BooksPage(),
    TAFSEER_ROUTES: (context) => const TafseerPage(),
  };


}