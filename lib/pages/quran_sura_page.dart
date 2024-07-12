import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:islamiclibrary/pages/quran_aya_page.dart';
import 'package:islamiclibrary/services/app_data_pref.dart';
import 'package:islamiclibrary/utilities/utility.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:quran/quran.dart' as quran;
import 'package:arabic_numbers/arabic_numbers.dart';
import '../config/app_colors.dart';
import '../config/app_languages.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../config/toast_message.dart';
import '../services/admob_service.dart';
import '../services/app_data.dart';

class QuranSuraPage extends StatefulWidget {
  const QuranSuraPage({super.key});

  @override
  _QuranSuraPageState createState() => _QuranSuraPageState();
}

class _QuranSuraPageState extends State<QuranSuraPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  BannerAd? _bannerAd;
  int surahIdLastRead = 0;
  int verseIdLastRead = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    //_createBannerAd();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadQuranData();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    String currentLanguage = Localizations.localeOf(context).languageCode;
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    final bool isMobile = shortestSide < 600;

    return Scaffold(
      body: Container(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(
              child: _header(width, height, context, isMobile, currentLanguage),
            ),
            SliverAppBar(
              pinned: true,
              automaticallyImplyLeading: false,
              elevation: 0,
              backgroundColor: innerBoxIsScrolled == false
                  ? AppColor.black.withOpacity(0)
                  : AppColor.primary1,
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(isMobile == true ? 0 : 20.h),
                child: TabBar(
                    controller: _tabController,
                    unselectedLabelColor: innerBoxIsScrolled
                        ? AppColor.white.withOpacity(0.7)
                        : Colors.grey.withOpacity(0.7),
                    overlayColor: WidgetStateProperty.all(!innerBoxIsScrolled
                        ? AppColor.black.withOpacity(0.1)
                        : AppColor.white.withOpacity(0.1)),
                    labelPadding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: isMobile == true ? 0 : 10.h),
                    labelStyle: TextStyle(fontSize: 20.sp),
                    labelColor:
                        !innerBoxIsScrolled ? AppColor.black : AppColor.white,
                    indicatorColor: !innerBoxIsScrolled
                        ? AppColor.primary1
                        : AppColor.white,
                    tabs: [
                      Tab(
                        child: Text(
                          AppLocalizations.of(context)!.surah,
                          style: TextStyle(
                              fontFamily:
                                  Utility.getTextFamily(currentLanguage)),
                        ),
                      ),
                      Tab(
                        child: Text(
                          AppLocalizations.of(context)!.juz,
                          style: TextStyle(
                              fontFamily:
                                  Utility.getTextFamily(currentLanguage)),
                        ),
                      ),
                    ]),
              ),
            )
          ],
          body: TabBarView(
            controller: _tabController,
            children: [
              _listOfSurah(height, width, currentLanguage),
              _listOfJuz(height, width, currentLanguage)
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadQuranData() async {
    surahIdLastRead = await AppDataPreferences.getSurahId();
    verseIdLastRead = await AppDataPreferences.getVerseId();
  }

  Widget _listOfJuz(double height, double width, String currentLanguage) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 10.w, mainAxisSpacing: 10.h),
        itemBuilder: (context, index) {
          return Card(
            color: AppColor.white,
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => QuranAyaPage(
                          surahId: AppData.getNumberSurahByJuz(index),
                          initialPage: AppData.getNumberPageByJuz(index) - 1,
                        )));
              },
              child: Container(
                margin: EdgeInsets.symmetric(vertical: height / 20),
                padding: EdgeInsets.symmetric(horizontal: width / 20),
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SvgPicture.asset(
                        "assets/images/nomor-surah.svg",
                        colorFilter: const ColorFilter.mode(
                            AppColor.black, BlendMode.srcATop),
                        width: 80.w,
                        height: 80.w,
                      ),
                      Center(
                        child: Text(
                          currentLanguage == Languages.EN.languageCode
                              ? convertToString(index)
                              : ArabicNumbers.convert(convertToString(index)),
                          style: TextStyle(
                              fontSize: 35.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColor.primary1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        itemCount: 30,
      ),
    );
  }

  FutureBuilder<List<String>> _listOfSurah(
      double height, double width, String currentLanguage) {
    return FutureBuilder<List<String>>(
      future: AppData.fetchSurahData(currentLanguage),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          List<String>? surahList = snapshot.data;
          if (surahList != null && surahList.isNotEmpty) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              child: ListView.separated(
                itemBuilder: (BuildContext context, int index) {
                  // itemBuilder function
                  return Card(
                    color: AppColor.white,
                    child: InkWell(
                      onTap: () {
                        int value = index;
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => QuranAyaPage(
                                  surahId: value,
                                  initialPage:
                                      quran.getSurahPages(value)[0] - 1,
                                )));
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: height / 20),
                        padding: EdgeInsets.symmetric(horizontal: width / 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Stack(
                              children: [
                                SvgPicture.asset(
                                  "assets/images/nomor-surah.svg",
                                  colorFilter: const ColorFilter.mode(
                                      AppColor.black, BlendMode.srcATop),
                                  width: 33.w,
                                  height: 33.w,
                                ),
                                SizedBox(
                                  height: 33.w,
                                  width: 33.w,
                                  child: Center(
                                    child: Text(
                                      currentLanguage ==
                                              Languages.EN.languageCode
                                          ? convertToString(index)
                                          : ArabicNumbers.convert(
                                              convertToString(index)),
                                      style: TextStyle(
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.w700,
                                          color: AppColor.primary1),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              currentLanguage == Languages.EN.languageCode
                                  ? quran.getSurahNameEnglish(++index)
                                  : quran.getSurahNameArabic(++index),
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                                fontFamily:
                                    Utility.getTextFamily(currentLanguage),
                              ),
                            ),
                            Column(
                              children: [
                                Text(
                                  currentLanguage == Languages.EN.languageCode
                                      ? "${quran.getVerseCount(index)}   Verse"
                                      : "${ArabicNumbers.convert(quran.getVerseCount(index))}   اية",
                                  style: TextStyle(
                                      fontFamily: Utility.getTextFamily(
                                          currentLanguage),
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w700),
                                ),
                                SizedBox(
                                  height: 5.h,
                                ),
                                Text(
                                  currentLanguage == Languages.EN.languageCode
                                      ? "${quran.getJuzNumber(index, 1)}   Juz"
                                      : "${ArabicNumbers.convert(quran.getJuzNumber(index, 1))}   جزء",
                                  style: TextStyle(
                                      fontFamily: Utility.getTextFamily(
                                          currentLanguage),
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return const Divider();
                },
                itemCount: quran.totalSurahCount,
              ),
            );
          } else {
            return Center(
              child: Text(
                'No Tafseer data available',
                style: TextStyle(fontSize: 30.sp),
              ),
            );
          }
        }
      },
    );
  }

  void _createBannerAd() {
    _bannerAd = BannerAd(
      size: AdSize.fullBanner,
      adUnitId: AdmobService.bannerAdUnitId(false),
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
                          BorderRadius.circular(isMobile == true ? 15.w : 10.w),
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
                          AppLocalizations.of(context)!.quran,
                          style: TextStyle(
                              fontSize: 60.sp,
                              color: AppColor.black,
                              fontFamily: 'AEFont',
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          width: width / 2,
                          child: Text(
                            AppLocalizations.of(context)!.quranSubTitle,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15.sp,
                                color: Colors.grey),
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
                          BorderRadius.circular(isMobile == true ? 15.w : 10.w),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColor.white,
                          border: Border.all(
                            color: AppColor.black,
                            width: 1.w,
                          ),
                          borderRadius: BorderRadius.circular(
                              isMobile == true ? 15.w : 10.w),
                        ),
                        child: Container(
                          child: IconButton(
                            onPressed: () async {
                              await _loadQuranData();
                              if (surahIdLastRead != -1) {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => QuranAyaPage(
                                          surahId: surahIdLastRead,
                                          initialPage: quran.getPageNumber(
                                                  surahIdLastRead,
                                                  verseIdLastRead) -
                                              1,
                                        )));
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

  String convertToString(int number) {
    number++;
    return number.toString();
  }
}
