import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/config/app_languages.dart';
import 'package:freelancer/pages/tafseer_conent_page.dart';
import 'package:loader_overlay/loader_overlay.dart';
import '../config/app_colors.dart';
import '../models/tafseer_books.dart';
import '../services/app_data.dart';
import '../services/app_data_pref.dart';

class TafseerPage extends StatefulWidget {
  const TafseerPage({super.key});

  @override
  State<TafseerPage> createState() => _TafseerPageState();
}

class _TafseerPageState extends State<TafseerPage> {
  late Future<List<Tafseer>> _tafseerListFuture;
  late Future<List<String>> _surahListSurah;
  int _indexOfTafseer = 0;
  Tafseer _mufseer = Tafseer.empty();
  int _indexOfSurah = 0;

  late int _surahId;
  late Tafseer _mufseerLastRead;
  late int _indexOfScrolling;



  @override
  void initState() {
    super.initState();
    _loadTafseerData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    String currentLanguage = Localizations.localeOf(context).languageCode;
    _tafseerListFuture = AppData.fetchTafseerData(currentLanguage);
    _surahListSurah = AppData.fetchSurahData(currentLanguage);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    String currentLanguage = Localizations.localeOf(context).languageCode;
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
        child: Column(
          children: [
            _header(width, height, context,isMobile,currentLanguage),
            Container(
              height: 400.h,
              padding: EdgeInsets.symmetric(horizontal: 40.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _listOfTafseer(),
                  _listOfSurah(),
                  SizedBox(
                    width: width / 2,
                    height: isMobile ? 50.h : 60.h,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                        MaterialStateProperty.all(AppColor.primary1),
                        foregroundColor:
                        MaterialStateProperty.all(AppColor.white),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.w),
                          ),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => TafseerContentPage(
                              surahId: _indexOfSurah + 1,
                              mufseer: _mufseer,
                            )));
                      },
                      child: Text(
                        "Tafseer",
                        style: TextStyle(fontSize: 20.sp),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadTafseerData() async {
    _surahId = await AppDataPreferences.getTafseerSurahId();
    _mufseerLastRead = await AppDataPreferences.getTafseerMufseer();
    _indexOfScrolling = await AppDataPreferences.getTafseerIndex();
  }


  FutureBuilder<List<Tafseer>> _listOfTafseer() {
    return FutureBuilder<List<Tafseer>>(
      future: _tafseerListFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          context.loaderOverlay.show();
          return Container();
        } else if (snapshot.hasError) {
          context.loaderOverlay.hide();
          return Text('Error: ${snapshot.error}');
        } else {
          context.loaderOverlay.hide();
          List<Tafseer>? tafseerList = snapshot.data;
          if (tafseerList != null && tafseerList.isNotEmpty) {
            return Container(
              height: 100.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  border: Border.all(color: AppColor.black, width: 1.w),
                  borderRadius: BorderRadius.circular(5.w)),
              child: SizedBox(
                height: double.infinity,
                child: DropdownButton<Tafseer>(
                  hint: Text(
                    "Select tafseer",
                    style: TextStyle(fontSize: 15.sp),
                  ),
                  iconSize: 0,
                  underline: Container(),
                  isExpanded: true,
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  value: _mufseer = tafseerList[_indexOfTafseer],
                  onChanged: (Tafseer? newValue) {
                    setState(() {
                      for (var tafseer in tafseerList) {
                        if (tafseer.name == newValue!.name) {
                          _indexOfTafseer = tafseerList.indexOf(tafseer);
                          _mufseer = tafseerList[_indexOfTafseer];
                        }
                      }
                    });
                  },
                  itemHeight: 100.h,
                  items: tafseerList.map<DropdownMenuItem<Tafseer>>(
                    (Tafseer value) {
                      return DropdownMenuItem<Tafseer>(
                        value: value,
                        child: Center(
                          child: Text(
                            value.name.toString(),
                            style: TextStyle(
                                fontSize: 25.sp, color: AppColor.black),
                          ),
                        ),
                      );
                    },
                  ).toList(),
                ),
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

  FutureBuilder<List<String>> _listOfSurah() {
    return FutureBuilder<List<String>>(
      future: _surahListSurah,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          context.loaderOverlay.show();
          return Container();
        } else if (snapshot.hasError) {
          context.loaderOverlay.hide();
          return Text('Error: ${snapshot.error}');
        } else {
          context.loaderOverlay.hide();
          List<String>? surahList = snapshot.data;
          if (surahList != null && surahList.isNotEmpty) {
            return Container(
              height: 100.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  border: Border.all(color: AppColor.black, width: 1.w),
                  borderRadius: BorderRadius.circular(5.w)),
              child: SizedBox(
                height: double.infinity,
                child: DropdownButton<String>(
                  hint: Text(
                    "Select surah",
                    style: TextStyle(fontSize: 15.sp),
                  ),
                  iconSize: 0,
                  underline: Container(),
                  isExpanded: true,
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  value: surahList[_indexOfSurah],
                  onChanged: (String? newValue) {
                    setState(() {
                      for (var surah in surahList) {
                        if (surah == newValue!) {
                          _indexOfSurah = surahList.indexOf(surah);
                        }
                      }
                    });
                  },
                  itemHeight: 100.h,
                  items: surahList.map<DropdownMenuItem<String>>(
                        (String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Center(
                          child: Text(
                            textAlign: TextAlign.center,
                            value,
                            style: TextStyle(
                                fontSize: 25.sp, color: AppColor.black),
                          ),
                        ),
                      );
                    },
                  ).toList(),
                ),
              ),
            );
          } else {
            return Center(
              child: Text(
                'No Surah data available',
                style: TextStyle(fontSize: 30.sp),
              ),
            );
          }
        }
      },
    );
  }

  Widget _header(double width, double height, BuildContext context,bool isMobile,String currentLanguage) {
    return Container(
      width: width,
      height: isMobile ? height / 3 : height / 2 - 100,
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
                  borderRadius: BorderRadius.circular(isMobile ? 15.w : 10.w),
                  child: Container(
                    color: AppColor.primary1,
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        currentLanguage == Languages.EN.languageCode ?
                        Icons.keyboard_arrow_left_rounded : Icons.keyboard_arrow_right_rounded,
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
                      "Tafseer",
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
                  borderRadius: BorderRadius.circular(isMobile == true ? 15.w : 10.w),
                  child: Container(
                    color: AppColor.primary1,
                    child: IconButton(
                        onPressed: () async{
                          await _loadTafseerData();
                          if(_indexOfTafseer != -1)
                            {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => TafseerContentPage(
                                    mufseer: _mufseerLastRead,
                                    surahId: _surahId,
                                    isScrollable: true,
                                    indexOfScrollable: _indexOfScrolling,
                                  )));
                            }
                        },
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
}
