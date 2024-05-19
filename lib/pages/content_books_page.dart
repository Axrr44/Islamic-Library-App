import 'dart:convert';
import 'package:arabic_numbers/arabic_numbers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:freelancer/utilities/constants.dart';
import 'package:loader_overlay/loader_overlay.dart';
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

class ContentBooksPage extends StatelessWidget {
  final int bookId;
  final String bookName;
  final int? indexOfScrollable;
  final bool? isScrollable;
  final bool isChapter;
  final int chapterId;
  final ItemScrollController _scrollController = ItemScrollController();

  ContentBooksPage({
    super.key,
    required this.bookId,
    required this.bookName,
    this.indexOfScrollable = -1,
    this.isScrollable = false,
    required this.isChapter,
    required this.chapterId,
  });

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    String currentLanguage = Localizations.localeOf(context).languageCode;
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    final bool isMobile = shortestSide < 600;

    return Scaffold(
      body: FutureBuilder(
        future: AppData.getCurrentBook(bookId),
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
              if (isScrollable!) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToIndexIfNeeded(context);
                });
              }
              Map<String, dynamic> data = jsonDecode(snapshot.data!);
              Metadata metadata = Metadata.fromJson(data);
              List<Hadith> hadiths = isChapter
                  ? getHadithsByChapterId(
                      parseHadiths(snapshot.data), chapterId)
                  : parseHadiths(snapshot.data);
              List<Chapter> chapters = parseChapters(snapshot.data);

              return Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [
                          AppColor.primary1.withOpacity(0.1),
                          AppColor.white.withOpacity(0.2)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: const [0.2, 0.6])),
                child: NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) => [
                    SliverToBoxAdapter(
                      child: _header(currentLanguage, metadata, context, width,isMobile),
                    ),
                  ],
                  body: _listOfHadiths(hadiths, chapters, currentLanguage),
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _scrollToIndexIfNeeded(BuildContext context) {
    if (indexOfScrollable != null) {
      _scrollController.scrollTo(
        index: indexOfScrollable!,
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: isScrollable!
          ? ScrollablePositionedList.separated(
              itemScrollController: _scrollController,
              itemCount: hadiths.length + 1,
              // Add one extra item for the last separator
              itemBuilder: (context, index) {
                if (index < hadiths.length) {
                  return _listViewBuilder(
                      chapters, hadiths, index, currentLanguage, context);
                } else {
                  return const SizedBox
                      .shrink(); // The last item is just for the separator
                }
              },
              separatorBuilder: (context, index) {
                return _listViewSeparator(currentLanguage, hadiths, index + 1);
              },
            )
          : ListView.separated(
              itemCount: hadiths.length + 1,
              // Add one extra item for the last separator
              itemBuilder: (context, index) {
                if (index < hadiths.length) {
                  return _listViewBuilder(
                      chapters, hadiths, index, currentLanguage, context,);
                } else {
                  return const SizedBox
                      .shrink(); // The last item is just for the separator
                }
              },
              separatorBuilder: (context, index) {
                return _listViewSeparator(currentLanguage, hadiths, index + 1);
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
    final bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    Chapter chapter = chapters.firstWhere(
        (element) => element.id == hadiths[index].chapterId,
        orElse: () =>
            Chapter(id: -1, bookId: -1, arabic: 'Unknown', english: 'Unknown'));

    return Container(
      margin: EdgeInsets.symmetric(vertical: 15.h),
      height: isPortrait == true ? isMobile == true ? 50.h : 60.h :
      isMobile == true ? 50.w : 60.w,
      child: Card(
        color: AppColor.black,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w,vertical: isPortrait == true
          ? 10.h : 20.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    currentLanguage == Languages.EN.languageCode ? (index + 1).toString()
                    : ArabicNumbers.convert(index + 1),
                    style: TextStyle(
                      fontFamily: Constants.getTextFamily(currentLanguage),
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
                    currentLanguage == Languages.EN.languageCode
                        ? chapter.english!.length <= 40
                            ? chapter.english!
                            : "${chapter.english!.substring(0, 35)}..."
                        : chapter.arabic!.length <= 40
                            ? chapter.arabic!
                            : "${chapter.arabic!.substring(0, 35)}...",
                    style: TextStyle(
                        fontFamily: Constants.getTextFamily(currentLanguage),
                        fontSize: currentLanguage == Languages.EN.languageCode
                            ? chapter.english!.length <= 25
                                ? 15.sp
                                : 10.sp
                            : chapter.arabic!.length <= 25
                                ? 15.sp
                                : 10.sp,
                        color: AppColor.white,
                        fontWeight: FontWeight.w600),
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
                          await Share.share(hadith);
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
                                  fontSize: 15.sp, color: AppColor.black,),
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
                              bookId, index, isChapter, chapterId, bookName);
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
      BuildContext context, double width,bool isMobile) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 50.h, right: 20.w, left: 20.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(isMobile == true ? 15.w : 10.w),
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
              SizedBox(
                width: 20.w,
              ),
              Text(
                bookName.length <= 20
                    ? bookName
                    : "${bookName.substring(0, 17)}...",
                style: TextStyle(fontSize: bookName.length < 20 ? 25.sp : 22.sp, fontWeight: FontWeight.bold,
                fontFamily: Constants.getTextFamily(currentLanguage)),
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
