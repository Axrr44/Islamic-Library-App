import 'dart:convert';
import 'package:arabic_numbers/arabic_numbers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/models/favorite_model.dart';
import 'package:freelancer/services/firestore_service.dart';
import 'package:freelancer/utilities/utility.dart';
import 'package:provider/provider.dart';
import 'package:quran/quran.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../config/app_colors.dart';
import '../config/toast_message.dart';
import '../models/tafseer_content.dart';
import '../providers/sub_search_provider.dart';
import '../services/app_data_pref.dart';
import '../config/app_languages.dart';
import '../models/tafseer_books.dart';
import 'package:quran/quran.dart' as quran;
import 'package:http/http.dart' as http;
import '../models/tafseer_response.dart';


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
  List<TafseerContent> _tafseerContents = [];
  int _currentVerseCount = 0;
  bool _isLoadingMore = false;
  late Future<void> _initialLoadFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initialLoadFuture = _loadInitialTafseerContents(Localizations.localeOf(context).languageCode);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    String currentLanguage = Localizations.localeOf(context).languageCode;
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    final bool isMobile = shortestSide < 600;
    final subSearchProvider = Provider.of<SubSearchProvider>(context,listen: false);

    return Scaffold(
      body: FutureBuilder<void>(
        future: _initialLoadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColor.primary1),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            if (widget.isScrollable!) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollToIndexIfNeeded(context);
              });
            }

            return NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      _header(currentLanguage, context, width, isMobile),
                      Padding(
                        padding: EdgeInsets.only(top: 20.h, left: 20.w, right: 20.w),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                onChanged: (query) {
                                    subSearchProvider.updateSearchQuery(query);
                                },
                                decoration: InputDecoration(
                                  hintText: AppLocalizations.of(context)!.search,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.w),
                                    borderSide: const BorderSide(color: Colors.black),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.w),
                                    borderSide: const BorderSide(color: Colors.black),
                                  ),
                                ),
                                style: const TextStyle(color: Colors.black),
                                cursorColor: AppColor.black,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            _loadMoreButton(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              body: Consumer<SubSearchProvider>(
                builder: (context, provider, _) {
                  List<TafseerContent> filteredTafseerContents = provider.filterTafseerContents(_tafseerContents);
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: widget.isScrollable!
                        ? ScrollablePositionedList.separated(
                      itemScrollController: _scrollController,
                      itemCount: filteredTafseerContents.length + 1,
                      itemBuilder: (context, index) {
                        if (index < filteredTafseerContents.length) {
                          return _listViewBuilder(context, currentLanguage, filteredTafseerContents[index]);
                        } else {
                          return const SizedBox.shrink();
                        }
                      },
                      separatorBuilder: (context, index) {
                        return _separatorTafseerItem(currentLanguage, filteredTafseerContents[index]);
                      },
                    )
                        : ListView.separated(
                      itemCount: filteredTafseerContents.length + 1,
                      itemBuilder: (context, index) {
                        if (index < filteredTafseerContents.length) {
                          return _listViewBuilder(context, currentLanguage, filteredTafseerContents[index]);
                        } else {
                          return const SizedBox.shrink();
                        }
                      },
                      separatorBuilder: (context, index) {
                        return _separatorTafseerItem(currentLanguage, filteredTafseerContents[index]);
                      },
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> _loadInitialTafseerContents(String currentLanguage) async {
    int initialLoadCount = _currentVerseCount + 50;
    int totalVerses = quran.getVerseCount(widget.surahId);

    if (initialLoadCount > totalVerses) {
      initialLoadCount = totalVerses;
    }

    await _loadTafseerContents(currentLanguage, 1, initialLoadCount);
    setState(() {
      _currentVerseCount = initialLoadCount;
    });
  }

  Future<void> _loadTafseerContents(String currentLanguage, int start, int end) async {
    List<TafseerContent> newContents = [];
    int totalVerses = quran.getVerseCount(widget.surahId);

    for (int verseNumber = start; verseNumber <= end && verseNumber <= totalVerses; verseNumber++) {
      final verseText = currentLanguage == Languages.EN.languageCode
          ? quran.getVerse(widget.surahId, verseNumber)
          : quran.getVerse(widget.surahId, verseNumber);
      final surahText = currentLanguage == Languages.EN.languageCode
          ? quran.getSurahName(widget.surahId)
          : quran.getSurahNameArabic(widget.surahId);
      final tafseerResponse = await _fetchTafseerData(widget.surahId, verseNumber);
      if (tafseerResponse != null) {
        newContents.add(TafseerContent(
          tafseerText: tafseerResponse.text,
          verseText: verseText,
          surahText: surahText,
          verseId: verseNumber,
          surahId: widget.surahId,
        ));
      }
    }

    setState(() {
      _tafseerContents.addAll(newContents);
    });
  }

  void _loadMoreTafseerContents() async {
    if (_isLoadingMore) return;
    setState(() {
      _isLoadingMore = true;
    });

    int newEnd = _currentVerseCount + 50;
    int totalVerses = quran.getVerseCount(widget.surahId);

    if (newEnd > totalVerses) {
      newEnd = totalVerses;
    }

    await _loadTafseerContents(Localizations.localeOf(context).languageCode, _currentVerseCount + 1, newEnd);

    setState(() {
      _currentVerseCount = newEnd;
      _isLoadingMore = false;
    });

    if (_currentVerseCount >= totalVerses) {
      debugPrint("All verses have been loaded.");
    }
  }

  Widget _loadMoreButton() {
    int totalVerses = quran.getVerseCount(widget.surahId);

    if (_currentVerseCount < totalVerses) {
      return IconButton(
        onPressed: _isLoadingMore ? (){ToastMessage.showMessage(_tafseerContents.length.toString());} :
        _loadMoreTafseerContents,
        icon: _isLoadingMore
            ? const CircularProgressIndicator(color: AppColor.primary1)
            : const Icon(Icons.add, color: AppColor.primary1),
        tooltip: 'Load More Verses',
      );
    } else {
      return const IconButton(
        onPressed: null,
        icon: Icon(Icons.check, color: AppColor.primary1),
        tooltip: 'All verses loaded',
      );
    }
  }


  Container _listViewBuilder(BuildContext context, String currentLanguage,
      TafseerContent tafseerContent) {
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    final bool isMobile = shortestSide < 600;
    final bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Container(
      margin: EdgeInsets.only(bottom: 15.h,
      top: tafseerContent.verseId == 1 ? 0 : 15.h ),
      height: isPortrait
          ? isMobile
          ? 50.h
          : 60.h
          : isMobile
          ? 50.w
          : 60.w,
      child: Card(
        color: AppColor.black,
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: 10.w, vertical: isPortrait ? 10.h : 20.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    currentLanguage == Languages.EN.languageCode
                        ? (tafseerContent.verseId).toString()
                        : ArabicNumbers.convert((tafseerContent.verseId).toString()),
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
                  Row(
                    children: [
                      Text(
                        widget.mufseer!.name,
                        style: TextStyle(
                          fontSize: widget.mufseer!.name.length >= 25
                              ? 7.sp
                              : 15.sp,
                          overflow: TextOverflow.ellipsis,
                          color: AppColor.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              _popUpMenu(tafseerContent,context, currentLanguage)
            ],
          ),
        ),
      ),
    );

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

  Card _separatorTafseerItem(String language,TafseerContent tafseerContent) {
    return Card(
      color: AppColor.white,
      child: Padding(
        padding: EdgeInsets.all(10.w),
        child: Column(
          children: [
            SizedBox(
              height: 5.h,
            ),
            Text(tafseerContent.verseText,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20.sp, fontFamily: 'Hafs'),
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
            Text(tafseerContent.tafseerText, textAlign: TextAlign.center, style: TextStyle(fontSize: 15.sp))
          ],
        ),
      ),
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

  Widget _popUpMenu(TafseerContent tafseerContent ,BuildContext context, String language) {
    return _buildPopupMenu(
        tafseerContent, language);
  }

  Widget _buildPopupMenu(TafseerContent tafseerContent , String language) {

    copy() {
      final value = ClipboardData(
        text: "${tafseerContent.verseText}[${tafseerContent.surahText}]\n\n\n\n${tafseerContent.tafseerText}",
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
                    copy();
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
                    await Share.share("${tafseerContent.verseText}[${tafseerContent.surahText}]\n\n\n\n${tafseerContent.tafseerText}");
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
                  onTap: () {
                    FireStoreService.addFavorite(Favorite(
                        type: "Tafseer",
                        title: widget.mufseer!.name,
                        content: "${tafseerContent.verseText}Split${tafseerContent.tafseerText}"));
                    ToastMessage.showMessage(
                        AppLocalizations.of(context)!.favoriteIt);
                  },
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
                        widget.mufseer!, widget.surahId, tafseerContent.verseId -1);
                    ToastMessage.showMessage(
                        AppLocalizations.of(context)!.save);
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


  Widget _header(String currentLanguage, BuildContext context, double width,
      bool isMobile) {
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
                      currentLanguage == Languages.EN.languageCode
                          ? Icons.keyboard_arrow_left_rounded
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
                  style: TextStyle(
                      fontSize: 25.sp,
                      fontWeight: FontWeight.bold,
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

}
