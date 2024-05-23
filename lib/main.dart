import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

String _language = "en";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(
  //   name: "NewApp2",
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  _language = await AppDataPreferences.getCurrentLanguage();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => QuranAyaPageProvider()),
        ChangeNotifierProvider(create: (_) => TafseerDialogProvider()),
      ],
      child: DevicePreview(builder: (context) => MyApp(),),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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
            home: const Material(
              child: ViewPager(),
            ),
            routes: AppRoutes.ROUTES,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Languages.AR),
      ),
    );
  }
  Future<String> getCurrentLanguage(){
    return AppDataPreferences.getCurrentLanguage();
  }
}
