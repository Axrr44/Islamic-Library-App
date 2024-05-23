import 'package:arabic_numbers/arabic_numbers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:freelancer/providers/favorite_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';
import '../config/app_colors.dart';
import '../config/app_languages.dart';
import '../models/favorite_model.dart';
import '../services/app_data_pref.dart';
import '../services/firestore_service.dart';
import '../utilities/utility.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late Future<List<Favorite>> _favoritesFuture;

  @override
  void initState() {
    super.initState();
    _favoritesFuture = _loadFavorites();
  }

  Future<List<Favorite>> _loadFavorites() async {
    final checkboxValues =
    Provider.of<FavoriteProvider>(context, listen: false);

    bool isQuranChecked = await AppDataPreferences.getFavoritePageQuranCheck();
    bool isHadithChecked =
    await AppDataPreferences.getFavoritePageHadithCheck();
    bool isTafseerChecked =
    await AppDataPreferences.getFavoritePageTafseerCheck();

    List<String> ignoreTypes = [];
    if (!isQuranChecked) ignoreTypes.add('Quran');
    if (!isHadithChecked) ignoreTypes.add('Hadith');
    if (!isTafseerChecked) ignoreTypes.add('Tafseer');

    List<Favorite> favorites =
    await FireStoreService.getFavoritesIgnoringTypes(ignoreTypes);

    return favorites;
  }

  @override
  Widget build(BuildContext context) {
    String currentLanguage = Localizations.localeOf(context).languageCode;

    return FutureBuilder<List<Favorite>>(
      future: _favoritesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(
                color: Colors.black,
              ));
        }
        else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        else if (snapshot.hasData && snapshot.data!.isEmpty) {
          return const Center(
              child: Text(
                'No favorites found.',
                textAlign: TextAlign.center,
              ));
        }
        else {
          List<Favorite> favorites = snapshot.data ?? [];
          return SizedBox(
            height: MediaQuery.of(context).size.height,
            child: ListView.separated(
              itemBuilder: (context, index) {
                if (index < favorites.length) {
                  return _listViewBuilder(context, currentLanguage,
                      favorites[index], index);
                } else {
                  return const SizedBox.shrink();
                }
              },
              separatorBuilder: (context, index) {
                if (index <= favorites.length) {
                  return _listViewSeparator(favorites[index]);
                } else {
                  return SizedBox.shrink();
                }
              },
              itemCount: favorites.length + 1,
            ),
          );
        }
      },
    );
  }

  Widget _listViewSeparator(Favorite favorite) {
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
              favorite.content,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20.sp),
            ),
          ],
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
    return Card(
      color: AppColor.black,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 10.w,
          vertical: isPortrait ? 10.h : 20.h,
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
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
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.w),
                    child: VerticalDivider(
                      thickness: 3.w,
                      color: AppColor.white,
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Text(
                          favorite.title,
                          style: TextStyle(
                            fontFamily: Utility.getTextFamily(currentLanguage),
                            fontSize: 15.sp,
                            color: AppColor.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              _popUpMenu(context, favorite),
            ],
          ),
        ),
      ),
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
