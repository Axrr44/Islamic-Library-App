import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../config/app_colors.dart';
import '../config/app_routes.dart';

class ViewPager extends StatefulWidget {
  const ViewPager({super.key});

  @override
  State<ViewPager> createState() => _ViewPagerState();
}

class _ViewPagerState extends State<ViewPager> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  String _buttonName = "Next";

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
    return Container(
        child: PageView(
          onPageChanged: (int page) {
            setState(() {
              // Update button name based on current page
              _currentPage = page;
              _buttonName = _currentPage != 2 ? "Next" : "Let's go";
            });
          },
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            Center(
              child: _buildPages("assets/images/destination.png", "Page 1",
                  "this is test for description in page 1", width, height),
            ),
            Center(
              child: _buildPages("assets/images/photography.png", "Page 2",
                  "this is test for description in page 2", width, height),
            ),
            Center(
              child: _buildPages("assets/images/travel.png", "Page 3",
                  "this is test for description in page 3", width, height),
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
                if (_currentPage != 2) {
                  _pageController.animateToPage(++_currentPage,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut);
                } else {
                  Navigator.of(context)
                      .pushReplacementNamed(AppRoutes.MAIN_ROUTES);
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
      double height) {
    return Column(
      // Aligns children horizontally at the center
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: height / 8,
        ),
        Text(
          title,
          style: TextStyle(fontSize: 50.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: height / 1000,
        ),
        SizedBox(width: width, height: height / 2, child: Image.asset(image)),
        SizedBox(
          height: height / 1000,
        ),
        Text(
          description,
          style: TextStyle(fontSize: 15.sp),
        )
      ],
    );
  }
}


