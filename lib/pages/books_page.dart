import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../components/custom_dialog.dart';
import '../config/app_languages.dart';
import '../models/hadith_drop_down_item.dart';
import '../services/app_data.dart';
import '../config/app_colors.dart';
import '../models/hadith_model.dart';
import '../services/app_data_pref.dart';
import 'content_books_page.dart';

class BooksPage extends StatefulWidget {
  const BooksPage({super.key});

  @override
  State<BooksPage> createState() => _BooksPageState();
}

class _BooksPageState extends State<BooksPage> {
  late int _hadithBookId;
  late int _hadithIndex;
  late int _chapterId;
  late bool _isChapter;
  late String _chapterName;
  IndexDropdownItem? _selectedItem;

  @override
  void initState() {
    super.initState();
    _loadHadithData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selectedItem = IndexDropdownItem(AppData.getBookName(context, 0), 0);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    String currentLanguage = Localizations.localeOf(context).languageCode;
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    final bool isMobile = shortestSide < 600;

    return Scaffold(
      extendBody: true,
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
        child: DefaultTabController(
          length: 2,
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverToBoxAdapter(
                child: _header(width, height, context,isMobile,currentLanguage),
              ),
              SliverAppBar(
                pinned: true,
                automaticallyImplyLeading: false,
                elevation: 0,
                backgroundColor: innerBoxIsScrolled == false
                    ? AppColor.black.withOpacity(0)
                    : AppColor.black,
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(isMobile == true ? 0 : 20.h),
                  child: TabBar(
                      unselectedLabelColor: Colors.grey.withOpacity(0.7),
                      overlayColor: MaterialStateProperty.all(
                          innerBoxIsScrolled == false
                              ? AppColor.black.withOpacity(0.1)
                              : AppColor.white.withOpacity(0.1)),
                      labelPadding: EdgeInsets.symmetric(horizontal: 10.w,
                          vertical: isMobile == true ? 0 : 10.h),
                      labelStyle: TextStyle(fontSize: 20.sp),
                      labelColor: innerBoxIsScrolled == false
                          ? AppColor.black
                          : AppColor.white,
                      indicatorColor: innerBoxIsScrolled == false
                          ? AppColor.black
                          : AppColor.white,
                      tabs: const [
                        Tab(
                          child: Text("All"),
                        ),
                        Tab(
                          child: Text("Chapter"),
                        ),
                      ]),
                ),
              )
            ],
            body: TabBarView(
              children: [
                _listOfHadiths(width, height, context),
                _listOfChapters(width, height, context, currentLanguage)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _listOfChapters(
      double width, double height, BuildContext context, String language) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Padding(
        padding: EdgeInsets.only(top: 10.h),
        child: Column(
          children: [
            _menuOfImam(),
            Expanded(
              child: FutureBuilder(
                future: AppData.getCurrentBook(_selectedItem!.index),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      width: 5,
                    );
                  } else {
                    if (snapshot.hasError) {
                      customDialog(context, snapshot.error.toString());
                      return const SizedBox(
                        width: 5,
                      );
                    } else {
                      List<Chapter> chapters = parseChapters(snapshot.data);

                      return GridView.builder(
                        itemCount: chapters.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10.w,
                          mainAxisSpacing: 10.h,
                        ),
                        itemBuilder: (context, index) {
                          return Card(
                            color: AppColor.white,
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => ContentBooksPage(
                                          chapterId: index + 1,
                                          isChapter: true,
                                          bookId: _selectedItem!.index,
                                          bookName: language ==
                                                  Languages.EN.languageCode
                                              ? chapters[index]
                                                  .english
                                                  .toString()
                                              : chapters[index]
                                                  .arabic
                                                  .toString(),
                                        )));
                              },
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.all(10.w),
                                  child: Text(
                                    textAlign: TextAlign.center,
                                    language == Languages.EN.languageCode
                                        ? chapters[index].english.toString()
                                        : chapters[index].arabic.toString(),
                                    style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadHadithData() async {
    _hadithBookId = await AppDataPreferences.getHadithBookId();
    _hadithIndex = await AppDataPreferences.getHadithIndex();
    _isChapter = await AppDataPreferences.getHadithIsChapter();
    _chapterId = await AppDataPreferences.getHadithChapterId();
    _chapterName = await AppDataPreferences.getHadithChapterName();
  }

  Widget _listOfHadiths(double width, double height, BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: GridView.builder(
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: width / 2,
              mainAxisExtent: height / 4,
              childAspectRatio: 1,
              crossAxisSpacing: 5.w,
              mainAxisSpacing: 5.h),
          itemCount: 13,
          itemBuilder: (_, index) {
            return Card(
              color: AppColor.white,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ContentBooksPage(
                            chapterId: 0,
                            isChapter: false,
                            bookId: index,
                            bookName: AppData.getBookName(context, index),
                          )));
                },
                child: ListTile(
                  leading: Icon(
                    Icons.menu_book_outlined,
                    color: AppColor.black,
                    size: 20.w,
                  ),
                  title: Text(
                    AppData.getBookName(context, index),
                    style: TextStyle(fontSize: 14.sp),
                  ),
                ),
              ),
            );
          }),
    );
  }

  Widget _menuOfImam() {
    return Container(
      height: 50.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: AppColor.black, width: 1.w),
        borderRadius: BorderRadius.circular(5.w),
      ),
      child: SizedBox(
        height: double.infinity,
        child: DropdownButton<IndexDropdownItem>(
          value: _selectedItem,
          iconSize: 0,
          underline: Container(),
          itemHeight: 50.h,
          isExpanded: true,
          onChanged: (IndexDropdownItem? newValue) {
            setState(() {
              _selectedItem = newValue;
            });
          },
          items: List.generate(12, (index) {
            return DropdownMenuItem<IndexDropdownItem>(
              value: IndexDropdownItem(
                  AppData.getBookName(context, index), index),
              child: Center(
                child: Text(
                  AppData.getBookName(context, index),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _header(double width, double height, BuildContext context,bool isMobile,
      String currentLanguage) {
    return Container(
      width: width,
      height: isMobile == true ? height / 3 : height / 2 - 100,
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
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hadiths",
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
                        onPressed: () async {
                          await _loadHadithData();
                          if (_hadithBookId != -1) {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ContentBooksPage(
                                      chapterId: _chapterId,
                                      isChapter: _isChapter,
                                      bookId: _hadithBookId,
                                      bookName: _chapterName,
                                      isScrollable: true,
                                      indexOfScrollable: _hadithIndex,
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
