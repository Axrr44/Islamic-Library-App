import 'package:flutter/material.dart';
import 'package:freelancer/config/app_languages.dart';
import 'package:freelancer/pages/profile_page.dart';
import 'package:freelancer/pages/search_page.dart';
import 'package:freelancer/utilities/constants.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loader_overlay/loader_overlay.dart';
import '../config/app_colors.dart';
import '../config/app_routes.dart';
import '../models/hadith_drop_down_item.dart';
import '../models/tafseer_books.dart';
import '../services/app_data.dart';
import '../services/app_data_pref.dart';
import 'home_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late String _selectedLanguage;
  late IndexDropdownItem _selectedHadith;
  int _currentPage = 0;
  late String _nameOfPage;
  late Future<List<Tafseer>> _tafseerListFuture;
  Tafseer _mufseer = Tafseer.empty();
  late int _indexOfTafseer = 0;
  late bool _searchIsQuranChecked;
  late bool _searchIsHadithChecked;
  late bool _searchIsTafseerChecked;

  final pages = [
    const HomePage(),
    const SearchPage(),
    Text(
      "Test2",
      style: TextStyle(fontSize: 50.sp),
    ),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedLanguage = "English";
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _nameOfPage = AppLocalizations.of(context)!.home;
    String currentLanguage = Localizations.localeOf(context).languageCode;
    _tafseerListFuture = AppData.fetchTafseerData(currentLanguage);
    _loadSearchDialogData();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    const int notificationCount = 10;
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    final bool isMobile = shortestSide < 600;

    return Scaffold(
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _header(width, height, notificationCount, isMobile),
              Container(
                alignment: Alignment.center,
                child: pages[_currentPage],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _bottomNavigation(),
    );
  }

  FutureBuilder<List<Tafseer>> _listOfTafseer() {
    return FutureBuilder<List<Tafseer>>(
      future: _tafseerListFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          context.loaderOverlay.show();
          return Container();
        } else if (snapshot.hasError) {
          context.loaderOverlay.hide();
          return Text('Error: ${snapshot.error}');
        } else {
          context.loaderOverlay.hide();
          List<Tafseer>? tafseerList = snapshot.data;
          if (tafseerList != null && tafseerList.isNotEmpty) {
            return StatefulBuilder(builder: (context, setState) {
              return Container(
                height: 50.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    border: Border.all(color: AppColor.black, width: 1.w),
                    borderRadius: BorderRadius.circular(5.w)),
                child: SizedBox(
                  height: double.infinity,
                  child: DropdownButton<Tafseer>(
                    hint: Text(
                      "Select tafseer",
                      style: TextStyle(fontSize: 15.sp),
                    ),
                    iconSize: 0,
                    underline: Container(),
                    isExpanded: true,
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    value: _mufseer = tafseerList[_indexOfTafseer],
                    onChanged: !_searchIsTafseerChecked
                        ? null
                        : (Tafseer? newValue) {
                            setState(() {
                              _indexOfTafseer = tafseerList.indexOf(newValue!);
                              _mufseer = newValue;
                              AppDataPreferences.setSearchPageMufseerId(
                                  newValue.id);
                            });
                          },
                    itemHeight: 50.h,
                    items: tafseerList.map<DropdownMenuItem<Tafseer>>(
                      (Tafseer value) {
                        return DropdownMenuItem<Tafseer>(
                          value: value,
                          child: Center(
                            child: Text(
                              value.name.toString(),
                              style: TextStyle(
                                  fontSize: 15.sp,
                                  color: _searchIsTafseerChecked
                                      ? AppColor.black
                                      : Colors.grey,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      },
                    ).toList(),
                  ),
                ),
              );
            });
          } else {
            return Center(
              child: Text(
                'No Tafseer data available',
                style: TextStyle(fontSize: 30.sp),
              ),
            );
          }
        }
      },
    );
  }

  Future<void> _loadSearchDialogData() async {
    _searchIsQuranChecked = await AppDataPreferences.getSearchPageQuranCheck();
    _searchIsHadithChecked =
        await AppDataPreferences.getSearchPageHadithsCheck();
    _searchIsTafseerChecked =
        await AppDataPreferences.getSearchPageTafseerCheck();
    _selectedHadith = IndexDropdownItem(
        AppData.getBookName(
            context, await AppDataPreferences.getSearchPageHadithId()),
        await AppDataPreferences.getSearchPageHadithId());
  }

  void _showFilterSearchDialog(String currentLanguage) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            content: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              child: SizedBox(
                width: 200.w,
                height: 350.w,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.quran,
                          style: TextStyle(
                              fontSize: 20.sp,
                              fontFamily:
                                  Constants.getTextFamily(currentLanguage)),
                        ),
                        Transform.scale(
                          scale: 1.w,
                          child: Checkbox(
                            value: _searchIsQuranChecked,
                            onChanged: (value) {
                              setState(() {
                                _searchIsQuranChecked = value!;
                                AppDataPreferences.setSearchPageQuranCheck(
                                    _searchIsQuranChecked);
                              });
                            },
                            activeColor: AppColor.black,
                            checkColor: AppColor.white,
                          ),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.hadiths,
                          style: TextStyle(
                              fontSize: 20.sp,
                              fontFamily:
                                  Constants.getTextFamily(currentLanguage)),
                        ),
                        Transform.scale(
                          scale: 1.w,
                          child: Checkbox(
                            value: _searchIsHadithChecked,
                            onChanged: (value) {
                              setState(() {
                                _searchIsHadithChecked = value!;
                                AppDataPreferences.setSearchPageHadithsCheck(
                                    _searchIsHadithChecked);
                              });
                            },
                            activeColor: AppColor.black,
                            checkColor: AppColor.white,
                          ),
                        )
                      ],
                    ),
                    Container(
                      height: 50.h,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          border: Border.all(color: AppColor.black, width: 1.w),
                          borderRadius: BorderRadius.circular(5.w)),
                      child: SizedBox(
                        height: double.infinity,
                        child: DropdownButton<IndexDropdownItem>(
                          value: _selectedHadith,
                          iconSize: 0,
                          underline: Container(),
                          itemHeight: 50.h,
                          isExpanded: true,
                          onChanged: !_searchIsHadithChecked
                              ? null
                              : (IndexDropdownItem? newValue) {
                                  setState(() {
                                    _selectedHadith = newValue!;
                                    AppDataPreferences.setSearchPageHadithId(
                                        newValue.index);
                                  });
                                },
                          items: List.generate(13, (index) {
                            return DropdownMenuItem<IndexDropdownItem>(
                              value: IndexDropdownItem(
                                  AppData.getBookName(context, index), index),
                              child: Center(
                                  child: Text(
                                textAlign: TextAlign.center,
                                AppData.getBookName(context, index),
                                style: TextStyle(
                                    fontSize: 15.sp,
                                    color: _searchIsHadithChecked
                                        ? Colors.black
                                        : Colors.grey,
                                    fontWeight: FontWeight.bold),
                              )),
                            );
                          }),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.tafseer,
                          style: TextStyle(
                              fontSize: 20.sp,
                              fontFamily:
                                  Constants.getTextFamily(currentLanguage)),
                        ),
                        Transform.scale(
                          scale: 1.w,
                          child: Checkbox(
                            value: _searchIsTafseerChecked,
                            onChanged: (value) {
                              setState(() {
                                _searchIsTafseerChecked = value!;
                                AppDataPreferences.setSearchPageTafseerCheck(
                                    _searchIsTafseerChecked);
                              });
                            },
                            activeColor: AppColor.black,
                            checkColor: AppColor.white,
                          ),
                        )
                      ],
                    ),
                    _listOfTafseer(),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  void _showFilterFavoriteDialog(String currentLanguage) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            child: SizedBox(
              width: 200.w,
              height: 250.w,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.quran,
                        style: TextStyle(
                            fontSize: 20.sp,
                            fontFamily:
                                Constants.getTextFamily(currentLanguage)),
                      ),
                      Transform.scale(
                        scale: 1.w,
                        child: Checkbox(
                          value: true,
                          onChanged: (value) {},
                          activeColor: AppColor.black,
                          checkColor: AppColor.white,
                        ),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.hadiths,
                        style: TextStyle(
                            fontSize: 20.sp,
                            fontFamily:
                                Constants.getTextFamily(currentLanguage)),
                      ),
                      Transform.scale(
                        scale: 1.w,
                        child: Checkbox(
                          value: true,
                          onChanged: (value) {},
                          activeColor: AppColor.black,
                          checkColor: AppColor.white,
                        ),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.tafseer,
                        style: TextStyle(
                            fontSize: 20.sp,
                            fontFamily:
                                Constants.getTextFamily(currentLanguage)),
                      ),
                      Transform.scale(
                        scale: 1.w,
                        child: Checkbox(
                          value: true,
                          onChanged: (value) {},
                          activeColor: AppColor.black,
                          checkColor: AppColor.white,
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSettingDialog(String currentLanguage) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SizedBox(
                width: 200.w,
                height: 250.w,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.languages,
                      style: TextStyle(
                        fontFamily: Constants.getTextFamily(currentLanguage),
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      child: Divider(
                        height: 2.h,
                        color: Colors.black,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Radio<String>(
                          value: "English",
                          activeColor: Colors.black,
                          groupValue: _selectedLanguage,
                          onChanged: (String? value) {
                            setState(() {
                              _selectedLanguage = value!;
                            });
                          },
                        ),
                        Text(
                          "English",
                          style:
                              TextStyle(fontSize: 15.sp, color: Colors.black),
                        ),
                        Radio<String>(
                          value: "Arabic",
                          activeColor: Colors.black,
                          groupValue: _selectedLanguage,
                          onChanged: (String? value) {
                            setState(() {
                              _selectedLanguage = value!;
                            });
                          },
                        ),
                        Text(
                          "العربية",
                          style:
                              TextStyle(fontSize: 15.sp, color: Colors.black),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      child: Divider(
                        height: 2.h,
                        color: Colors.black,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(AppColor.black),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.w),
                          ),
                        ),
                        minimumSize:
                            MaterialStateProperty.all(Size(200.w, 50.h)),
                      ),
                      child: Text(
                        "Sign out",
                        style:
                            TextStyle(fontSize: 20.sp, color: AppColor.white),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _header(
      double width, double height, int notificationCount, bool isMobile) {
    String currentLanguage = Localizations.localeOf(context).languageCode;


    return Stack(
      alignment: Alignment.center,
      children: [
        ShaderMask(
        shaderCallback: (bounds) {
          return LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey.withOpacity(0.1) , Colors.grey.withOpacity(0)],
          ).createShader(bounds);
        },
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/islamic_pattern_2.png"),
              fit: BoxFit.cover,
            ),
          ),
          width: width,
          height: height / 3 - 40.h,
        ),
      ),
        Container(
          width: width,
          height: height / 3 - 40.h,
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _nameOfPage,
                      style: TextStyle(
                          fontFamily: Constants.getTextFamily(currentLanguage),
                          fontSize: _nameOfPage.length > 10 ? 30.sp : 40.sp,
                          color: AppColor.black,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: width / 2,
                      child: Text(
                        _subTitleHeader(_nameOfPage),
                        style: TextStyle(fontSize: 15.sp, color: Colors.grey,fontFamily:
                        currentLanguage == Languages.EN.languageCode ? 'EnglishQuran'
                        : 'Hafs'),
                      ),
                    ),
                  ],
                ),
                _nameOfPage != AppLocalizations.of(context)!.home
                    ? Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                          isMobile == true ? 15.w : 10.w),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColor.white,
                          border: Border.all(
                            color: AppColor.black, // Set the border color
                            width: 1.w, // Set the border width
                          ),
                          borderRadius: BorderRadius.circular(isMobile == true
                              ? 15.w
                              : 10.w), // Match the ClipRRect border radius
                        ),
                        child: Container(
                          child: IconButton(
                            onPressed: () {
                              _actionOfHeaderButton();
                            },
                            icon: Icon(
                              _iconHeader(_nameOfPage),
                              size: 35.w,
                              color: AppColor.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (notificationCount > 0 &&
                        _nameOfPage == AppLocalizations.of(context)!.home)
                      Positioned(
                        right: 8.w,
                        top: 8.w,
                        child: Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: BoxConstraints(
                            minWidth: 16.w,
                            minHeight: 16.w,
                          ),
                          child: Center(
                            child: Text(
                              notificationCount.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                )
                    : Container()
              ],
            ),
          ),
        )
      ]
    );
  }

  void _actionOfHeaderButton() {
    String currentLanguage = Localizations.localeOf(context).languageCode;
   if (_nameOfPage == AppLocalizations.of(context)!.search) {
      _showFilterSearchDialog(currentLanguage);
    } else if (_nameOfPage == AppLocalizations.of(context)!.favorites) {
      _showFilterFavoriteDialog(currentLanguage);
    } else if (_nameOfPage == AppLocalizations.of(context)!.profile) {
      _showSettingDialog(currentLanguage);
    }
  }

  String _subTitleHeader(String currentPage) {
    switch (currentPage) {
      case "Home":
        {
          return AppLocalizations.of(context)!.homeSubTitle;
          break;
        }
      case "Search":
        {
          return AppLocalizations.of(context)!.searchSubTitle;
          break;
        }
      case "Favorites":
        {
          return AppLocalizations.of(context)!.favoriteSubTitle;
          break;
        }
      case "الرئيسية":
        {
          return AppLocalizations.of(context)!.homeSubTitle;
          break;
        }
      case "البحث":
        {
          return AppLocalizations.of(context)!.searchSubTitle;
          break;
        }
      case "المفضلة":
        {
          return AppLocalizations.of(context)!.favoriteSubTitle;
          break;
        }
    }
    return "";
  }
  
  IconData _iconHeader(String currentPage) {
    switch (currentPage) {
      case "Home":
        {
          return Icons.notifications_outlined;
          break;
        }
      case "Search":
        {
          return Icons.filter_list_outlined;
          break;
        }
      case "Favorites":
        {
          return Icons.filter_list_outlined;
          break;
        }
      case "Profile":
        {
          return Icons.settings;
          break;
        }
      case "الرئيسية":
        {
          return Icons.notifications_outlined;
          break;
        }
      case "البحث":
        {
          return Icons.filter_list_outlined;
          break;
        }
      case "المفضلة":
        {
          return Icons.filter_list_outlined;
          break;
        }
      case "الملف الشخصي":
        {
          return Icons.settings;
          break;
        }
    }
    return Icons.abc;
  }

  Widget _bottomNavigation() {
    String currentLanguage = Localizations.localeOf(context).languageCode;

    return Container(
      color: AppColor.white,
      child: Padding(
        padding:
            EdgeInsets.only(left: 30.w, right: 30.w, top: 15.h, bottom: 15.h),
        child: GNav(
          tabActiveBorder: Border.all(color: Colors.black, width: 1),
          backgroundColor: AppColor.white,
          tabBackgroundColor: AppColor.black.withOpacity(0.07),
          gap: 8.w,
          // padding between text and icon
          duration: const Duration(milliseconds: 200),
          // tab animation duration
          color: Colors.black.withOpacity(0.5),
          padding:
              EdgeInsets.only(left: 10.w, right: 10.w, top: 15.h, bottom: 15.h),
          activeColor: AppColor.black,
          tabs: [
            GButton(
              icon: Icons.home_outlined,
              text: AppLocalizations.of(context)!.home,
              textStyle: TextStyle(
                  fontSize: 15.sp,
                  fontFamily: Constants.getTextFamily(currentLanguage)),
              iconColor: AppColor.black,
              iconSize: 20.w,
              onPressed: () {
                setState(() {
                  _nameOfPage = AppLocalizations.of(context)!.home;
                });
              },
            ),
            GButton(
              icon: Icons.search,
              text: AppLocalizations.of(context)!.search,
              textStyle: TextStyle(
                  fontSize: 15.sp,
                  fontFamily: Constants.getTextFamily(currentLanguage)),
              iconColor: AppColor.black,
              iconSize: 20.w,
              onPressed: () {
                setState(() {
                  _nameOfPage = AppLocalizations.of(context)!.search;
                });
              },
            ),
            GButton(
              icon: Icons.favorite_border_outlined,
              text: AppLocalizations.of(context)!.favorites,
              textStyle: TextStyle(
                  fontSize: 15.sp,
                  fontFamily: Constants.getTextFamily(currentLanguage)),
              iconColor: AppColor.black,
              iconSize: 20.w,
              onPressed: () {
                setState(() {
                  _nameOfPage = AppLocalizations.of(context)!.favorites;
                });
              },
            ),
            GButton(
              icon: Icons.person_outline,
              text: AppLocalizations.of(context)!.profile,
              textStyle: TextStyle(
                  fontSize: 15.sp,
                  fontFamily: Constants.getTextFamily(currentLanguage)),
              iconColor: AppColor.black,
              iconSize: 20.w,
              onPressed: () {
                setState(() {
                  _nameOfPage = AppLocalizations.of(context)!.profile;
                });
              },
            ),
          ],
          onTabChange: (index) {
            setState(() {
              _currentPage = index;
            });
          },
        ),
      ),
    );
  }
}
