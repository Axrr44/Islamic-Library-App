import 'dart:convert';
import 'package:arabic_numbers/arabic_numbers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/utilities/utility.dart';
import 'package:quran/quran.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../config/app_colors.dart';
import '../config/toast_message.dart';
import '../services/app_data_pref.dart';
import '../config/app_languages.dart';
import '../models/tafseer_books.dart';
import 'package:quran/quran.dart' as quran;
import 'package:http/http.dart' as http;
import '../models/tafseer_content.dart';

class TafseerContentPage extends StatefulWidget {
  final Tafseer? mufseer;
  final int surahId;
  final int? indexOfScrollable;
  final bool? isScrollable;

  const TafseerContentPage({
    super.key,
    this.mufseer,
    required this.surahId,
    this.isScrollable = false,
    this.indexOfScrollable = -1,
  });

  @override
  State<TafseerContentPage> createState() => _TafseerContentPageState();
}

class _TafseerContentPageState extends State<TafseerContentPage> {
  final ItemScrollController _scrollController = ItemScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.isScrollable!) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToIndexIfNeeded(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    String currentLanguage = Localizations.localeOf(context).languageCode;
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    final bool isMobile = shortestSide < 600;

    return Scaffold(
        body: Container(
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverToBoxAdapter(
            child: _header(currentLanguage, context, width, isMobile),
          ),
        ],
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: widget.isScrollable!
              ? ScrollablePositionedList.separated(
                  itemScrollController: _scrollController,
                  itemCount: quran.getVerseCount(widget.surahId) + 1,
                  // Add one extra item for the last separator
                  itemBuilder: (context, index) {
                    if (index < quran.getVerseCount(widget.surahId)) {
                      return _listViewBuilder(index, context, currentLanguage);
                    } else {
                      return const SizedBox
                          .shrink(); // The last item is just for the separator
                    }
                  },
                  separatorBuilder: (context, index) {
                    return _separatorTafseerItem(index + 1, currentLanguage);
                  },
                )
              : ListView.separated(
                  itemCount: quran.getVerseCount(widget.surahId) + 1,
                  // Add one extra item for the last separator
                  itemBuilder: (context, index) {
                    if (index < quran.getVerseCount(widget.surahId)) {
                      return _listViewBuilder(index, context, currentLanguage);
                    } else {
                      return const SizedBox
                          .shrink(); // The last item is just for the separator
                    }
                  },
                  separatorBuilder: (context, index) {
                    return _separatorTafseerItem(index + 1, currentLanguage);
                  },
                ),
        ),
      ),
    ));
  }

  Container _listViewBuilder(
      int index, BuildContext context, String currentLanguage) {
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    final bool isMobile = shortestSide < 600;
    final bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    if (index < quran.getVerseCount(widget.surahId)) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 15.h),
        height: isPortrait == true
            ? isMobile == true
                ? 50.h
                : 60.h
            : isMobile == true
                ? 50.w
                : 60.w,
        child: Card(
          color: AppColor.black,
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: 10.w, vertical: isPortrait == true ? 10.h : 20.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      currentLanguage == Languages.EN.languageCode ? (index + 1).toString() : 
                      ArabicNumbers.convert((index + 1).toString()),
                      style: TextStyle(
                          fontSize: 15.sp,
                          color: AppColor.white,
                          fontWeight: FontWeight.w600),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.w),
                      child: VerticalDivider(
                        thickness: 3.w,
                        color: AppColor.white,
                      ),
                    ),
                    Text(
                      widget.mufseer!.name,
                      style: TextStyle(
                          fontSize:
                              widget.mufseer!.name.length <= 25 ? 15.sp : 10.sp,
                          color: AppColor.white,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                _popUpMenu(context, index + 1, index, currentLanguage)
              ],
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  void _scrollToIndexIfNeeded(BuildContext context) {
    if (widget.indexOfScrollable != null) {
      _scrollController.scrollTo(
        index: widget.indexOfScrollable!,
        duration: const Duration(seconds: 1),
        curve: Curves.easeInOut,
      );
    }
  }

  Card _separatorTafseerItem(int verse, String language) {
    return Card(
      color: AppColor.white,
      child: Padding(
        padding: EdgeInsets.all(10.w),
        child: Column(
          children: [
            SizedBox(
              height: 5.h,
            ),
            Text(
              language == Languages.EN.languageCode
                  ? quran.getVerseTranslation(
                      widget.surahId,
                      verse,
                      translation: Translation.enSaheeh,
                    )
                  : quran.getVerse(widget.surahId, verse),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20.sp),
            ),
            SizedBox(
              height: 20.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                    child: Divider(
                  thickness: 2.h,
                  color: AppColor.black,
                )),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Text(AppLocalizations.of(context)!.fseer),
                ),
                Expanded(
                    child: Divider(
                  thickness: 2.h,
                  color: AppColor.black,
                )),
              ],
            ),
            SizedBox(
              height: 10.h,
            ),
            _tafseer(verse)
          ],
        ),
      ),
    );
  }

  FutureBuilder<TafseerResponse?> _tafseer(int verse) {
    return FutureBuilder<TafseerResponse?>(
      future: _fetchTafseerData(widget.surahId, verse),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          TafseerResponse? tafseerResponse = snapshot.data;
          if (tafseerResponse != null) {
            String tafseerText = tafseerResponse.text;
            return Text(tafseerText,
                textAlign: TextAlign.center, style: TextStyle(fontSize: 15.sp));
          } else {
            return const Text('No Tafseer available');
          }
        }
      },
    );
  }

  Widget _popUpMenu(
      BuildContext context, int verse, int index, String language) {
    return FutureBuilder<TafseerResponse?>(
      future: _fetchTafseerData(widget.surahId, verse),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(color: AppColor.white);
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          TafseerResponse? tafseerResponse = snapshot.data;
          if (tafseerResponse != null) {
            return _buildPopupMenu(
                tafseerResponse.text, verse, index, language);
          } else {
            return const Text('No Tafseer available');
          }
        }
      },
    );
  }

  Widget _buildPopupMenu(
      String tafseerText, int verse, int index, String language) {
    String verseText = language == Languages.EN.languageCode
        ? quran.getVerseTranslation(
            widget.surahId,
            verse,
            translation: Translation.enSaheeh,
          )
        : quran.getVerse(widget.surahId, verse);

    copy(String textToCopy) {
      final value = ClipboardData(
        text: "$verseText\n\n\n\n$textToCopy",
      );
      Clipboard.setData(value);
      ToastMessage.showMessage("Text copied");
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(5.w),
      child: Container(
        alignment: Alignment.center,
        color: AppColor.white,
        child: PopupMenuButton(
          padding: EdgeInsets.zero,
          iconSize: 25.w,
          iconColor: AppColor.black,
          itemBuilder: (context) => [
            PopupMenuItem(
              child: Padding(
                padding: EdgeInsets.all(3.w),
                child: InkWell(
                  onTap: () {
                    copy(tafseerText);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        Icons.copy,
                        size: 15.w,
                        color: AppColor.black,
                      ),
                      Text(
                        AppLocalizations.of(context)!.copy,
                        style:
                            TextStyle(fontSize: 15.sp, color: AppColor.black),
                      )
                    ],
                  ),
                ),
              ),
            ),
            PopupMenuItem(
              child: Padding(
                padding: EdgeInsets.all(3.w),
                child: InkWell(
                  onTap: () async {
                    await Share.share("$verseText\n\n\n\n$tafseerText");
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        Icons.share,
                        size: 15.w,
                        color: AppColor.black,
                      ),
                      Text(
                        AppLocalizations.of(context)!.share,
                        style:
                            TextStyle(fontSize: 15.sp, color: AppColor.black),
                      )
                    ],
                  ),
                ),
              ),
            ),
            PopupMenuItem(
              child: Padding(
                padding: EdgeInsets.all(3.w),
                child: InkWell(
                  onTap: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        Icons.favorite,
                        size: 15.w,
                        color: AppColor.black,
                      ),
                      Text(
                        AppLocalizations.of(context)!.favorite,
                        style:
                            TextStyle(fontSize: 15.sp, color: AppColor.black),
                      )
                    ],
                  ),
                ),
              ),
            ),
            PopupMenuItem(
              child: Padding(
                padding: EdgeInsets.all(3.w),
                child: InkWell(
                  onTap: () {
                    AppDataPreferences.setTafseerLastRead(
                        widget.mufseer!, widget.surahId, index);
                    ToastMessage.showMessage("Save");
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        Icons.bookmark,
                        size: 15.w,
                        color: AppColor.black,
                      ),
                      Text(
                        AppLocalizations.of(context)!.mark,
                        style:
                            TextStyle(fontSize: 15.sp, color: AppColor.black),
                      )
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

  Widget _authorWidget(double width) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        height: 200.h,
        width: width,
        decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5.w,
                  blurRadius: 7.w,
                  offset: const Offset(1.5, 3))
            ],
            image: const DecorationImage(
                image: AssetImage("assets/images/islamic_book.jpg"),
                fit: BoxFit.fill),
            borderRadius: BorderRadius.circular(15.w)),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [
                    AppColor.black.withOpacity(0.85),
                    Colors.grey.withOpacity(0.85)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: const [0.2, 3]),
              borderRadius: BorderRadius.circular(15.w)),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Text(
              widget.mufseer!.author,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 20.sp,
                  color: AppColor.white,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(
      String currentLanguage, BuildContext context, double width, bool isMobile) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 50.h, right: 20.w, left: 20.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
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
                      currentLanguage == Languages.EN.languageCode ? Icons.keyboard_arrow_left_rounded
                      : Icons.keyboard_arrow_right_rounded,
                      size: 35.w,
                      color: AppColor.white,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 20.w,
              ),
              SizedBox(
                width: width / 2,
                child: Text(
                  textAlign: TextAlign.center,
                  currentLanguage == Languages.EN.languageCode
                      ? quran.getSurahNameEnglish(widget.surahId)
                      : quran.getSurahNameArabic(widget.surahId),
                  style:
                      TextStyle(fontSize: 25.sp, fontWeight: FontWeight.bold,
                      fontFamily: Utility.getTextFamily(currentLanguage)),
                ),
              )
            ],
          ),
        ),
        SizedBox(
          height: 50.h,
        ),
        _authorWidget(width)
      ],
    );
  }

  Future<TafseerResponse?> _fetchTafseerData(
      int surahId, int verseNumber) async {
    final response = await http.get(Uri.parse(
        'http://api.quran-tafseer.com/tafseer/${widget.mufseer!.id}/$surahId/$verseNumber'));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return TafseerResponse.fromJson(data);
    } else {
      return null;
    }
  }
}
