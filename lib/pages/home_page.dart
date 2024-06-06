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
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    String currentLanguage = Localizations.localeOf(context).languageCode;

    return SingleChildScrollView(
      child: Material(
        color: AppColor.white.withOpacity(0.0),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: width / 20),
          child: Column(
            children: [
              SizedBox(
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
                        key: index == 0 ? quranKeyTutorial : hadithKeyTutorial,
                        onPressed: () {
                          Navigator.of(context).pushNamed(index == 0
                              ? AppRoutes.QURAN_SURA_ROUTES
                              : AppRoutes.BOOKS_ROUTES);
                        },
                        style: ButtonStyle(
                          overlayColor: WidgetStateProperty.all(index == 0
                              ? AppColor.white.withOpacity(0.1)
                              : AppColor.black.withOpacity(0.1)),
                          backgroundColor: WidgetStateProperty.all(index == 0
                              ? AppColor.primary1
                              : AppColor.white),
                          foregroundColor:
                              WidgetStateProperty.all(AppColor.white),
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.w),
                            ),
                          ),
                          padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 0))
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.w),
                            image: DecorationImage(
                              image: index == 0
                                  ? const AssetImage("assets/images/wave_lines_6.png")
                                  : const AssetImage("assets/images/wave_lines_4.png"),
                              colorFilter: index == 0
                                  ? null
                                  : ColorFilter.mode(
                                Colors.grey.withOpacity(0.15),
                                BlendMode.srcATop,
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),

                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.h,
                            horizontal: 20.w),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    index == 0
                                        ? SizedBox(
                                            width: 50.w,
                                            height: 50.w,
                                            child: Image.asset(
                                              "assets/images/quran.png",
                                              color: AppColor.white,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : Image.asset(
                                      "assets/images/hadith.png",
                                      color: AppColor.black,
                                      fit: BoxFit.cover,
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      index == 0
                                          ? AppLocalizations.of(context)!.quran
                                          : AppLocalizations.of(context)!.hadiths,
                                      style: TextStyle(
                                          fontFamily: 'AEFont',
                                          color: index == 0
                                              ? AppColor.white
                                              : AppColor.black,
                                          fontSize: 30.sp,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      color: index == 0
                                          ? AppColor.white
                                          : AppColor.black,
                                      size: 20.w,
                                    )
                                  ],
                                ),
                              ],
                            ),
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
                  key: tafseerKeyTutorial,
                  onPressed: () {
                    Navigator.of(context).pushNamed(AppRoutes.TAFSEER_ROUTES);
                  },
                  style: ButtonStyle(
                    overlayColor: WidgetStateProperty.all(
                        AppColor.black.withOpacity(0.1)),
                    backgroundColor: WidgetStateProperty.all(AppColor.primary6),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.w),
                      ),
                    ),
                      padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 0))
                  ),
                  child: Container(
                    decoration:  BoxDecoration(
                      borderRadius: BorderRadius.circular(20.w),
                      image: DecorationImage(
                        image: const AssetImage("assets/images/text_patter_2.png"),
                        colorFilter: ColorFilter.mode(
                        Colors.grey.withOpacity(0.1), BlendMode.srcATop),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.h,horizontal: 20.w),
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
                                    fontSize: 60.sp,
                                    fontWeight: FontWeight.w700,
                                    fontFamily:
                                        'AEFont'),
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
                                  AppLocalizations.of(context)!.tafseerDescription,
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w700),
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
            ],
          ),
        ),
      ),
    );
  }
}
