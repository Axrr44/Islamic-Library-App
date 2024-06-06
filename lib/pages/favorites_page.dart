import 'package:arabic_numbers/arabic_numbers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:freelancer/pages/quran_aya_page.dart';
import 'package:freelancer/pages/tafseer_conent_page.dart';
import 'package:freelancer/providers/favorite_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:quran/surah_data.dart';
import 'package:quran/quran.dart' as quran;
import 'package:share_plus/share_plus.dart';
import '../config/app_colors.dart';
import '../config/app_languages.dart';
import '../config/app_routes.dart';
import '../models/favorite_model.dart';
import '../models/tafseer_books.dart';
import '../providers/main_page_provider.dart';
import '../services/authentication.dart';
import '../utilities/utility.dart';
import 'content_books_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  Widget build(BuildContext context) {
    String currentLanguage = Localizations.localeOf(context).languageCode;

    if (AuthServices.getCurrentUser() == null) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context)!.guestMessage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15.sp, color: Colors.grey),
            ),
            SizedBox(
              height: 10.h,
            ),
            ElevatedButton(
              onPressed: () {
                var mainPageProvider =
                    Provider.of<MainPageProvider>(context, listen: false);
                mainPageProvider
                    .setCurrentPageName(AppLocalizations.of(context)!.home);
                Navigator.of(context)
                    .pushReplacementNamed(AppRoutes.SIGN_IN_ROUTES);
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(AppColor.primary1),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.w),
                  ),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.signIn,
                style: TextStyle(fontSize: 20.sp, color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    return Consumer<FavoriteProvider>(
      builder: (context, favoriteProvider, child) {
        return FutureBuilder<List<Favorite>>(
          future: favoriteProvider.loadFavorites(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.black,
                ),
              );
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData && snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  AppLocalizations.of(context)!.noFavorite,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20.sp),
                ),
              );
            } else {
              List<Favorite> favorites = snapshot.data ?? [];

              return SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Padding(
                  padding:
                      EdgeInsets.only(left: 20.w, right: 20.w, bottom: 30.h),
                  child: ListView.separated(
                    itemBuilder: (context, index) {
                      if (index < favorites.length) {
                        return _listViewBuilder(
                            context, currentLanguage, favorites[index], index);
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                    separatorBuilder: (context, index) {
                      return _listViewSeparator(
                          favorites[index], currentLanguage);
                    },
                    itemCount: favorites.length + 1,
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }

  Widget _listViewSeparator(Favorite favorite, String currentLanguage) {
    List<String> tafseerContent = [];
    if (favorite.type == 'Tafseer') {
      tafseerContent = favorite.content.split('Split');
      return InkWell(
        onTap: (){
          if (favorite.type.toLowerCase() == 'Tafseer'.toLowerCase()) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => TafseerContentPage(
                mufseer: Tafseer(
                    id: favorite.tafseerId,
                    name: favorite.tafseerName,
                    language: '',
                    author: favorite.author,
                    bookName: favorite.bookName),
                surahId: favorite.surahId,
                isScrollable: true,
                indexOfScrollable: favorite.verseId - 1,
              ),
            ));
          }
        },
        child: Card(
          color: AppColor.white,
          child: Padding(
            padding: EdgeInsets.all(10.w),
            child: Column(
              children: [
                SizedBox(
                  height: 5.h,
                ),
                Text(
                  tafseerContent[0],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 20.sp,
                      fontFamily: currentLanguage == Languages.EN.languageCode
                          ? 'EnglishQuran'
                          : 'Hafs'),
                ),
                separateTafseerContent(),
                Text(
                  tafseerContent[1],
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15.sp),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return InkWell(
      onTap: () {
        if (favorite.type.toLowerCase() == 'quran'.toLowerCase())
        {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => QuranAyaPage(
                    surahId: favorite.surahId,
                    initialPage: quran.getPageNumber(
                            favorite.surahId, favorite.verseId) -
                        1,
                  )));
        } else {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ContentBooksPage(
              chapterId: favorite.hadithChapterId,
              bookId: favorite.hadithBookId,
              bookName: favorite.bookName,
              isScrollable: true,
              indexOfScrollable: favorite.hadithIdInBook,
              isFromFavorite: true,
            ),
          ));
        }
      },
      child: Card(
        color: AppColor.white,
        child: Padding(
          padding: EdgeInsets.all(10.w),
          child: Column(
            children: [
              SizedBox(
                height: 5.h,
              ),
              Text(
                favorite.content,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20.sp,
                    fontFamily: currentLanguage == Languages.EN.languageCode
                        ? favorite.type == 'Quran'
                            ? 'EnglishQuran'
                            : 'Custom'
                        : favorite.type == 'Quran'
                            ? 'Hafs'
                            : 'ArabicFont'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _listViewBuilder(BuildContext context, String currentLanguage,
      Favorite favorite, int index) {
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    final bool isMobile = shortestSide < 600;
    final bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

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
                        favorite.title,
                        style: TextStyle(
                          fontFamily: Utility.getTextFamily(currentLanguage),
                          fontSize: favorite.title.length >= 25 ? 7.sp : 15.sp,
                          overflow: TextOverflow.ellipsis,
                          color: AppColor.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              _popUpMenu(context, favorite)
            ],
          ),
        ),
      ),
    );
  }

  Widget separateTafseerContent() {
    return Column(
      children: [
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
      ],
    );
  }

  Widget _popUpMenu(BuildContext context, Favorite favorite) {
    copy() {
      final value = ClipboardData(
        text: favorite.content,
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
                        style:
                            TextStyle(fontSize: 15.sp, color: AppColor.black),
                      ),
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
                    await Share.share(favorite.content);
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
                      ),
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
}
