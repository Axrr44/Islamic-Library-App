import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/config/toast_message.dart';
import 'package:freelancer/pages/chapter_of_books_page.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../config/app_languages.dart';
import '../services/admob_service.dart';
import '../services/app_data.dart';
import '../config/app_colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../services/app_data_pref.dart';
import 'content_books_page.dart';

class BooksPage extends StatefulWidget {
  const BooksPage({super.key});

  @override
  State<BooksPage> createState() => _BooksPageState();
}

class _BooksPageState extends State<BooksPage> {
  late int _hadithBookId;
  late int _hadithIndex;
  late int _chapterId;
  BannerAd? _bannerAd;
  late String _chapterName;

  @override
  void initState() {
    super.initState();
    _loadHadithData();
    _createBannerAd();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    String currentLanguage = Localizations.localeOf(context).languageCode;
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    final bool isMobile = shortestSide < 600;

    return Scaffold(
      extendBody: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _header(width, height, context, isMobile, currentLanguage),
            _listOfHadiths(width, height, context, currentLanguage),
          ],
        ),
      ),
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
              colors: [Colors.grey.withOpacity(0.1), Colors.grey.withOpacity(0)],
            ).createShader(bounds);
          },
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/islamic_pattern_2.png"),
                fit: BoxFit.cover,
              ),
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
          height:  height / 2  - 100,
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(top: 80.h, right: 20.w, left: 20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(isMobile ? 15.w : 10.w),
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
                            color: AppColor.primary6,
                          ),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.hadiths,
                          style: TextStyle(
                            fontFamily: 'AEFont',
                            fontSize: 60.sp,
                            color: AppColor.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          width: width / 2 + 50.w,
                          child: Text(
                            AppLocalizations.of(context)!.hadithsSubTitle,
                            style: TextStyle(
                              fontSize: currentLanguage ==
                                  Languages.EN.languageCode
                                  ? 10.sp
                                  : 15.sp,
                              color: Colors.grey,
                              fontFamily: currentLanguage ==
                                  Languages.EN.languageCode
                                  ? 'EnglishQuran'
                                  : 'Hafs',
                            ),
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
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColor.white,
                          border: Border.all(
                            color: AppColor.black,
                            width: 1.w,
                          ),
                          borderRadius: BorderRadius.circular(
                              isMobile ? 15.w : 10.w),
                        ),
                        child: Container(
                          color: AppColor.white.withOpacity(0.0),
                          child: IconButton(
                            onPressed: () async {
                              await _loadHadithData();
                              if (_hadithBookId != -1) {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => ContentBooksPage(
                                    chapterId: _chapterId,
                                    bookId: _hadithBookId,
                                    bookName: _chapterName,
                                    isScrollable: true,
                                    indexOfScrollable: _hadithIndex,
                                  ),
                                ));
                              } else {
                                ToastMessage.showMessage(
                                    AppLocalizations.of(context)!.noLastRead);
                              }
                            },
                            icon: Icon(
                              color: AppColor.black,
                              Icons.bookmark_outline_rounded,
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
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _loadHadithData() async {
    _hadithBookId = await AppDataPreferences.getHadithBookId();
    _hadithIndex = await AppDataPreferences.getHadithIndex();
    _chapterId = await AppDataPreferences.getHadithChapterId();
    _chapterName = await AppDataPreferences.getHadithChapterName();
  }

  Widget _listOfHadiths(double width, double height, BuildContext context, String currentLanguage) {
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
          itemCount: 14,
          itemBuilder: (_, index) {
            bool isDarimi = "Sunan ad-Darimi" == AppData.getBookName(context, index);
            return Card(
              color: isDarimi ? Colors.grey.withOpacity(0.5) : AppColor.white,
              child: InkWell(
                onTap: isDarimi
                    ? null
                    : () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ChapterOfBooksPage(selectedHadith: index),
                  ));
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        isDarimi ? "Only arabic" : AppData.getBookName(context, index),
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

}
