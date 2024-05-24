import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/providers/favorite_provider.dart';
import 'package:freelancer/providers/language_provider.dart';
import 'package:freelancer/providers/quran_aya_page_provider.dart';
import 'package:freelancer/providers/tafseer_dialog_provider.dart';
import 'package:freelancer/services/app_data_pref.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'components/custom_progress.dart';
import 'components/view_pager.dart';
import 'config/app_languages.dart';
import 'config/app_routes.dart';
import 'firebase_options.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => QuranAyaPageProvider()),
        ChangeNotifierProvider(create: (_) => TafseerDialogProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context,provider,_)
      {
        return ScreenUtilInit(
          designSize: const Size(360, 690),
          minTextAdapt: true,
          splitScreenMode: true,
          child: GlobalLoaderOverlay(
            overlayColor: Colors.grey.withOpacity(0.3),
            useDefaultLoading: false,
            overlayWidgetBuilder: (_) {
              return customProgress();
            },
            child: MaterialApp(
                theme: ThemeData(fontFamily: 'Custom'),
                initialRoute: AppRoutes.SPLASH_SCREEN_REOUTS,
                routes: AppRoutes.ROUTES,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                locale: Locale(provider.currentLanguage)),
          ),
        );
      }
    );
  }
  Future<String> getCurrentLanguage(){
    return AppDataPreferences.getCurrentLanguage();
  }
}
