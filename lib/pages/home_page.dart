import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../config/app_colors.dart';
import '../config/app_routes.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomePage extends StatelessWidget {
  final GlobalKey quranKeyTutorial;
  final GlobalKey hadithKeyTutorial;
  final GlobalKey tafseerKeyTutorial;

  const HomePage({
    super.key,
    required this.quranKeyTutorial,
    required this.hadithKeyTutorial,
    required this.tafseerKeyTutorial,
  });

  @override
  Widget build(BuildContext context) {

    double width = MediaQuery
        .of(context)
        .size
        .width;

    double height = MediaQuery
        .of(context)
        .size
        .height;

    String currentLanguage = Localizations
        .localeOf(context)
        .languageCode;

    return SingleChildScrollView(
      child: Material(
        color: AppColor.white.withOpacity(0.0),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: width / 20),
          child: Column(
            children: [
              SizedBox(
                width: width,
                height: height / 4 - 30.h,
                child: ElevatedButton(
                  key: quranKeyTutorial,
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed(AppRoutes.QURAN_SURA_ROUTES);
                  },
                  style: ButtonStyle(
                      overlayColor: WidgetStateProperty.all(
                          AppColor.black.withOpacity(0.1)),
                      backgroundColor:
                      WidgetStateProperty.all(AppColor.primary8),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.w),
                        ),
                      ),
                      padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(horizontal: 0))),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.w),
                      image: DecorationImage(
                        image:
                        const AssetImage("assets/images/text_patter_2.png"),
                        colorFilter: ColorFilter.mode(
                            Colors.grey.withOpacity(0.1), BlendMode.srcATop),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 20.h, horizontal: 20.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.quran,
                                style: TextStyle(
                                    color: AppColor.white,
                                    fontSize: 40.sp,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'AEFont'),
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
                                  AppLocalizations.of(context)!
                                      .quranButtonSubTitle,
                                  style: TextStyle(
                                      color: Colors.grey[300],
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: AppColor.white,
                                size: 30.w,
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20.h,
              ),
              SizedBox(
                width: width,
                height: height / 4 - 30.h,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 150.w,
                        child: ElevatedButton(
                          key: tafseerKeyTutorial,
                          onPressed: () {
                            Navigator.of(context)
                                .pushNamed(AppRoutes.TAFSEER_ROUTES);
                          },
                          style: ButtonStyle(
                              overlayColor: WidgetStateProperty.all(
                                  AppColor.white.withOpacity(0.1)),
                              backgroundColor:
                              WidgetStateProperty.all(AppColor.primary1),
                              foregroundColor:
                              WidgetStateProperty.all(AppColor.white),
                              shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.w),
                                ),
                              ),
                              padding: WidgetStateProperty.all(
                                  const EdgeInsets.symmetric(horizontal: 0))),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.w),
                              image: const DecorationImage(
                                image: AssetImage(
                                    "assets/images/wave_lines_6.png"),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 20.h, horizontal: 20.w),
                              child: Column(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 50.w,
                                        height: 50.w,
                                        child: Image.asset(
                                          "assets/images/quran.png",
                                          color: AppColor.white,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)!.tafseer,
                                        style: TextStyle(
                                            fontFamily: 'AEFont',
                                            color: AppColor.white,
                                            fontSize: 20.sp,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        color: AppColor.white,
                                        size: 20.w,
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 20.w,
                      ),
                      SizedBox(
                        width: 150.w,
                        child: ElevatedButton(
                          key: hadithKeyTutorial,
                          onPressed: () {
                            Navigator.of(context)
                                .pushNamed(AppRoutes.BOOKS_ROUTES);
                          },
                          style: ButtonStyle(
                              overlayColor: WidgetStateProperty.all(
                                  AppColor.black.withOpacity(0.1)),
                              backgroundColor:
                              WidgetStateProperty.all(AppColor.white),
                              shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.w),
                                ),
                              ),
                              padding: WidgetStateProperty.all(
                                  const EdgeInsets.symmetric(horizontal: 0))),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.w),
                              image: DecorationImage(
                                image: const AssetImage(
                                    "assets/images/wave_lines_4.png"),
                                colorFilter: ColorFilter.mode(
                                  Colors.grey.withOpacity(0.15),
                                  BlendMode.srcATop,
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 20.h, horizontal: 20.w),
                              child: Column(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Image.asset(
                                        "assets/images/hadith.png",
                                        color: AppColor.black,
                                        fit: BoxFit.cover,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)!.hadiths,
                                        style: TextStyle(
                                            fontFamily: 'AEFont',
                                            color: AppColor.black,
                                            fontSize: 20.sp,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        color: AppColor.black,
                                        size: 20.w,
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 20.h,
              ),
              SizedBox(
                width: width,
                height: height / 4 - 30.h,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 150.w,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ButtonStyle(
                              overlayColor: WidgetStateProperty.all(
                                  AppColor.black.withOpacity(0.1)),
                              backgroundColor:
                              WidgetStateProperty.all(AppColor.white),
                              foregroundColor:
                              WidgetStateProperty.all(AppColor.white),
                              shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.w),
                                ),
                              ),
                              padding: WidgetStateProperty.all(
                                  const EdgeInsets.symmetric(horizontal: 0))),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.w),
                              image: DecorationImage(
                                image: const AssetImage(
                                    "assets/images/wave_lines_4.png"),
                                colorFilter: ColorFilter.mode(
                                  Colors.grey.withOpacity(0.15),
                                  BlendMode.srcATop,
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 20.h, horizontal: 20.w),
                              child: Column(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 50.w,
                                        height: 50.w,
                                        child: Image.asset(
                                          "assets/images/beads.png",
                                          color: AppColor.black,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)!.azkar,
                                        style: TextStyle(
                                            fontFamily: 'AEFont',
                                            color: AppColor.black,
                                            fontSize: 20.sp,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        color: AppColor.black,
                                        size: 20.w,
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 20.w,
                      ),
                      SizedBox(
                        width: 150.w,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ButtonStyle(
                              overlayColor: WidgetStateProperty.all(
                                  AppColor.white.withOpacity(0.1)),
                              backgroundColor:
                              WidgetStateProperty.all(AppColor.primary1),
                              foregroundColor:
                              WidgetStateProperty.all(AppColor.white),
                              shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.w),
                                ),
                              ),
                              padding: WidgetStateProperty.all(
                                  const EdgeInsets.symmetric(horizontal: 0))),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.w),
                              image: const DecorationImage(
                                image: AssetImage(
                                    "assets/images/wave_lines_6.png"),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 20.h, horizontal: 20.w),
                              child: Column(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 50.w,
                                        height: 50.w,
                                        child: Image.asset(
                                          "assets/images/reading_book.png",
                                          color: AppColor.white,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        width: 80.w,
                                        child: Text(
                                          AppLocalizations.of(context)!
                                              .storiesOfProphets,
                                          style: TextStyle(
                                              fontFamily: 'AEFont',
                                              color: AppColor.white,
                                              fontSize:  17.sp,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        color: AppColor.white,
                                        size: 20.w,
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 20.h,
              ),
              SizedBox(
                width: width,
                height: height / 4 - 30.h,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ButtonStyle(
                      overlayColor: WidgetStateProperty.all(
                          AppColor.black.withOpacity(0.1)),
                      backgroundColor:
                      WidgetStateProperty.all(AppColor.primary6),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.w),
                        ),
                      ),
                      padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(horizontal: 0))),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.w),
                      image: DecorationImage(
                        image:
                        const AssetImage("assets/images/allah_akbar.png"),
                        colorFilter: ColorFilter.mode(
                            Colors.grey[300]!.withOpacity(0.005), BlendMode.srcATop),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 20.h, horizontal: 20.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.qiblahAndPrayer,
                                style: TextStyle(
                                    color: AppColor.black,
                                    fontSize: 30.sp ,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'AEFont'),
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
                                  AppLocalizations.of(context)!
                                      .qiblahButtonSubTitle,
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: AppColor.black,
                                size: 30.w,
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20.h,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
