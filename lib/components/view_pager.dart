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
  late String _buttonName;


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _buttonName = AppLocalizations.of(context)!.next;
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    TextDirection textDirection = Directionality.of(context);

    return Scaffold(
        extendBody: true,
        body: _contentOfPageView(width, height),
        bottomNavigationBar: _nextButton(textDirection, height, width, context));
  }

  Container _contentOfPageView(double width, double height) {
    String currentLanguage = Localizations.localeOf(context).languageCode;

    return Container(
      child: PageView(
        onPageChanged: (int page) {
          setState(() {
            // Update button name based on current page
            _currentPage = page;
            if (_currentPage == 4) {
              _buttonName = AppLocalizations.of(context)!.letsGo;
            } else {
              _buttonName = AppLocalizations.of(context)!.next;
            }
          });
        },
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Center(
            child: _buildPages("assets/images/quran4.png", AppLocalizations.of(context)!.quran,
                AppLocalizations.of(context)!.contentPage1, width, height,currentLanguage),
          ),
          Center(
            child: _buildPages("assets/images/hadithBook.png", AppLocalizations.of(context)!.hadiths,
                AppLocalizations.of(context)!.contentPage2, width, height,currentLanguage),
          ),
          Center(
            child: _buildPages("assets/images/quran1.png", AppLocalizations.of(context)!.tafseer,
                AppLocalizations.of(context)!.contentPage3, width, height,currentLanguage),
          ),
          Center(
            child: _buildPages("assets/images/audiobook.png", AppLocalizations.of(context)!.audio,
                AppLocalizations.of(context)!.contentPage4, width, height,currentLanguage),
          ),
          Center(
            child: _buildPages("assets/images/arabic.png", AppLocalizations.of(context)!.languages,
                AppLocalizations.of(context)!.contentPage5, width, height,currentLanguage),
          ),
        ],
      ),
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
                  Navigator.of(context)
                      .pushReplacementNamed(AppRoutes.SGIN_IN_ROUTES);
                  AppDataPreferences.setShowViewPager(false);
                }
              },
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(AppColor.primary1),
                foregroundColor:
                    MaterialStateProperty.all<Color>(AppColor.white),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              child: Text(_buttonName, style: TextStyle(fontSize: 20.sp))),
        ),
      );
  }

  Widget _buildPages(String image, String title, String description, double width,
      double height,String currentLanguage) {
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    final bool isMobile = shortestSide < 600;
    return Column(
      // Aligns children horizontally at the center
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: isMobile ? height / 8 : height / 12,
        ),
        Text(
          title,
          style: TextStyle(fontSize: 50.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: height / 12,
        ),
        SizedBox(width: 230.h, height: 230.h, child: Image.asset(image,fit: BoxFit.cover,)),
        SizedBox(
          height: height / 12,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
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
}


