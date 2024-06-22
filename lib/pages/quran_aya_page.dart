import 'dart:async';
import 'dart:convert';
import 'package:arabic_numbers/arabic_numbers.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:islamiclibrary/components/custom_appbar.dart';
import 'package:islamiclibrary/config/app_colors.dart';
import 'package:islamiclibrary/config/toast_message.dart';
import 'package:islamiclibrary/models/favorite_model.dart';
import 'package:islamiclibrary/providers/tafseer_dialog_provider.dart';
import 'package:islamiclibrary/services/app_data_pref.dart';
import 'package:islamiclibrary/services/authentication.dart';
import 'package:islamiclibrary/services/firestore_service.dart';
import 'package:islamiclibrary/utilities/utility.dart';
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
import '../models/tafseer_response.dart';
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

  @override
  void dispose() {
    audioPlayer.stop();
    audioPlayer.dispose();
    _pageController.dispose();
    super.dispose();
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
    final bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    final bool isMobile = shortestSide < 600;

    return GestureDetector(
      onTap: () {
        final quranProvider =
            Provider.of<QuranAyaPageProvider>(context, listen: false);
        if (quranProvider.highlightedAyah == -1) {
          quranProvider.updateExtraWidget();
        }
        quranProvider.clearHighlight();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        extendBody: true,
        body: Column(
          children: [
            Consumer<QuranAyaPageProvider>(
              builder: (context, quranProvider, _) {
                return quranProvider.showExtraWidget
                    ? _appBar(isMobile, currentLanguage, width)
                    : const PreferredSize(
                        preferredSize: Size.zero, child: SizedBox());
              },
            ),
            _quranPages(height, currentLanguage, isPortrait),
            Consumer<QuranAyaPageProvider>(
              builder: (context, quranProvider, _) {
                return quranProvider.showExtraWidget
                    ? _bottomBar(
                        isMobile, currentLanguage, width, quranProvider)
                    : const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Expanded _quranPages(double height, String currentLanguage, bool isPortrait) {
    return Expanded(
      child: PageView.builder(
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
                return const Center(
                    child: Text('Error: No internet connection'));
              } else if (!snapshot.hasData) {
                return const SizedBox();
              } else {
                final quranData = snapshot.data!;
                int lastIndex = quranData.ayahs.length - 1;
                var lastAyah = quranData.ayahs[lastIndex];
                bool isCenterPage = page == 0 || page == 1;
                surahIdLastRead = quranData.ayahs.last.surah.number;
                verseIdLastRead = quranData.ayahs.last.numberInSurah;

                listOfSurah.clear();
                bool isFirst = true;
                for (var entry in quranData.surahs.entries) {
                  var key = entry.key;
                  var value = entry.value;
                  if (!listOfSurah.contains(value.number)) {
                    if (quranData.ayahs.first.numberInSurah == 1) {
                      listOfSurah.add(value.number);
                    } else {
                      if (quranData.surahs.length >= 2) {
                        if (isFirst) {
                          isFirst = false;
                          continue; // Skip this iteration
                        }
                      }
                      listOfSurah.add(value.number);
                    }
                  }
                }

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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  currentLanguage == Languages.EN.languageCode
                                      ? "Juz : ${lastAyah.juz}"
                                      : AppData.getJuz(lastAyah.juz),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25.sp,
                                    fontFamily: 'ATF',
                                  ),
                                ),
                                Text(
                                  currentLanguage == Languages.EN.languageCode
                                      ? lastAyah.surah.englishName
                                      : quran.getSurahNameArabic(
                                          lastAyah.surah.number),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25.sp,
                                    fontFamily: 'ATF',
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
        },
      ),
    );
  }

  PreferredSizeWidget _appBar(
      bool isMobile, String currentLanguage, double width) {
    String getDataByPage() {
      List<String> versesText = [];
      quran
          .getVersesTextByPage(
              quran.getPageNumber(surahIdLastRead, verseIdLastRead),
              verseEndSymbol: true)
          .forEach((element) {
        versesText.add(element);
      });
      return versesText.join("");
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
                      onPressed: () async {
                        await Share.share(
                            "${getDataByPage()}[${currentLanguage == Languages.EN.languageCode ? quran.getSurahName(surahIdLastRead) : quran.getSurahNameArabic(surahIdLastRead)}]");
                      },
                      icon: Icon(
                        Icons.share,
                        size: 20.w,
                      )),
                  IconButton(
                      onPressed: () {
                        AppDataPreferences.setQuranLastRead(
                            surahIdLastRead, verseIdLastRead);
                        ToastMessage.showMessage(
                            AppLocalizations.of(context)!.save);
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
                    (ayah.numberInSurah == quranProvider.highlightedAyah) &&
                            (ayah.surah.number ==
                                quranProvider.ayahHighlightedInSurah)
                        ? AppColor.primary7
                        : Colors.transparent),
            recognizer: LongPressGestureRecognizer()
              ..onLongPress = () {
                quranProvider.updateHighlightAyah(
                    ayah.numberInSurah, ayah.surah.number);
                _onLongPressDialog(ayah);
              }),
      );

      // Add the end of ayah
      spans.add(TextSpan(
          text: Utility.isTheSameLanguage(currentLanguage, "ar")
          ? ArabicNumbers.convert(ayah.numberInSurah) : "\uFD3E${ayah.numberInSurah}\uFD3F",
          style: TextStyle(
              color: Colors.black,
              fontSize:
                  Utility.isTheSameLanguage(currentLanguage, 'ar') ? 30.sp : 20.sp,
              fontFamily: currentLanguage == Languages.EN.languageCode
                  ? 'EnglishQuran'
                  : 'Hafs',
              fontWeight: Utility.isTheSameLanguage(currentLanguage, 'ar')
                  ? FontWeight.bold
                  : FontWeight.normal)));
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
        '${Utility.getQuranIdentifier(currentLanguage)}'));
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
    String currentLanguage = Localizations.localeOf(context).languageCode;
    bool isEnglish = currentLanguage == Languages.EN.languageCode;
    String ayahText = "";
    if (isEnglish) {
      ayahText =
          quran.getVerseTranslation(ayah.surah.number, ayah.numberInSurah);
    } else {
      ayahText = quran.getVerse(ayah.surah.number, ayah.numberInSurah);
    }

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
                      onTap: () async {
                        await Share.share(
                            "$ayahText[${currentLanguage == Languages.EN.languageCode ? quran.getSurahName(surahIdLastRead) : quran.getSurahNameArabic(surahIdLastRead)}]");
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
                      onTap: () {
                        if (AuthServices.getCurrentUser() == null) {
                          ToastMessage.showMessage(AppLocalizations.of(context)!
                              .favoriteToastMessage);
                          return;
                        }
                        FireStoreService.addFavorite(Favorite(
                            type: "Quran",
                            title: isEnglish
                                ? quran.getSurahNameEnglish(ayah.surah.number)
                                : quran.getSurahNameArabic(ayah.surah.number),
                            content: ayahText,
                            surahId: ayah.surah.number,
                            verseId: ayah.numberInSurah,
                            author: '',
                            bookName: '',
                            hadithBookId: 0,
                            hadithChapterId: 0,
                            hadithIdInBook: 0,
                            tafseerId: 0,
                            tafseerName: ''));
                        ToastMessage.showMessage(
                            AppLocalizations.of(context)!.favoriteIt);
                      },
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
      String audioUrl = "$path${Utility.formatNumber(surahId)}.mp3";
      try {
        await audioPlayer.play(UrlSource(audioUrl));
      } catch (e) {
        print("Error playing audio: $e");
      }
    } else {
      print("No reciter selected.");
    }
  }

  void _pause() {
    audioPlayer.pause();
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
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
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
                      fontFamily: currentLanguage == Languages.EN.languageCode
                          ? "EnglishQuran"
                          : "Hafs",
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(20.w),
                    child: const Divider(color: Colors.grey),
                  ),
                  Consumer<TafseerDialogProvider>(
                    builder: (context, provider, _) {
                      return _listOfTafseer(currentLanguage, tafseerProvider);
                    },
                  ),
                  SizedBox(
                    height: 50.h,
                  ),
                  Consumer<TafseerDialogProvider>(
                    builder: (context, provider, _) {
                      return _tafseerAyah(ayah, provider);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  FutureBuilder<TafseerResponse?> _tafseerAyah(
      Ayah ayah, TafseerDialogProvider tafseerProvider) {
    String currentLanguage = Localizations.localeOf(context).languageCode;
    return FutureBuilder(
      future: _fetchTafseerData(
          ayah.surah.number,
          ayah.numberInSurah,
          currentLanguage == Languages.EN.languageCode
              ? tafseerProvider.indexOfTafseer == 0
                  ? 9
                  : 10
              : tafseerProvider.mufseer.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(
            color: AppColor.primary1,
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          TafseerResponse? tafseer = snapshot.data;
          if (tafseer != null) {
            return Text(
              tafseer.text,
              style: TextStyle(fontSize: 15.sp, height: 1.5.h),
              textAlign: TextAlign.center,
            );
          } else {
            return Center(
              child: Text(
                textAlign: TextAlign.center,
                'No Tafseer data available',
                style: TextStyle(fontSize: 30.sp),
              ),
            );
          }
        }
      },
    );
  }

  FutureBuilder<List<Tafseer>> _listOfTafseer(
      String currentLanguage, TafseerDialogProvider provider) {
    return FutureBuilder<List<Tafseer>>(
      future: AppData.fetchTafseerData(currentLanguage),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(
            color: AppColor.primary1,
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          List<Tafseer>? tafseerList = snapshot.data;
          if (tafseerList != null && tafseerList.isNotEmpty) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.arrow_drop_down_circle_outlined,
                  size: 30.w,
                ),
                SizedBox(
                  width: 20.w,
                ),
                Container(
                  height: 50.h,
                  width: 230.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColor.black, width: 1.w),
                    borderRadius: BorderRadius.circular(5.w),
                  ),
                  child: SizedBox(
                    height: double.infinity,
                    width: 200.w,
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
                        if (newValue != null) {
                          provider.mufseer = newValue;
                          provider
                              .setIndexOfMufseer(tafseerList.indexOf(newValue));
                        }
                      },
                      itemHeight: 50.h,
                      items: tafseerList
                          .map<DropdownMenuItem<Tafseer>>((Tafseer value) {
                        return DropdownMenuItem<Tafseer>(
                          value: value,
                          child: Center(
                            child: Text(
                              value.name,
                              style: TextStyle(
                                  fontSize: 15.sp, color: AppColor.black),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                )
              ],
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

  Future<TafseerResponse?> _fetchTafseerData(
      int surahId, int verseNumber, int mufseerId) async {
    final response = await http.get(Uri.parse(
      'http://api.quran-tafseer.com/tafseer/$mufseerId/$surahId/$verseNumber',
    ));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return TafseerResponse.fromJson(data);
    } else {
      return null;
    }
  }
}
