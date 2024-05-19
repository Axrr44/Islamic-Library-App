import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/utilities/constants.dart';
import '../config/app_colors.dart';
import '../config/app_routes.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    String currentLanguage = Localizations.localeOf(context).languageCode;


    return Material(
      color: AppColor.white.withOpacity(0.0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: width / 20),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    blurRadius: 8,
                    offset: Offset(1.w, 5.h))
              ]),
              width: width,
              height: height / 4 + 20.h,
              child: ListView.separated(
                separatorBuilder: (context, index) => SizedBox(width: 20.w),
                scrollDirection: Axis.horizontal,
                itemCount: 2,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.only(top: 7.h, bottom: 7.h),
                    width: width / 2,
                    height: height / 4 + 20.h,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(index == 0
                            ? AppRoutes.QURAN_SURA_ROUTES
                            : AppRoutes.BOOKS_ROUTES);
                      },
                      style: ButtonStyle(
                        overlayColor: MaterialStateProperty.all(index == 0 ? AppColor.white.withOpacity(0.1) :
                        AppColor.black.withOpacity(0.1)),
                        backgroundColor: MaterialStateProperty.all(
                            index == 0 ? AppColor.black : AppColor.white),
                        foregroundColor:
                            MaterialStateProperty.all(AppColor.white),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.w),
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(top: 20.h,bottom: 20.h,),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                index == 0
                                    ? Image.asset(
                                        "assets/images/textbook.png",
                                        color: AppColor.white,
                                        scale: 2.5,
                                      )
                                    : Icon(
                                        Icons.menu_book_rounded,
                                        color: AppColor.black,
                                        size: 50.w,
                                      ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  index == 0 ? AppLocalizations.of(context)!.quran :
                                  AppLocalizations.of(context)!.hadiths,
                                  style: TextStyle(
                                    fontFamily: Constants.getTextFamily(currentLanguage),
                                    color: index == 0 ? AppColor.white : AppColor.black,
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w700),
                                ),
                                Icon(Icons.arrow_forward_ios_rounded,color:
                                index == 0 ? AppColor.white : AppColor.black,
                                  size : 20.w,)
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              height: 20.h,
            ),
            Container(
              width: width,
              height: height / 4 + 20.h,
              margin: EdgeInsets.only(bottom: height / 25),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.TAFSEER_ROUTES);
                },
                style: ButtonStyle(
                  overlayColor: MaterialStateProperty.all(AppColor.black.withOpacity(0.1)),
                  backgroundColor: MaterialStateProperty.all(Colors.grey[300]),
                  foregroundColor: MaterialStateProperty.all(AppColor.white),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.w),
                    ),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.only(top: 20.h,bottom: 20.h),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.tafseer,
                            style: TextStyle(
                              color: AppColor.black,
                              fontSize: 30.sp,
                              fontWeight: FontWeight.w700
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 200.w,
                            child: Text(
                              "This is test for this button in this app",
                              style: TextStyle(
                                color: AppColor.primary5,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700
                              ),
                              textAlign: TextAlign.start,
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios_rounded,color: AppColor.black,size: 30.w,)
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
