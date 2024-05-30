import 'dart:async';
import 'dart:isolate';
import 'package:arabic_numbers/arabic_numbers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:freelancer/config/app_languages.dart';
import 'package:freelancer/services/app_data.dart';
import 'package:freelancer/utilities/utility.dart';
import 'package:share_plus/share_plus.dart';
import '../config/app_colors.dart';
import '../services/app_data_pref.dart';
import '../models/hadith_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../services/search_hepler.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final List<Hadith> _hadiths = [];
  List<dynamic> _searchResults = [];
  final TextEditingController _searchController = TextEditingController();
  late int _selectedFilterSearch;
  late int _indexOfHadith = 0;
  late int _mufseerId;
  bool _isLoading = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadSearchDialogData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadSearchDialogData() async {
    _selectedFilterSearch = (await AppDataPreferences.getFilterSearch())!;
    _indexOfHadith = await AppDataPreferences.getSearchPageHadithId();
    _mufseerId = await AppDataPreferences.getSearchPageMufseerId(Localizations.localeOf(context).languageCode);
    setState(() {});
  }

  Widget _buildWarningSearch(String currentLanguage,String content) {
    return Padding(
      padding: EdgeInsets.only(top: 20.h),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.w),
            border: Border.all(color: const Color(0xFFC7A102), width: 2),
            color: const Color(0x33FFCC00)),
        child: ListTile(
          leading: Icon(
            Icons.warning_amber,
            size: 20.w,
            color: Colors.black,
          ),
          title: Text(
            content,
            style: TextStyle(
                fontSize: 12.sp,
                fontFamily: Utility.getTextFamily(currentLanguage)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    String currentLanguage = Localizations.localeOf(context).languageCode;

    return SingleChildScrollView(
      child: Material(
        color: Colors.white.withOpacity(0.0),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width / 20),
          child: Container(
            color: Colors.grey.withOpacity(0.0),
            child: Column(
              children: [
                _searchBar(currentLanguage),
                _isLoading
                    ? SizedBox(
                  height: 200.h,
                      child: const Center(
                        child: CircularProgressIndicator(
                                        color: AppColor.black,
                                      ),
                      ),
                    )
                    : _searchResults.isNotEmpty
                    ? _buildSearchResults(currentLanguage)
                    : Column(
                  children: [
                    _buildWarningSearch(currentLanguage,AppLocalizations.of(context)!.warningSearch),
                    _buildWarningSearch(currentLanguage,AppLocalizations.of(context)!.warningFilterSearch)
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _searchBar(String currentLanguage) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(
                right: currentLanguage == Languages.EN.languageCode ? 5.w : 0,
                left: currentLanguage == Languages.EN.languageCode ? 0 : 5.w),
            child: Card(
              elevation: 2,
              child: TextField(
                controller: _searchController,
                style: TextStyle(fontSize: 15.sp),
                textAlign: TextAlign.center,
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  contentPadding:
                  EdgeInsets.symmetric(vertical: 20.h, horizontal: 10.w),
                  hintText: "${AppLocalizations.of(context)!.search}....",
                  hintStyle: TextStyle(
                      fontFamily: Utility.getTextFamily(currentLanguage)),
                  filled: true,
                  fillColor: Colors.white,
                  focusColor: Colors.black,
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.black),
                    borderRadius:
                    BorderRadius.circular(5.w), // Adjust border radius
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.circular(5.w),
                  ),
                ),
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: () async {
            await _loadSearchDialogData();
            _search(_searchController.text.trim());
          },
          icon: Icon(
            color: AppColor.white,
            Icons.search_rounded,
            size: 43.w,
          ),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.black),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.w),
              ),
            ),
          ),
        )
      ],
    );
  }


  void _search(String query) async {
    if (_searchController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _searchResults.clear();
    });

    await _loadSearchDialogData();

    List<Map<String, String>> quranResults = [];
    List<Map<String, String>> hadithResults = [];
    List<Map<String, String>> tafseerResults = [];

    final ReceivePort receivePort = ReceivePort();
    await Isolate.spawn(
      SearchHelper.searchIsolate,
      {
        'query': query,
        'sendPort': receivePort.sendPort,
        'searchFilterSearch': _selectedFilterSearch,
        'hadiths': _hadiths,
        'mufseerId': _mufseerId,
      },
    );

    receivePort.listen((data) {
      setState(() {
        _searchResults = data;
        _isLoading = false;
      });
      receivePort.close();
    });
  }

  Widget _buildSearchResults(String currentLanguage) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _searchResults.length + 1,
      itemBuilder: (context, index) {
        if (index != _searchResults.length) {
          return _listViewSeparated(currentLanguage, index, context);
        } else {
          return Container();
        }
      },
      separatorBuilder: (BuildContext context, int index) {
        final result = _searchResults[index];
        switch (result['type']) {
          case 'quran':
            return _buildQuranResult(result, currentLanguage);
          case 'hadith':
            return _buildHadithResult(result, currentLanguage);
          case 'tafseer':
            return _buildTafseerResult(result, currentLanguage);
          default:
            return const SizedBox();
        }
      },
    );
  }

  Widget _listViewSeparated(
      String currentLanguage, int index, BuildContext context) {
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    final bool isMobile = shortestSide < 600;
    final bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    String title = "";

    if (_searchResults[index]['type'] == 'quran' ||
        _searchResults[index]['type'] == 'tafseer') {
      title = _searchResults[index]['surah'];
    } else {
      title = AppData.getBookName(context, _indexOfHadith);
    }

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
                  Text(
                    title,
                    style: TextStyle(
                        fontFamily: Utility.getTextFamily(currentLanguage),
                        fontSize: title.length > 25 ? 7.sp : 15.sp,
                        color: AppColor.white,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              _popUpMenu(context, index, currentLanguage)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuranResult(result, String currentLanguage) {
    return Card(
      color: AppColor.white,
      child: Padding(
        padding: EdgeInsets.all(10.w),
        child: Column(
          children: [
            Text(
              result['verse'],
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 20.sp,
                  fontFamily: currentLanguage == Languages.EN.languageCode
                      ? "EnglishQuran"
                      : "Hafs"),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildHadithResult(result, String currentLanguage) {
    return Card(
      color: AppColor.white,
      child: Padding(
        padding: EdgeInsets.all(10.w),
        child: Text(
          currentLanguage == Languages.EN.languageCode
              ? result['english']
              : result['arabic'],
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20.sp),
        ),
      ),
    );
  }

  Widget _buildTafseerResult(result, String currentLanguage) {
    return Card(
      color: AppColor.white,
      child: Padding(
        padding: EdgeInsets.all(10.w),
        child: Column(
          children: [
            Text(
              result['verse'],
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20.sp),
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
            Text(
              result['tafseer'],
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20.sp),
            ),
          ],
        ),
      ),
    );
  }

  Widget _popUpMenu(BuildContext context, int index, String currentLanguage) {
    String content = "";
    if (_searchResults[index]['type'] == 'quran') {
      content = _searchResults[index]['verse'];
    } else if (_searchResults[index]['type'] == 'tafseer') {
      content = _searchResults[index]['verse'] +
          "\n\n\n\n" +
          _searchResults[index]['tafseer'];
    } else {
      content = currentLanguage == Languages.EN.languageCode
          ? _searchResults[index]['english']
          : _searchResults[index]['arabic'];
    }
    copy() {
      final value = ClipboardData(
        text: content,
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
                          await Share.share(content);
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
                ]),
      ),
    );
  }
}
