import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:freelancer/pages/quran_aya_page.dart';
import 'package:quran/quran.dart' as quran;
import 'package:arabic_numbers/arabic_numbers.dart';
import '../config/app_colors.dart';
import '../config/app_languages.dart';
import '../services/app_data.dart';

class QuranSuraPage extends StatefulWidget {
  const QuranSuraPage({super.key});

  @override
  _QuranSuraPageState createState() => _QuranSuraPageState();
}

class _QuranSuraPageState extends State<QuranSuraPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [
                  AppColor.primary1.withOpacity(0.1),
                  AppColor.white.withOpacity(0.2)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0.2, 0.6])),
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(
              child: _header(width, height, context, isMobile,currentLanguage),
            ),
            SliverAppBar(
              pinned: true,
              automaticallyImplyLeading: false,
              elevation: 0,
              backgroundColor: innerBoxIsScrolled == false
                  ? AppColor.black.withOpacity(0)
                  : AppColor.black,
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(isMobile == true ? 0 : 20.h),
                child: TabBar(
                    controller: _tabController,
                    unselectedLabelColor: Colors.grey.withOpacity(0.7),
                    overlayColor: MaterialStateProperty.all(
                        innerBoxIsScrolled == false
                            ? AppColor.black.withOpacity(0.1)
                            : AppColor.white.withOpacity(0.1)),
                    labelPadding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: isMobile == true ? 0 : 10.h),
                    labelStyle: TextStyle(fontSize: 20.sp),
                    labelColor: innerBoxIsScrolled == false
                        ? AppColor.black
                        : AppColor.white,
                    indicatorColor: innerBoxIsScrolled == false
                        ? AppColor.black
                        : AppColor.white,
                    tabs: const [
                      Tab(
                        child: Text("Surah"),
                      ),
                      Tab(
                        child: Text("Juz"),
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
              onTap: () {},
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
                              fontSize: 35.sp, fontWeight: FontWeight.w700),
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
                                          fontWeight: FontWeight.w700),
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
                                  fontSize: 15.sp, fontWeight: FontWeight.w700),
                            ),
                            Column(
                              children: [
                                Text(
                                  currentLanguage == Languages.EN.languageCode
                                      ? "${quran.getVerseCount(index)}   Verse"
                                      : "${ArabicNumbers.convert(quran.getVerseCount(index))}   اية",
                                  style: TextStyle(
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

  Widget _header(
      double width, double height, BuildContext context, bool isMobile,String currentLanguage) {
    return Container(
      width: width,
      height: isMobile == true ? height / 3 : height / 2 - 100,
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding:
            EdgeInsets.only(top: 50.h, bottom: 10.h, right: 20.w, left: 20.w),
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
                      icon: Icon(currentLanguage == Languages.EN.languageCode
                        ? Icons.keyboard_arrow_left_rounded : Icons.keyboard_arrow_right_rounded,
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
                      "Qura`an",
                      style: TextStyle(
                          fontSize: 40.sp,
                          color: AppColor.primary1,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: width / 2,
                      child: Text(
                        "This is test for design",
                        style: TextStyle(
                            fontSize: 15.sp, color: AppColor.primary6),
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
                  child: Container(
                    color: AppColor.primary1,
                    child: IconButton(
                        onPressed: () {},
                        icon: Icon(
                          color: AppColor.white,
                          Icons.bookmark_outline_rounded,
                          size: 35.w,
                        )),
                  ),
                ),
                SizedBox(
                  height: 5.h,
                ),
                Text(
                  "Last read",
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  String convertToString(int number) {
    number++;
    return number.toString();
  }
}
