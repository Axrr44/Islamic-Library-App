import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:islamiclibrary/config/app_languages.dart';
import 'package:islamiclibrary/pages/list_of_mufseer_page.dart';
import 'package:islamiclibrary/pages/tafseer_conent_page.dart';
import 'package:islamiclibrary/utilities/utility.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../config/app_colors.dart';
import '../config/toast_message.dart';
import '../models/tafseer_books.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../services/admob_service.dart';
import '../services/app_data_pref.dart';
import 'package:quran/quran.dart' as quran;

class TafseerPage extends StatefulWidget {
  const TafseerPage({super.key});

  @override
  State<TafseerPage> createState() => _TafseerPageState();
}

class _TafseerPageState extends State<TafseerPage> {
  late Future<List<Tafseer>> _tafseerListFuture;
  late Tafseer _mufseerLastRead;
  BannerAd? _bannerAd;
  final int _indexOfSurah = 0;
  late int _surahId;
  late int _indexOfScrolling;

  @override
  void initState() {
    super.initState();
    _createBannerAd();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadTafseerData();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    String currentLanguage = Localizations.localeOf(context).languageCode;
    final bool isMobile = shortestSide < 600;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _header(width, height, context, isMobile, currentLanguage),
            _listOfSurah(width, height, context, currentLanguage),
          ],
        ),
      ),
    );
  }

  Future<void> _loadTafseerData() async {
    _surahId = await AppDataPreferences.getTafseerSurahId();
    _mufseerLastRead = await AppDataPreferences.getTafseerMufseer();
    _indexOfScrolling = await AppDataPreferences.getTafseerIndex();
  }

  Widget _listOfSurah(double width, double height, BuildContext context,
      String currentLanguage) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: width / 2,
            mainAxisExtent: height / 5,
            childAspectRatio: 1,
            crossAxisSpacing: 5.w,
            mainAxisSpacing: 5.h,
          ),
          itemCount: 114,
          itemBuilder: (_, index) {
            return Card(
              color: AppColor.white,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ListOfMufseerPage(surahId: index + 1),
                  ));
                },
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        currentLanguage == Languages.EN.languageCode
                            ? quran.getSurahName(index + 1)
                            : quran.getSurahNameArabic(index + 1),
                        style: TextStyle(fontSize: 14.sp),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 15.w,
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _createBannerAd() {
    _bannerAd = BannerAd(
      size: AdSize.fullBanner,
      adUnitId: AdmobService.bannerAdUnitId(true),
      listener: AdmobService.bannerListener,
      request: const AdRequest(),
    )..load();
  }

  Widget _header(double width, double height, BuildContext context,
      bool isMobile, String currentLanguage) {
    return Stack(
      children: [
        ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.grey.withOpacity(0.1),
                Colors.grey.withOpacity(0)
              ],
            ).createShader(bounds);
          },
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/images/islamic_pattern_2.png"),
                  fit: BoxFit.cover),
            ),
            width: width,
            height: height / 3 - 40.h,
            alignment: Alignment.bottomCenter,
          ),
        ),
        if (_bannerAd != null)
          Positioned(
            top: 0, // Set to top of the screen
            left: 0,
            right: 0,
            child: SizedBox(
              width: width,
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
          ),
        Container(
          width: width,
          height: height / 2 - 100,
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(
                top: 80.h, bottom: 10.h, right: 20.w, left: 20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(isMobile ? 15.w : 10.w),
                      child: Container(
                        color: AppColor.primary1,
                        child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            currentLanguage == Languages.EN.languageCode
                                ? Icons.keyboard_arrow_left_rounded
                                : Icons.keyboard_arrow_right_rounded,
                            size: 35.w,
                            color: AppColor.white,
                          ),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.tafseer,
                          style: TextStyle(
                              fontFamily: 'AEFont',
                              fontSize: 60.sp,
                              color: AppColor.black,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          width: width / 2,
                          child: Text(
                            AppLocalizations.of(context)!.tafseerSubTitle,
                            style: TextStyle(
                                fontSize: 15.sp,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontFamily:
                                    currentLanguage == Languages.EN.languageCode
                                        ? 'EnglishQuran'
                                        : 'Hafs'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(isMobile ? 15.w : 10.w),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColor.white,
                          borderRadius:
                              BorderRadius.circular(isMobile ? 15.w : 10.w),
                          border: Border.all(
                            color: AppColor.black, // Set the border color here
                            width: 1.w, // Set the border width here
                          ),
                        ),
                        child: IconButton(
                          onPressed: () async {
                            await _loadTafseerData();
                            if (_surahId != -1) {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => TafseerContentPage(
                                  mufseer: _mufseerLastRead,
                                  surahId: _surahId,
                                  isScrollable: true,
                                  indexOfScrollable: _indexOfScrolling,
                                ),
                              ));
                            } else {
                              ToastMessage.showMessage(
                                  AppLocalizations.of(context)!.noLastRead);
                            }
                          },
                          icon: Icon(
                            Icons.bookmark_outline_rounded,
                            color: AppColor.black,
                            size: 35.w,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5.h,
                    ),
                    Text(
                      AppLocalizations.of(context)!.lastRead,
                      style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey,
                          fontFamily: Utility.getTextFamily(currentLanguage)),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
