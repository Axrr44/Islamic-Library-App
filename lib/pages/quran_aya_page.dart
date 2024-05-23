import 'dart:async';
import 'dart:convert';
import 'package:arabic_numbers/arabic_numbers.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:freelancer/components/custom_appbar.dart';
import 'package:freelancer/config/app_colors.dart';
import 'package:freelancer/providers/tafseer_dialog_provider.dart';
import 'package:freelancer/services/app_data_pref.dart';
import 'package:freelancer/utilities/utility.dart';
import 'package:provider/provider.dart';
import 'package:quran/quran.dart' as quran;
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';
import '../components/custom_dialog.dart';
import '../config/app_languages.dart';
import '../models/quran_model.dart';
import '../models/reciter_model.dart';
import '../models/tafseer_books.dart';
import '../providers/quran_aya_page_provider.dart';
import '../services/app_data.dart';

class QuranAyaPage extends StatefulWidget {
  final int surahId;
  final int initialPage;

  const QuranAyaPage(
      {super.key, required this.surahId, required this.initialPage});

  @override
  State<QuranAyaPage> createState() => _QuranAyaPageState();
}

class _QuranAyaPageState extends State<QuranAyaPage> {
  late PageController _pageController;
  late List<Reciter> _reciters;
  bool showExtraWidget = false;
  int surahIdLastRead = 0;
  List<int> listOfSurah = [];
  int verseIdLastRead = 0;
  AudioPlayer audioPlayer = AudioPlayer();
  double _maxSliderValue = 10000;
  bool _isPlay = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialPage);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToPage(widget.initialPage);
    });
    audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      setState(() {
        _isPlay = state == PlayerState.playing;
      });
    });
    audioPlayer.onDurationChanged.listen((Duration duration) {
      setState(() {
        _maxSliderValue = duration.inSeconds.toDouble();
      });
    });
    audioPlayer.onPositionChanged.listen((Duration position) {
      final sliderValueProvider =
          Provider.of<QuranAyaPageProvider>(context, listen: false);
      sliderValueProvider.updateSliderValue(position.inSeconds.toDouble());
    });
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    String currentLanguage = Localizations.localeOf(context).languageCode;
    if (currentLanguage == Languages.EN.languageCode) {
      _reciters = await AppData.fetchAndFilterReciters("eng");
    } else {
      _reciters = await AppData.fetchAndFilterReciters("ar");
    }
    if (_reciters.isNotEmpty) {
      final sliderValueProvider =
          Provider.of<QuranAyaPageProvider>(context, listen: false);
      sliderValueProvider.updateSelectedReciter(_reciters.first);
    }
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
    final quranProvider =
        Provider.of<QuranAyaPageProvider>(context, listen: false);

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    String currentLanguage = Localizations.localeOf(context).languageCode;
    final bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    final bool isMobile = shortestSide < 600;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (quranProvider.highlightedAyah == -1) {
            showExtraWidget ? showExtraWidget = false : showExtraWidget = true;
          }
        });
        quranProvider.clearHighlight();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        extendBody: true,
        appBar: showExtraWidget
            ? _appBar(isMobile, currentLanguage, width)
            : const PreferredSize(preferredSize: Size.zero, child: SizedBox()),
        body: PageView.builder(
          controller: _pageController,
          itemCount: quran.totalPagesCount,
          itemBuilder: (context, page) {
            return FutureBuilder<QuranData>(
              future: fetchPageData(page + 1),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.black),
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData) {
                  return const SizedBox();
                } else {
                  final quranData = snapshot.data!;
                  int lastIndex = quranData.ayahs.length - 1;
                  var lastAyah = quranData.ayahs[lastIndex];
                  bool isCenterPage = page == 0 || page == 1;
                  surahIdLastRead = quranData.ayahs.last.surah.number;
                  verseIdLastRead = quranData.ayahs.last.numberInSurah;
                  bool isFirst = true;
                  quranData.surahs.forEach((key, value) {
                    if (listOfSurah.length < quranData.surahs.length) {
                      if (quranData.ayahs.first.numberInSurah == 1) {
                        listOfSurah.add(value.number);
                      } else {
                        if (isFirst) {
                          isFirst = false;
                          return;
                        }
                        listOfSurah.add(value.number);
                      }
                    }
                  });
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
                                  top: 40.h, right: 20.w, left: 20.w),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                          : 'ArabicFont',
                                    ),
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
                                          : 'ArabicFont',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 15.w, vertical: 15.h),
                              child: Column(
                                mainAxisAlignment: isCenterPage
                                    ? MainAxisAlignment.center
                                    : MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Consumer<QuranAyaPageProvider>(
                                    builder: (context, quranProvider, _) {
                                      return RichText(
                                        textAlign: TextAlign.center,
                                        text: TextSpan(
                                          children: buildTextSpans(
                                              context,
                                              quranData,
                                              page,
                                              currentLanguage,
                                              isPortrait,
                                              quranProvider),
                                        ),
                                      );
                                    },
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
            setState(() {});
          },
        ),
        bottomNavigationBar: showExtraWidget
            ? _bottomBar(isMobile, currentLanguage, width, quranProvider)
            : const SizedBox.shrink(),
      ),
    );
  }

  PreferredSizeWidget _appBar(
      bool isMobile, String currentLanguage, double width) {
    String getDataByPage() {
      List<String> versesList = [];
      quran
          .getVersesTextByPage(
              quran.getPageNumber(surahIdLastRead, verseIdLastRead))
          .forEach((element) {
        versesList.add(element);
      });
      return versesList.join(" ");
    }

    copy() {
      String verses = getDataByPage();
      final value = ClipboardData(
        text: verses,
      );
      Clipboard.setData(value);
      Fluttertoast.showToast(
        msg: "Text copied",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.black,
        fontSize: 16.sp,
      );
    }

    return CustomAppBar(
        alignment: isMobile ? Alignment.bottomCenter : Alignment.center,
        height: isMobile ? 70.h : 60.h,
        color: Colors.grey.withOpacity(0.2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back,
                  size: 20.w,
                )),
            SizedBox(
              width: width / 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                      onPressed: () {
                        copy();
                      },
                      icon: Icon(
                        Icons.copy,
                        size: 20.w,
                      )),
                  IconButton(
                      onPressed: () {
                        Share.share(getDataByPage());
                      },
                      icon: Icon(
                        Icons.share,
                        size: 20.w,
                      )),
                  IconButton(
                      onPressed: () {
                        AppDataPreferences.setQuranLastRead(
                            surahIdLastRead, verseIdLastRead);
                      },
                      icon: Icon(
                        Icons.bookmark_outline_rounded,
                        size: 20.w,
                      )),
                ],
              ),
            )
          ],
        ));
  }

  PreferredSizeWidget _bottomBar(bool isMobile, String currentLanguage,
      double width, QuranAyaPageProvider quranProvider) {
    return CustomAppBar(
        alignment: Alignment.center,
        height: 100.h,
        color: Colors.grey.withOpacity(0.2),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: width - 20.w,
                child: Row(
                  children: [
                    IconButton(
                        color: AppColor.primary1,
                        onPressed: () {
                          _isPlay ? _pause() : playAllSurahsInOrder();
                        },
                        icon: Icon(
                          _isPlay ? Icons.pause : Icons.play_arrow,
                          size: 30.w,
                        )),
                    Expanded(
                      child: Consumer<QuranAyaPageProvider>(
                        builder: (context, sliderValueProvider, _) {
                          return Slider(
                            value: sliderValueProvider.currentSliderValue,
                            min: 0.0,
                            max: _maxSliderValue,
                            onChanged: null,
                            activeColor: AppColor.primary1,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 5.h),
                child: const Divider(
                  color: Colors.grey,
                ),
              ),
              Consumer<QuranAyaPageProvider>(
                  builder: (context, quranProvider, _) {
                return TextButton(
                    onPressed: () {
                      _showRecitersDialog(currentLanguage, quranProvider);
                    },
                    child: Text(
                      quranProvider.selectedReciter?.name ??
                          AppLocalizations.of(context)!.reciter,
                      style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColor.primary1),
                    ));
              })
            ],
          ),
        ));
  }

  List<InlineSpan> buildTextSpans(
      BuildContext context,
      QuranData quranData,
      int currentPage,
      String currentLanguage,
      bool isPortrait,
      QuranAyaPageProvider quranProvider) {
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

        if (currentPage != 0) {
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
      if (ayah.numberInSurah == 1 &&
          currentLanguage != Languages.EN.languageCode &&
          currentPage != 0) {
        ayahText = ayahText
            .replaceFirst('بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ', '')
            .trim();
      }

      spans.add(
        TextSpan(
            text: " $ayahText ",
            style: TextStyle(
                fontFamily: currentLanguage == Languages.EN.languageCode
                    ? 'EnglishQuran'
                    : 'Hafs',
                fontSize: currentLanguage == Languages.EN.languageCode
                    ? 17.sp
                    : 20.sp,
                color: Colors.black,
                height: 1.5.h,
                backgroundColor:
                    ayah.numberInSurah == quranProvider.highlightedAyah
                        ? AppColor.primary7
                        : Colors.transparent),
            recognizer: LongPressGestureRecognizer()
              ..onLongPress = () {
                quranProvider.updateHighlightAyah(ayah.numberInSurah);
                _onLongPressDialog(ayah);
              }),
      );

      // Add the end of ayah
      spans.add(TextSpan(
          text: currentLanguage == Languages.EN.languageCode
              ? "\uFD3E${ayah.numberInSurah}\uFD3F"
              : "${ArabicNumbers.convert(ayah.numberInSurah)}",
          style: TextStyle(
              fontSize:
                  currentLanguage == Languages.EN.languageCode ? 20.sp : 30.sp,
              fontFamily: "Hafs",
              fontWeight: currentLanguage == Languages.EN.languageCode
                  ? FontWeight.normal
                  : FontWeight.bold)));
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

  void _showRecitersDialog(
      String currentLanguage, QuranAyaPageProvider quranProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: SizedBox(
            width: 200.w,
            height: 350.w,
            child: ListView.separated(
              itemCount: _reciters.length,
              itemBuilder: (context, index) {
                return SizedBox(
                  height: 50.h,
                  child: TextButton(
                    style: ButtonStyle(
                      overlayColor: MaterialStateProperty.all(
                          AppColor.primary1.withOpacity(0.1)),
                    ),
                    onPressed: () {
                      quranProvider.updateSelectedReciter(_reciters[index]);
                      Navigator.of(context).pop();
                      setState(() {});
                    },
                    child: Text(
                      _reciters[index].name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: currentLanguage == Languages.EN.languageCode
                            ? 'Custom'
                            : 'ArabicFont',
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: const Divider(color: Colors.grey),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _onLongPressDialog(Ayah ayah) {
    final ayahText = quran.getVerse(ayah.surah.number, ayah.numberInSurah);
    copy() {
      final value = ClipboardData(
        text: ayahText,
      );
      Clipboard.setData(value);
      Fluttertoast.showToast(
        msg: "Text copied",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.black,
        fontSize: 16.sp,
      );
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: SizedBox(
            width: 200.w,
            height: 285.w,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                        _showBottomSheet(ayah, ayahText);
                      },
                      child: ListTile(
                        leading: Text(
                          AppLocalizations.of(context)!.fseer,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20.sp,
                          ),
                        ),
                        trailing: Icon(
                          Icons.my_library_books_rounded,
                          size: 30.w,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const Divider(
                      color: Colors.grey,
                    ),
                    InkWell(
                      onTap: () {
                        copy();
                        Navigator.of(context).pop();
                      },
                      child: ListTile(
                        leading: Text(
                          "Copy",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20.sp,
                          ),
                        ),
                        trailing: Icon(
                          Icons.copy,
                          size: 30.w,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const Divider(
                      color: Colors.grey,
                    ),
                    InkWell(
                      onTap: () {
                        Share.share(ayahText);
                        Navigator.of(context).pop();
                      },
                      child: ListTile(
                        leading: Text(
                          AppLocalizations.of(context)!.share,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20.sp,
                          ),
                        ),
                        trailing: Icon(
                          Icons.share,
                          size: 30.w,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const Divider(
                      color: Colors.grey,
                    ),
                    InkWell(
                      onTap: () {},
                      child: ListTile(
                        leading: Text(
                          AppLocalizations.of(context)!.favorite,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20.sp,
                          ),
                        ),
                        trailing: Icon(
                          Icons.favorite,
                          size: 30.w,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _play(int surahId, QuranAyaPageProvider quranProvider) async {
    String path = quranProvider.selectedReciter!.moshaf.first.server;
    if (quranProvider.selectedReciter!.moshaf.length >= 2 &&
        (quranProvider.selectedReciter!.id == 123 ||
            quranProvider.selectedReciter!.id == 112)) {
      path = quranProvider.selectedReciter!.moshaf[1].server;
    }
    if (quranProvider.selectedReciter != null) {
      String audioUrl = "${path}${Utility.formatNumber(surahId)}.mp3";
      try {
        await audioPlayer.play(UrlSource(audioUrl));
      } catch (e) {
        print("Error playing audio: $e");
      }
    } else {
      print("No reciter selected.");
    }
  }

  void playAllSurahsInOrder() async {
    for (int surahId in listOfSurah) {
      await _playSurahAndWait(surahId);
    }
  }

  Future<void> _playSurahAndWait(int surahId) async {
    final completer = Completer<void>();
    final quranProvider =
        Provider.of<QuranAyaPageProvider>(context, listen: false);
    audioPlayer.onPlayerComplete.listen((_) {
      completer.complete();
    });

    await _play(surahId, quranProvider);

    await completer.future;
  }

  void _showBottomSheet(Ayah ayah, String ayahText) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    String currentLanguage = Localizations.localeOf(context).languageCode;
    final tafseerProvider =
        Provider.of<TafseerDialogProvider>(context, listen: false);
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return SizedBox(
              height: height / 2 + 50.h,
              width: width,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.fseer,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 25.sp),
                      ),
                      SizedBox(
                        height: 20.h,
                      ),
                      Text(
                        ayahText,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 25.sp,
                            fontFamily:
                                currentLanguage == Languages.EN.languageCode
                                    ? "EnglishQuran"
                                    : "Hafs"),
                      ),
                      Padding(
                        padding: EdgeInsets.all(20.w),
                        child: const Divider(color: Colors.grey),
                      ),
                      _listOfTafseer(currentLanguage, tafseerProvider)
                    ],
                  ),
                ),
              ));
        });
  }

  FutureBuilder<List<Tafseer>> _listOfTafseer(
      String currentLanguage, TafseerDialogProvider provider) {
    return FutureBuilder<List<Tafseer>>(
      future: AppData.fetchTafseerData(currentLanguage),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          CircularProgressIndicator(
            color: AppColor.primary1,
          );
          return Container();
        }
        else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        else {
          List<Tafseer>? tafseerList = snapshot.data;
          if (tafseerList != null && tafseerList.isNotEmpty) {
            return Consumer<TafseerDialogProvider>(builder: (context,provider,_){
              return Container(
                height: 50.h,
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
                    value: provider.mufseer =
                    tafseerList[provider.indexOfTafseer],
                    onChanged: (Tafseer? newValue) {
                      for (var tafseer in tafseerList) {
                        if (tafseer.name == newValue!.name) {
                          provider
                              .setIndexOfMufseer(tafseerList.indexOf(tafseer));
                          provider.mufseer = tafseerList[provider.indexOfTafseer];
                        }
                      }
                    },
                    itemHeight: 50.h,
                    items: tafseerList.map<DropdownMenuItem<Tafseer>>(
                          (Tafseer value) {
                        return DropdownMenuItem<Tafseer>(
                          value: value,
                          child: Center(
                            child: Text(
                              value.name.toString(),
                              style: TextStyle(
                                  fontSize: 15.sp, color: AppColor.black),
                            ),
                          ),
                        );
                      },
                    ).toList(),
                  ),
                ),
              );
            });
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

  void _pause() {
    audioPlayer.pause();
  }
}
