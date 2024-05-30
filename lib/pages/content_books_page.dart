import 'dart:convert';
import 'package:arabic_numbers/arabic_numbers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:freelancer/models/favorite_model.dart';
import 'package:freelancer/providers/sub_search_provider.dart';
import 'package:freelancer/services/firestore_service.dart';
import 'package:freelancer/utilities/utility.dart';
import 'package:loader_overlay/loader_overlay.dart';
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

class ContentBooksPage extends StatefulWidget {
  final int bookId;
  final String bookName;
  final int? indexOfScrollable;
  final bool? isScrollable;
  final int chapterId;

  ContentBooksPage({
    super.key,
    required this.bookId,
    required this.bookName,
    this.indexOfScrollable = -1,
    this.isScrollable = false,
    required this.chapterId,
  });

  @override
  State<ContentBooksPage> createState() => _ContentBooksPageState();
}

class _ContentBooksPageState extends State<ContentBooksPage> {
  final ItemScrollController _scrollController = ItemScrollController();

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    String currentLanguage = Localizations.localeOf(context).languageCode;
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    final bool isMobile = shortestSide < 600;
    final subSearchProvider = Provider.of<SubSearchProvider>(context, listen: false);

    return Scaffold(
      body: FutureBuilder(
        future: AppData.getCurrentBook(widget.bookId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            context.loaderOverlay.show();
            return const SizedBox(
              width: 5,
            ); // Return an empty widget
          } else {
            context.loaderOverlay.hide();
            if (snapshot.hasError) {
              customDialog(context, snapshot.error.toString());
              return const SizedBox(
                width: 5,
              ); // Return an empty widget
            } else {
              if (widget.isScrollable!) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToIndexIfNeeded(context);
                });
              }
              Map<String, dynamic> data = jsonDecode(snapshot.data!);
              Metadata metadata = Metadata.fromJson(data);
              List<Hadith> hadiths = getHadithsByChapterId(parseHadiths(snapshot.data), widget.chapterId);
              List<Chapter> chapters = parseChapters(snapshot.data);

              return NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  SliverToBoxAdapter(
                    child: Column(children: [
                      _header(
                          currentLanguage, metadata, context, width, isMobile),
                      Padding(
                        padding: EdgeInsets.only(left: 20.w,right: 20.w,top: 20.h),
                        child: TextField(
                          onChanged: (query) {
                            subSearchProvider.updateSearchQuery(query);
                          },
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!.search,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.w),
                              borderSide: const BorderSide(color: Colors.black), // Outline border color
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.w),
                              borderSide: const BorderSide(color: Colors.black),
                            ),
                          ),
                          style: const TextStyle(color: Colors.black),
                          cursorColor: AppColor.black,// Text color
                        ),
                      ),
                    ],),
                  ),
                ],
                body: _listOfHadiths(hadiths, chapters, currentLanguage)
                ,
              );
            }
          }
        },
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

  Widget _authorWidget(
      String currentLanguage, Metadata metadata, double width) {
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
              currentLanguage == Languages.EN.languageCode
                  ? metadata.english!["author"]
                  : metadata.arabic!["author"],
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

  Widget _listOfHadiths(
      List<Hadith> hadiths, List<Chapter> chapters, String currentLanguage) {
    return Consumer<SubSearchProvider>(
      builder: (context, subSearchProvider, _) {
        final filteredHadiths = subSearchProvider.filterHadiths(hadiths);
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: widget.isScrollable!
              ? ScrollablePositionedList.separated(
            itemScrollController: _scrollController,
            itemCount: filteredHadiths.length + 1,
            itemBuilder: (context, index) {
              if (index < filteredHadiths.length) {
                return _listViewBuilder(
                  chapters,
                  filteredHadiths,
                  index,
                  currentLanguage,
                  context,
                );
              } else {
                return const SizedBox.shrink(); // Separator
              }
            },
            separatorBuilder: (context, index) {
              return _listViewSeparator(
                  currentLanguage, filteredHadiths, index);
            },
          )
              : ListView.separated(
            itemCount: filteredHadiths.length + 1,
            itemBuilder: (context, index) {
              if (index < filteredHadiths.length) {
                return _listViewBuilder(
                  chapters,
                  filteredHadiths,
                  index,
                  currentLanguage,
                  context,
                );
              } else {
                return const SizedBox.shrink(); // Separator
              }
            },
            separatorBuilder: (context, index) {
              return _listViewSeparator(
                  currentLanguage, filteredHadiths, index);
            },
          ),
        );
      },
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
                        ? (index + 1).toString()
                        : ArabicNumbers.convert(index + 1),
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
                  index)
            ],
          ),
        ),
      ),
    );
  }

  Widget _popUpMenu(BuildContext context, String hadith, int index) {
    copy() {
      final value = ClipboardData(
        text: hadith,
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
                          await Share.share("$hadith[${AppData.getBookName(context, widget.bookId)}][${widget.bookName}]");
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
                          FireStoreService.addFavorite(Favorite(
                              type: "Hadith",
                              title: widget.bookName,
                              content: hadith));
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
                          AppDataPreferences.setHadithLastRead(
                              widget.bookId, index, widget.chapterId, widget.bookName);
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
                    fontSize: widget.bookName.length < 20 ? 25.sp : 22.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: Utility.getTextFamily(currentLanguage)),
              )
            ],
          ),
        ),
        SizedBox(
          height: 50.h,
        ),
        _authorWidget(currentLanguage, metadata, width)
      ],
    );
  }

  List<Hadith> getHadithsByChapterId(List<Hadith> hadiths, int chapterId) {
    return hadiths.where((hadith) => hadith.chapterId == chapterId).toList();
  }
}
