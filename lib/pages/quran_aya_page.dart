import 'dart:convert';
import 'package:arabic_numbers/arabic_numbers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quran/quran.dart' as quran;
import 'package:http/http.dart' as http;
import '../components/custom_dialog.dart';
import '../config/app_languages.dart';
import '../models/quran_model.dart';
import '../services/app_data.dart';

class QuranAyaPage extends StatefulWidget {
  final int surahId;
  final int initialPage;

  const QuranAyaPage({super.key, required this.surahId, required this.initialPage});

  @override
  State<QuranAyaPage> createState() => _QuranAyaPageState();
}

class _QuranAyaPageState extends State<QuranAyaPage> {

  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialPage);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToPage(widget.initialPage);
    });
  }

  void scrollToPage(int pageIndex) {
    _pageController.animateToPage(
      pageIndex,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }


  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    String currentLanguage = Localizations.localeOf(context).languageCode;
    final bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        itemCount: quran.totalPagesCount,
        itemBuilder: (context, page) {
          return FutureBuilder<QuranData>(
            future: fetchPageData(page + 1), // Page numbers start from 1
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(color: Colors.black));
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                final quranData = snapshot.data!;
                int lastIndex = quranData.ayahs.length - 1;
                var lastAyah = quranData.ayahs[lastIndex];
                bool isCenterPage = page == 0 || page == 1;


                return SafeArea(
                  child: SingleChildScrollView(
                    child: Container(
                      constraints: BoxConstraints(minHeight: height),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                                top: 10.h, right: 10.w, left: 10.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  currentLanguage == Languages.EN.languageCode
                                      ? "Juz : ${lastAyah.juz}"
                                      : AppData.getJuz(lastAyah.juz),
                                  style: TextStyle(
                                      fontSize: 15.sp,
                                      fontFamily: currentLanguage ==
                                              Languages.EN.languageCode
                                          ? 'EnglishQuran'
                                          : 'ArabicFont'),
                                ),
                                Text(
                                  currentLanguage == Languages.EN.languageCode
                                      ? lastAyah.surah.englishName
                                      : quran.getSurahNameArabic(
                                          lastAyah.surah.number),
                                  style: TextStyle(
                                      fontSize: 15.sp,
                                      fontFamily: currentLanguage ==
                                              Languages.EN.languageCode
                                          ? 'EnglishQuran'
                                          : 'ArabicFont'),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15.w ,vertical: 15 .h),
                            child: Column(
                              mainAxisAlignment: isCenterPage
                                  ? MainAxisAlignment.center
                                  : MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    children: buildTextSpans(context, quranData,
                                        page, currentLanguage, isPortrait),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(10.h),
                            child: Text(
                              currentLanguage == Languages.EN.languageCode
                                  ? (page + 1).toString()
                                  : ArabicNumbers.convert(
                                      (page + 1).toString()),
                              style: TextStyle(fontSize: 15.sp),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }

  List<InlineSpan> buildTextSpans(BuildContext context, QuranData quranData,
      int currentPage, String currentLanguage, bool isPortrait) {
    List<InlineSpan> spans = [];


    for (var ayah in quranData.ayahs) {
      if (ayah.numberInSurah == 1) {
        // Add the surah banner
        spans.add(
          WidgetSpan(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 5.h),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SvgPicture.asset(
                    "assets/images/surah_banner.svg",
                    height: isPortrait ? 40.h : 40.w,
                  ),
                  Text(
                    currentLanguage == Languages.EN.languageCode
                        ? ayah.surah.englishName
                        : ayah.surah.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.sp,
                      fontFamily: currentLanguage == Languages.EN.languageCode
                          ? 'EnglishQuran'
                          : 'Hafs',
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

          if(currentPage != 0){
            spans.add(
              WidgetSpan(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(bottom: 5.h),
                  child: Text(
                    "بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontFamily: 'Hafs',
                    ),
                  ),
                ),
              ),
            );
          }

      }

      // Add the ayah text
      String ayahText = ayah.text;
      if (ayah.numberInSurah == 1 && currentLanguage != Languages.EN.languageCode && currentPage != 0) {
        ayahText = ayahText.replaceFirst('بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ', '').trim();
      }

      spans.add(
        TextSpan(
          text: " $ayahText ",
          style: TextStyle(
            fontFamily: currentLanguage == Languages.EN.languageCode ? 'EnglishQuran' : 'Hafs',
            fontSize: currentLanguage == Languages.EN.languageCode ? 17.sp : 20.sp,
            color: Colors.black,
            height: 1.5.h,
          ),
        ),
      );

      // Add the end of ayah
      spans.add(
        TextSpan(text: currentLanguage == Languages.EN.languageCode ?
        "\uFD3E${ayah.numberInSurah}\uFD3F" : "${ArabicNumbers.convert(ayah.numberInSurah)}",
        style: TextStyle(fontSize: currentLanguage == Languages.EN.languageCode
            ? 20.sp : 30.sp,fontFamily: "Hafs",fontWeight: currentLanguage == Languages.EN.languageCode
        ? FontWeight.normal : FontWeight.bold))
      );
    }
    return spans;
  }



  double getFontSize(String surahName) {
    return surahName.length <= 20 ? 20.sp : 15.sp;
  }

  Future<QuranData> fetchPageData(int pageCount) async {
    String currentLanguage = Localizations.localeOf(context).languageCode;
    final response = await http.get(Uri.parse(
        'https://api.alquran.cloud/v1/page/$pageCount/'
        '${currentLanguage == Languages.EN.languageCode ? 'en.asad' : 'quran-uthmani'}'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(utf8.decode(response.bodyBytes));
      return QuranData.fromJson(jsonData);
    } else {
      customDialog(context, "No internet connection");
      return Future.error('Failed to fetch data');
    }
  }
}
