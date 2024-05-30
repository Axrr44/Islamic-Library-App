import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/services/app_data_pref.dart';
import 'package:freelancer/utilities/utility.dart';
import '../config/app_colors.dart';
import '../config/app_routes.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class ViewPager extends StatefulWidget {
  const ViewPager({super.key});

  @override
  State<ViewPager> createState() => _ViewPagerState();
}


class _ViewPagerState extends State<ViewPager> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    TextDirection textDirection = Directionality.of(context);

    return Scaffold(
      extendBody: true,
      body: Column(
        children: [
          Expanded(child: _contentOfPageView(width, height)),
          if (_currentPage == 4) _nextButton(textDirection, height, width, context),
          _buildPageIndicators(),
        ],
      ),
    );
  }

  Widget _contentOfPageView(double width, double height) {
    String currentLanguage = Localizations.localeOf(context).languageCode;
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    final bool isMobile = shortestSide < 600;

    return PageView(
      onPageChanged: (int page) {
        setState(() {
          _currentPage = page;
        });
      },
      controller: _pageController,
      children: [
        Center(
          child: _buildPages(
            "assets/images/quran_page.png",
            AppLocalizations.of(context)!.quran,
            AppLocalizations.of(context)!.contentPage1,
            width,
            height,
            currentLanguage,
            isMobile ? 300.w : 200.w,
            20.h,
            100.h,
          ),
        ),
        Center(
          child: _buildPages(
            "assets/images/hadith_page.png",
            AppLocalizations.of(context)!.hadiths,
            AppLocalizations.of(context)!.contentPage2,
            width,
            height,
            currentLanguage,
            isMobile ? 300.w : 200.w,
            30.h,
            100.h,
          ),
        ),
        Center(
          child: _buildPages(
            "assets/images/tafseer.png",
            AppLocalizations.of(context)!.tafseer,
            AppLocalizations.of(context)!.contentPage3,
            width,
            height,
            currentLanguage,
            isMobile ? 300.w : 200.w,
            30.h,
            40.h,
          ),
        ),
        Center(
          child: _buildPages(
            "assets/images/audiobook.png",
            AppLocalizations.of(context)!.audio,
            AppLocalizations.of(context)!.contentPage4,
            width,
            height,
            currentLanguage,
            isMobile ? 200.w : 150.w,
            50.h,
            60.h,
          ),
        ),
        Center(
          child: _buildPages(
            "assets/images/arabic.png",
            AppLocalizations.of(context)!.languages,
            AppLocalizations.of(context)!.contentPage5,
            width,
            height,
            currentLanguage,
            isMobile ? 200.w : 150.w,
            50.h,
            60.h,
          ),
        ),
      ],
    );
  }

  Container _nextButton(TextDirection textDirection, double height, double width, BuildContext context) {
    return Container(
      alignment: textDirection == TextDirection.ltr
          ? Alignment.bottomRight
          : Alignment.bottomLeft,
      margin: EdgeInsets.only(
          bottom: height / 25,
          right: textDirection == TextDirection.ltr ? width / 10 : 0,
          left: textDirection == TextDirection.rtl ? width / 10 : 0),
      child: SizedBox(
        width: 150.w,
        height: 50.h,
        child: ElevatedButton(
          onPressed: () {
            if (_currentPage != 4) {
              _pageController.animateToPage(++_currentPage,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut);
            } else {
              Navigator.of(context).pushReplacementNamed(AppRoutes.SIGN_IN_ROUTES);
              AppDataPreferences.setShowViewPager(false);
            }
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(AppColor.primary1),
            foregroundColor: MaterialStateProperty.all<Color>(AppColor.white),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          child: Text(AppLocalizations.of(context)!.next, style: TextStyle(fontSize: 20.sp)),
        ),
      ),
    );
  }

  Widget _buildPages(String image, String title, String description, double width,
      double height, String currentLanguage, double imageSize, double topMargin, double bottomMargin) {
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    final bool isMobile = shortestSide < 600;
    return Column(
      // Aligns children horizontally at the center
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: isMobile ? height / 5 : height / 12,
        ),
        Text(
          title,
          style: TextStyle(fontSize: 60.sp, fontWeight: FontWeight.bold, fontFamily: 'AEFont'),
        ),
        SizedBox(
          height: topMargin,
        ),
        SizedBox(width: imageSize, height: imageSize, child: Image.asset(image, fit: BoxFit.cover)),
        SizedBox(
          height: bottomMargin,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 15.sp,
                fontFamily: Utility.getTextFamily(currentLanguage)),
          ),
        )
      ],
    );
  }

  Widget _buildPageIndicators() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List<Widget>.generate(5, (int index) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: EdgeInsets.symmetric(horizontal: 5.w),
            height: 10.w,
            width: _currentPage == index ? 20.w : 10.w,
            decoration: BoxDecoration(
              color: _currentPage == index ? AppColor.primary1 : Colors.grey,
              borderRadius: BorderRadius.circular(5.w),
            ),
          );
        }),
      ),
    );
  }
}
