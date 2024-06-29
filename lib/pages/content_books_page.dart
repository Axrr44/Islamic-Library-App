import 'dart:convert';
import 'package:arabic_numbers/arabic_numbers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:islamiclibrary/models/favorite_model.dart';
import 'package:islamiclibrary/providers/sub_search_provider.dart';
import 'package:islamiclibrary/services/firestore_service.dart';
import 'package:islamiclibrary/utilities/utility.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:share_plus/share_plus.dart';
import '../components/custom_dialog.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../config/app_languages.dart';
import '../services/app_data.dart';
import '../config/app_colors.dart';
import '../services/app_data_pref.dart';
import '../config/toast_message.dart';
import '../models/hadith_model.dart';
import '../services/authentication.dart';

class ContentBooksPage extends StatefulWidget {
  final int bookId;
  final String bookName;
  final int? indexOfScrollable;
  final bool? isScrollable;
  final int chapterId;
  final bool? isFromFavorite;
  final bool? isChapter;

  const ContentBooksPage({
    super.key,
    required this.bookId,
    required this.bookName,
    this.indexOfScrollable = -1,
    this.isScrollable = false,
    required this.chapterId,
    this.isFromFavorite = false,
    this.isChapter = true,
  });

  @override
  State<ContentBooksPage> createState() => _ContentBooksPageState();
}

class _ContentBooksPageState extends State<ContentBooksPage> {
  final ItemScrollController _scrollController = ItemScrollController();
  final TextEditingController _searchController = TextEditingController();
  late SubSearchProvider _subSearchProvider;
  late Future _bookDataFuture;
  bool _isSearching = false;


  @override
  void initState() {
    super.initState();
    _bookDataFuture = AppData.getCurrentBook(widget.bookId);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _subSearchProvider = Provider.of<SubSearchProvider>(context, listen: false);
  }

  @override
  void dispose() {
    _subSearchProvider.updateSearchHadithQuery('',[]);
    _subSearchProvider.filteredHadiths.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    String currentLanguage = Localizations.localeOf(context).languageCode;
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    final bool isMobile = shortestSide < 600;

    return Scaffold(
      body: FutureBuilder(
        future: _bookDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppColor.primary1));
          } else {
            if (snapshot.hasError) {
              customDialog(context, snapshot.error.toString());
              return const SizedBox(width: 5); // Return an empty widget
            } else {
              Map<String, dynamic> data = jsonDecode(snapshot.data!);
              Metadata metadata = Metadata.fromJson(data);
              List<Hadith> hadiths = widget.isChapter!
                  ? getHadithsByChapterId(
                      parseHadiths(snapshot.data), widget.chapterId)
                  : parseHadiths(snapshot.data);
              List<Chapter> chapters = parseChapters(snapshot.data);

              _subSearchProvider.filteredHadiths = hadiths;

              if (widget.isScrollable!) {
                int index = hadiths.indexWhere(
                    (element) => element.idInBook == widget.indexOfScrollable);
                if (index == -1) {
                  index = widget.indexOfScrollable!;
                }
                if (widget.isFromFavorite!) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToIndexIfNeeded(context, index);
                  });
                } else {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToIndexIfNeeded(context, widget.indexOfScrollable!);
                  });
                }
              }

              return Column(
                children: [
                  _header(currentLanguage, metadata, context, width, isMobile),
                  Padding(
                    padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 20.h),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value){
                              if (value.trim().isNotEmpty) {
                                setState(() {
                                  _isSearching = true;
                                });
                              } else {
                                setState(() {
                                  _isSearching = false;
                                });
                              }
                            },
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(context)!.search,
                              prefixIcon:
                                  Icon(Icons.search, color: Colors.black, size: 20.w),
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
                        if(_isSearching)
                        SizedBox(width: 10.w,),
                        if(_isSearching)
                        IconButton(
                          onPressed: () async {
                            _subSearchProvider.updateSearchHadithQuery(_searchController.text,hadiths);
                          },
                          icon: Icon(
                            color: AppColor.white,
                            Icons.search_rounded,
                            size: 33.w,
                          ),
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(Colors.black),
                            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.w),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: Consumer<SubSearchProvider>(
                      builder: (context, subSearchProvider, _) {
                        final filteredHadiths =
                        subSearchProvider.filteredHadiths;
                        return subSearchProvider.isLoading ? const Center(child: CircularProgressIndicator(color: AppColor.primary1,)):Row(
                          children: [
                            Expanded(
                              child: _listOfHadiths(
                                  filteredHadiths, chapters, currentLanguage),
                            ),
                            if (filteredHadiths.length >= 10)
                              _buildScrollbar(filteredHadiths.length,
                                  filteredHadiths, currentLanguage),
                          ],
                        ) ;
                      },
                    )
                    ,
                  ),
                ],
              );
            }
          }
        },
      ),
    );
  }

  Widget _buildScrollbar(
      int itemCount, List<Hadith> filteredHadiths, String currentLanguage) {
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
                _scrollController.scrollTo(
                  index: scrollIndexes[index] - 1,
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeInOut,
                );
              },
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                child: Text(
                  '${currentLanguage == Languages.EN.languageCode ? (filteredHadiths[scrollIndexes[index]].idInBook)! - 1 : ArabicNumbers.convert((filteredHadiths[scrollIndexes[index]].idInBook)! - 1)} ',
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

  void _scrollToIndexIfNeeded(BuildContext context, int index) {
    if (widget.indexOfScrollable != null) {
      _scrollController.scrollTo(
        index: index,
        duration: const Duration(seconds: 1),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _authorWidget(
      String currentLanguage, Metadata metadata, double width) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Text(
          currentLanguage == Languages.EN.languageCode
              ? metadata.english!["author"]
              : metadata.arabic!["author"],
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 20.sp,
              color: AppColor.black,
              fontWeight: FontWeight.w700),
        ));
  }

  Widget _listOfHadiths(
      List<Hadith> hadiths, List<Chapter> chapters, String currentLanguage) {
    bool isEnglish = currentLanguage == Languages.EN.languageCode;
    bool isBiggerT10 = hadiths.length >= 10;
    return Padding(
      padding: EdgeInsets.only(
          right: isEnglish
              ? isBiggerT10
                  ? 0
                  : 20.w
              : 20.w,
          left: isEnglish
              ? 20.w
              : isBiggerT10
                  ? 0
                  : 20.w),
      child: ScrollablePositionedList.separated(
        itemScrollController: _scrollController,
        itemCount: hadiths.length + 1,
        itemBuilder: (context, index) {
          if (index < hadiths.length) {
            return _listViewBuilder(
              chapters,
              hadiths,
              index,
              currentLanguage,
              context,
            );
          } else {
            return const SizedBox.shrink(); // Separator
          }
        },
        separatorBuilder: (context, index) {
          return _listViewSeparator(currentLanguage, hadiths, index);
        },
      ),
    );
  }

  Card _listViewSeparator(
      String currentLanguage, List<Hadith> hadiths, int index) {
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
              currentLanguage == Languages.EN.languageCode
                  ? hadiths[index].english!
                  : hadiths[index].arabic!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20.sp),
            )
          ],
        ),
      ),
    );
  }

  Container _listViewBuilder(List<Chapter> chapters, List<Hadith> hadiths,
      int index, String currentLanguage, BuildContext context) {
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    final bool isMobile = shortestSide < 600;
    final bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    Chapter chapter = chapters.firstWhere(
        (element) => element.id == hadiths[index].chapterId,
        orElse: () =>
            Chapter(id: -1, bookId: -1, arabic: 'Unknown', english: 'Unknown'));

    return Container(
      margin: EdgeInsets.symmetric(vertical: 15.h),
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
                        ? (hadiths[index].idInBook).toString()
                        : ArabicNumbers.convert(hadiths[index].idInBook),
                    style: TextStyle(
                        fontFamily: Utility.getTextFamily(currentLanguage),
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
                        currentLanguage == Languages.EN.languageCode
                            ? chapter.english!.length >= 50
                                ? "${chapter.english!.substring(0, 47)}..."
                                : chapter.english!
                            : chapter.arabic!.length >= 50
                                ? "${chapter.arabic!.substring(0, 47)}..."
                                : chapter.arabic!,
                        style: TextStyle(
                          fontFamily: Utility.getTextFamily(currentLanguage),
                          fontSize:
                              (currentLanguage == Languages.EN.languageCode
                                          ? chapter.english!.length
                                          : chapter.arabic!.length) >=
                                      25
                                  ? 7.sp
                                  : 15.sp,
                          color: AppColor.white,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
              _popUpMenu(
                  context,
                  currentLanguage == Languages.EN.languageCode
                      ? hadiths[index].english!
                      : hadiths[index].arabic!,
                  index,
                  hadiths[index].idInBook)
            ],
          ),
        ),
      ),
    );
  }

  Widget _popUpMenu(
      BuildContext context, String hadith, int index, int? idInBook) {
    copy() {
      final value = ClipboardData(
        text:
            "$hadith[${AppData.getBookName(context, widget.bookId)}][${widget.bookName}/$idInBook]",
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
                              style: TextStyle(
                                  fontSize: 15.sp, color: AppColor.black),
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
                              "$hadith[${AppData.getBookName(context, widget.bookId)}][${widget.bookName}/$idInBook]");
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
                              style: TextStyle(
                                fontSize: 15.sp,
                                color: AppColor.black,
                              ),
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
                                AppLocalizations.of(context)!
                                    .favoriteToastMessage);
                            return;
                          }
                          FireStoreService.addFavorite(Favorite(
                              type: "Hadith",
                              title: widget.bookName,
                              content: hadith,
                              surahId: 0,
                              verseId: 0,
                              author: '',
                              bookName: widget.bookName,
                              hadithBookId: widget.bookId,
                              hadithChapterId: widget.chapterId,
                              hadithIdInBook: index,
                              tafseerId: 0,
                              tafseerName: ''));
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
                              style: TextStyle(
                                  fontSize: 15.sp, color: AppColor.black),
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
                          AppDataPreferences.setHadithLastRead(widget.bookId,
                              index, widget.chapterId, widget.bookName);
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
                              style: TextStyle(
                                  fontSize: 15.sp, color: AppColor.black),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ]),
      ),
    );
  }

  Widget _header(String currentLanguage, Metadata metadata,
      BuildContext context, double width, bool isMobile) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 50.h, right: 20.w, left: 20.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(isMobile == true ? 15.w : 10.w),
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
              Text(
                widget.bookName.length <= 20
                    ? widget.bookName
                    : "${widget.bookName.substring(0, 17)}...",
                style: TextStyle(
                    fontSize: widget.bookName.length < 20 ? 35.sp : 32.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'ATF'),
              )
            ],
          ),
        ),
        SizedBox(
          height: 40.h,
        ),
        _authorWidget(currentLanguage, metadata, width)
      ],
    );
  }

  List<Hadith> getHadithsByChapterId(List<Hadith> hadiths, int chapterId) {
    return hadiths.where((hadith) => hadith.chapterId == chapterId).toList();
  }
}
