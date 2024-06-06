import 'dart:convert';
import 'package:arabic_numbers/arabic_numbers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/models/favorite_model.dart';
import 'package:freelancer/services/firestore_service.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../config/app_colors.dart';
import '../config/toast_message.dart';
import '../models/tafseer_content.dart';
import '../providers/sub_search_provider.dart';
import '../services/DatabaseHelper.dart';
import '../services/app_data_pref.dart';
import '../config/app_languages.dart';
import '../models/tafseer_books.dart';
import 'package:quran/quran.dart' as quran;
import 'package:http/http.dart' as http;
import '../models/tafseer_response.dart';
import '../services/authentication.dart';

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
  final List<TafseerContent> _tafseerContents = [];
  late Future<void> _initialLoadFuture;
  int _downloadProgress = 0;
  bool _isDataFromDb = true;
  late SubSearchProvider _subSearchProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_tafseerContents.isEmpty) {
      _initialLoadFuture = _loadInitialTafseerContents(
          Localizations.localeOf(context).languageCode);
    }
    _subSearchProvider = Provider.of<SubSearchProvider>(context, listen: false);
  }

  @override
  void dispose() {
    _subSearchProvider.updateSearchQuery('');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String currentLanguage = Localizations.localeOf(context).languageCode;
    return Scaffold(
      body: FutureBuilder<void>(
        future: _initialLoadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingIndicator();
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return _buildContent(currentLanguage);
          }
        },
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: _isDataFromDb
          ? const CircularProgressIndicator(color: AppColor.primary1)
          : _buildDownloadProgressIndicator(),
    );
  }

  Widget _buildDownloadProgressIndicator() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sim_card_download_rounded,size: 150.w,),
          SizedBox(height: 20.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: _downloadProgress / 100,
                    color: AppColor.primary1,
                  ),
                ),
                SizedBox(width: 10.w),
                Icon(
                  Icons.download, // Download icon
                  color: AppColor.primary1,
                  size: 20.w,
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            '${AppLocalizations.of(context)!.loadingTafseer} $_downloadProgress%',
            style: TextStyle(fontSize: 15.sp, color: Colors.grey),
          ),
          SizedBox(height: 50.h),
          Text(
            AppLocalizations.of(context)!.descriptionOfTafseerLoading,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20.sp, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(String currentLanguage) {
    double width = MediaQuery.of(context).size.width;
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    final bool isMobile = shortestSide < 600;

    if (widget.isScrollable!) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToIndexIfNeeded();
      });
    }

    return Column(
      children: [
        _header(currentLanguage, context, width, isMobile),
        _buildSearchField(context),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Consumer<SubSearchProvider>(
                  builder: (context, provider, _) {
                    List<TafseerContent> filteredTafseerContents =
                        provider.filterTafseerContents(_tafseerContents);
                    return _buildScrollableList(
                        filteredTafseerContents, currentLanguage);
                  },
                ),
              ),
              if(quran.getVerseCount(widget.surahId) >= 10)
              _buildScrollbar(_tafseerContents.length, currentLanguage),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScrollbar(int itemCount, String currentLanguage) {
    List<int> scrollIndexes = List<int>.generate(
        (itemCount / 10).ceil(), (index) => index == 0 ? 1 : index * 10);

    return SizedBox(
      width: 40.w,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        child: ListView.builder(
          itemCount: scrollIndexes.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                int scrollIndex =
                    (scrollIndexes[index] - 1).clamp(0, itemCount - 1);
                _scrollController.scrollTo(
                  index: scrollIndex,
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeInOut,
                );
              },
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                child: Text(
                  '${currentLanguage == Languages.EN.languageCode ? scrollIndexes[index] : ArabicNumbers.convert(scrollIndexes[index])}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.bold),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(top: 20.h, left: 20.w, right: 20.w, bottom: 20.h),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (query) {
                _subSearchProvider.updateSearchQuery(query);
              },
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.search,
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.black,
                  size: 20.w,
                ),
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
        ],
      ),
    );
  }

  Widget _buildScrollableList(
      List<TafseerContent> contents, String currentLanguage) {
    bool isBiggerT10 = quran.getVerseCount(widget.surahId) >= 10;
    bool isEnglish = currentLanguage == Languages.EN.languageCode;
    return Padding(
      padding: EdgeInsets.only(
          right: isEnglish ? isBiggerT10 ? 0 : 20.w  : 20.w,
          left: isEnglish? 20.w :
          isBiggerT10 ? 0 : 20.w ),
      child: ScrollablePositionedList.separated(
        itemScrollController: _scrollController,
        itemCount: contents.length + 1,
        itemBuilder: (context, index) {
          if (index < contents.length) {
            return _listViewBuilder(context, currentLanguage, contents[index]);
          } else {
            return const SizedBox.shrink();
          }
        },
        separatorBuilder: (context, index) {
          return _separatorTafseerItem(currentLanguage, contents[index]);
        },
      ),
    );
  }

  Future<void> _loadInitialTafseerContents(String currentLanguage) async {
    List<TafseerContent> savedContents = await DatabaseHelper()
        .getTafseerContents(widget.surahId, widget.mufseer!.id);
    if (savedContents.isNotEmpty) {
      setState(() {
        _isDataFromDb = true;
        _tafseerContents.addAll(savedContents);
      });
    } else {
      setState(() {
        _isDataFromDb = false;
      });
      int totalVerses = quran.getVerseCount(widget.surahId);
      await _loadTafseerContents(currentLanguage, 1, totalVerses);
    }
  }

  Future<void> _loadTafseerContents(
      String currentLanguage, int start, int end) async {
    List<TafseerContent> newContents = [];
    int totalVerses = quran.getVerseCount(widget.surahId);
    int totalToLoad = end - start + 1;

    for (int verseNumber = start;
        verseNumber <= end && verseNumber <= totalVerses;
        verseNumber++) {
      final verseText = currentLanguage == Languages.EN.languageCode
          ? quran.getVerseTranslation(widget.surahId, verseNumber)
          : quran.getVerse(widget.surahId, verseNumber);
      final surahText = currentLanguage == Languages.EN.languageCode
          ? quran.getSurahName(widget.surahId)
          : quran.getSurahNameArabic(widget.surahId);
      final tafseerResponse =
          await _fetchTafseerData(widget.surahId, verseNumber);
      if (tafseerResponse != null) {
        TafseerContent content = TafseerContent(
            tafseerText: tafseerResponse.text,
            verseText: verseText,
            surahText: surahText,
            verseId: verseNumber,
            surahId: widget.surahId,
            tafseerId: widget.mufseer?.id);
        newContents.add(content);
        await DatabaseHelper().insertTafseerContent(content);
      }
      setState(() {
        _downloadProgress =
            ((verseNumber - start + 1) / totalToLoad * 100).toInt();
      });
    }

    setState(() {
      _tafseerContents.addAll(newContents);
    });
  }

  Container _listViewBuilder(BuildContext context, String currentLanguage,
      TafseerContent tafseerContent) {
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    final bool isMobile = shortestSide < 600;
    final bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Container(
      margin: EdgeInsets.only(
          bottom: 15.h, top: tafseerContent.verseId == 1 ? 0 : 15.h),
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
                        : ArabicNumbers.convert(
                            (tafseerContent.verseId).toString()),
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
                          fontSize:
                              widget.mufseer!.name.length >= 25 ? 7.sp : 15.sp,
                          overflow: TextOverflow.ellipsis,
                          color: AppColor.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              _popUpMenu(tafseerContent, context, currentLanguage)
            ],
          ),
        ),
      ),
    );
  }

  void _scrollToIndexIfNeeded() {
    if (widget.indexOfScrollable != null) {
      _scrollController.scrollTo(
        index: widget.indexOfScrollable!,
        duration: const Duration(seconds: 1),
        curve: Curves.easeInOut,
      );
    }
  }

  Card _separatorTafseerItem(String language, TafseerContent tafseerContent) {
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
              tafseerContent.verseText,
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
            Text(tafseerContent.tafseerText,
                textAlign: TextAlign.center, style: TextStyle(fontSize: 15.sp))
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

  Widget _popUpMenu(
      TafseerContent tafseerContent, BuildContext context, String language) {
    return _buildPopupMenu(tafseerContent, language);
  }

  Widget _buildPopupMenu(TafseerContent tafseerContent, String language) {
    copy() {
      final value = ClipboardData(
        text:
            "${tafseerContent.verseText}[${tafseerContent.surahText}]\n\n\n\n${tafseerContent.tafseerText}",
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
                    await Share.share(
                        "${tafseerContent.verseText}[${tafseerContent.surahText}]\n\n\n\n${tafseerContent.tafseerText}");
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
                    if (AuthServices.getCurrentUser() == null) {
                      ToastMessage.showMessage(
                          AppLocalizations.of(context)!.favoriteToastMessage);
                      return;
                    }
                    FireStoreService.addFavorite(
                      Favorite(
                          type: "Tafseer",
                          title: widget.mufseer!.name,
                          content:
                              "${tafseerContent.verseText}Split${tafseerContent.tafseerText}",
                          surahId: tafseerContent.surahId,
                          verseId: tafseerContent.verseId,
                          author: widget.mufseer!.author,
                          bookName: widget.mufseer!.bookName,
                          hadithBookId: 0,
                          hadithChapterId: 0,
                          hadithIdInBook: 0,
                          tafseerId: widget.mufseer!.id,
                          tafseerName: widget.mufseer!.name),
                    );
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
                    AppDataPreferences.setTafseerLastRead(widget.mufseer!,
                        widget.surahId, tafseerContent.verseId - 1);
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
      child: Text(
        widget.mufseer!.author,
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: 20.sp,
            color: AppColor.black,
            fontWeight: FontWeight.w700),
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
                      fontSize: 45.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'ATF'),
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
