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
  List<Favorite> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {

    final checkboxValues = Provider.of<FavoriteProvider>(context, listen: false);


    bool isQuranChecked = await AppDataPreferences.getFavoritePageQuranCheck();
    bool isHadithChecked = await AppDataPreferences.getFavoritePageHadithCheck();
    bool isTafseerChecked = await AppDataPreferences.getFavoritePageTafseerCheck();

    List<String> ignoreTypes = [];
    if (!isQuranChecked) ignoreTypes.add('Quran');
    if (!isHadithChecked) ignoreTypes.add('Hadith');
    if (!isTafseerChecked) ignoreTypes.add('Tafseer');

    List<Favorite> favorites = await FireStoreService.getFavoritesIgnoringTypes(ignoreTypes);

    setState(() {
      _favorites = favorites;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    String currentLanguage = Localizations.localeOf(context).languageCode;

    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.separated(itemBuilder: (context,index)
          {
            return _listViewBuilder(context,currentLanguage,index);
          },
          separatorBuilder: (context,index)
          {
            return _listViewSeparator(index);
          },
          itemCount: _favorites.length + 1),
    );
  }

  Card _listViewSeparator(int index) {
    return Card(
      color: AppColor.white,
      child: Padding(
        padding: EdgeInsets.all(10.w),
        child: Column(
          children: [
            SizedBox(
              height: 5.h,
            ),
            Text(_favorites[index].content,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20.sp),
            )
          ],
        ),
      ),
    );
  }

  Container _listViewBuilder(BuildContext context, String currentLanguage,int index) {
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    final bool isMobile = shortestSide < 600;
    final bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;


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
                  SingleChildScrollView(
                    child: Row(
                      children: [
                        Text(_favorites[index].title,
                          style: TextStyle(
                              fontFamily: Utility.getTextFamily(currentLanguage),
                              fontSize:15.sp,
                              color: AppColor.white,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              _popUpMenu(
                  context,
                  index)
            ],
          ),
        ),
      ),
    );
  }

  Widget _popUpMenu(BuildContext context, int index) {
    copy() {
      final value = ClipboardData(
        text: _favorites[index].content,
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
                      await Share.share(_favorites[index].content);
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
            ]),
      ),
    );
  }
}