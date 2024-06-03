import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../components/custom_dialog.dart';
import '../config/app_colors.dart';
import '../config/app_languages.dart';
import '../models/hadith_model.dart';
import '../services/app_data.dart';
import '../utilities/utility.dart';
import 'content_books_page.dart';

class ChapterOfBooksPage extends StatelessWidget {
  final int selectedHadith;

  const ChapterOfBooksPage({super.key, required this.selectedHadith});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    String currentLanguage = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppData.getBookName(context, selectedHadith),
          style: TextStyle(
              fontSize: 25.sp,
              fontWeight: FontWeight.bold,
              fontFamily: 'ATF'),
        ),
      ),
      body: _listOfChapters(width, height, context, currentLanguage),
    );
  }

  Widget _listOfChapters(double width, double height, BuildContext context,
      String currentLanguage) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Padding(
        padding: EdgeInsets.only(top: 10.h),
        child: Column(
          children: [
            Padding(
              padding:  EdgeInsets.symmetric(vertical: 15.h),
              child: SizedBox(
                width: width,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(
                      builder: (context) => ContentBooksPage(
                        chapterId: 0,
                        bookId: selectedHadith,
                        bookName: AppData.getBookName(context, selectedHadith),
                        isChapter: false,
                      ),
                    ));
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.w),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 15.h), // Add padding
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.wholeBook,
                    style: TextStyle(fontSize: 20.sp,fontWeight: FontWeight.bold),
                  ),
                )
                ,
              ),
            )
            ,
            Expanded(
              child: FutureBuilder(
                future: AppData.getCurrentBook(selectedHadith),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(
                      color: AppColor.primary1,
                    ));
                  } else {
                    if (snapshot.hasError) {
                      customDialog(context, snapshot.error.toString());
                      return const SizedBox(width: 5);
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
                          bool isDarimi = false;
                          if (currentLanguage == Languages.EN.languageCode) {
                            isDarimi = chapters[index]
                                .english
                                .toString()
                                .trim()
                                .isEmpty;
                          }
                          return Card(
                            color: isDarimi
                                ? Colors.grey.withOpacity(0.5)
                                : AppColor.white,
                            child: InkWell(
                              onTap: isDarimi
                                  ? null
                                  : () {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                        builder: (context) => ContentBooksPage(
                                          chapterId: index + 1,
                                          bookId: selectedHadith,
                                          bookName: currentLanguage ==
                                                  Languages.EN.languageCode
                                              ? chapters[index]
                                                  .english
                                                  .toString()
                                              : chapters[index]
                                                  .arabic
                                                  .toString(),
                                        ),
                                      ));
                                    },
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.all(10.w),
                                  child: Text(
                                    textAlign: TextAlign.center,
                                    currentLanguage == Languages.EN.languageCode
                                        ? isDarimi
                                            ? "Only Arabic"
                                            : chapters[index].english.toString()
                                        : chapters[index].arabic.toString(),
                                    style: TextStyle(
                                      fontFamily: Utility.getTextFamily(
                                          currentLanguage),
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
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
}
