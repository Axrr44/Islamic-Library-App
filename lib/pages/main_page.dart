import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:freelancer/config/app_languages.dart';
import 'package:freelancer/pages/favorites_page.dart';
import 'package:freelancer/pages/profile_page.dart';
import 'package:freelancer/pages/search_page.dart';
import 'package:freelancer/providers/favorite_provider.dart';
import 'package:freelancer/providers/main_page_provider.dart';
import 'package:freelancer/services/admob_service.dart';
import 'package:freelancer/services/authentication.dart';
import 'package:freelancer/utilities/utility.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';
import '../config/app_colors.dart';
import '../models/hadith_drop_down_item.dart';
import '../models/tafseer_books.dart';
import '../providers/language_provider.dart';
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
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  late String _selectedLanguage;
  late int _selectedFilterSearch;
  late IndexDropdownItem _selectedHadith;
  int _currentPage = 0;
  late Future<List<Tafseer>> _tafseerListFuture;
  Tafseer _mufseer = Tafseer.empty();
  late int _indexOfTafseer = 0;
  late bool _favoriteIsQuranChecked;
  late bool _favoriteIsHadithChecked;
  late bool _favoriteIsTafseerChecked;

  final pages = [
    const HomePage(),
    const SearchPage(),
    const FavoritesPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _createBannerAd();
    _createInterstitialAd();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Use Future.delayed to schedule the code to run after the build phase
    Future.delayed(Duration.zero, () {
      String currentLanguage = Localizations.localeOf(context).languageCode;
      var mainProvider = Provider.of<MainPageProvider>(context, listen: false);
      if (mainProvider.currentPageName == "Home" || mainProvider.currentPageName == "الرئيسية") {
        mainProvider.setCurrentPageName(AppLocalizations.of(context)!.home);
      } else if (mainProvider.currentPageName == AppLocalizations.of(context)!.search) {
        mainProvider.setCurrentPageName(AppLocalizations.of(context)!.search);
      }
      _tafseerListFuture = AppData.fetchTafseerData(currentLanguage);
      _loadSearchDialogData();
      _loadFavoriteDialogData();
      _loaSettingDialogData();
    });
  }


  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    const int notificationCount = 10;
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    final bool isMobile = shortestSide < 600;

    return Scaffold(
      body: Column(
        children: [
          _header(width, height, notificationCount, isMobile),
          Expanded(
            child: pages[_currentPage],
          ),
        ],
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
                    onChanged: _selectedFilterSearch != 2
                        ? null
                        : (Tafseer? newValue) {
                            setState(() {
                              _indexOfTafseer = tafseerList.indexOf(newValue!);
                              _mufseer = newValue;
                              AppDataPreferences.setSearchPageMufseerIndex(
                                  _indexOfTafseer);
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
                                  color: _selectedFilterSearch == 2
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
    _selectedFilterSearch = (await AppDataPreferences.getFilterSearch())!;
    _selectedHadith = IndexDropdownItem(
        AppData.getBookName(
            context, await AppDataPreferences.getSearchPageHadithId()),
        await AppDataPreferences.getSearchPageHadithId());
    _indexOfTafseer = await AppDataPreferences.getSearchPageMufseerIndex();
  }

  Future<void> _loadFavoriteDialogData() async {
    _favoriteIsQuranChecked =
        await AppDataPreferences.getFavoritePageQuranCheck();
    _favoriteIsHadithChecked =
        await AppDataPreferences.getFavoritePageHadithCheck();
    _favoriteIsTafseerChecked =
        await AppDataPreferences.getFavoritePageTafseerCheck();
  }

  Future<void> _loaSettingDialogData() async {
    _selectedLanguage = await AppDataPreferences.getCurrentLanguage();
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
                              Utility.getTextFamily(currentLanguage)),
                        ),
                        Radio(
                          value: 0,
                          groupValue: _selectedFilterSearch,
                          onChanged: (value) {
                            setState(() {
                              AppDataPreferences.setFilterSearch(value!);
                              _selectedFilterSearch = value;
                            });
                          },
                          activeColor: AppColor.black,
                        ),
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
                              Utility.getTextFamily(currentLanguage)),
                        ),
                        Radio(
                          value: 1,
                          groupValue: _selectedFilterSearch,
                          onChanged: (value) {
                            setState(() {
                              AppDataPreferences.setFilterSearch(value!);
                              _selectedFilterSearch = value;
                            });
                          },
                          activeColor: AppColor.black,
                        ),
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
                          onChanged: _selectedFilterSearch != 1
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
                                        color: _selectedFilterSearch == 1
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
                              Utility.getTextFamily(currentLanguage)),
                        ),
                        Radio(
                          value: 2, // Unique value for Tafseer Radio
                          groupValue: _selectedFilterSearch,
                          onChanged: (value) {
                            setState(() {
                              AppDataPreferences.setFilterSearch(value!);
                              _selectedFilterSearch = value;
                            });
                          },
                          activeColor: AppColor.black,
                        ),
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
    final checkboxValues =
        Provider.of<FavoriteProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            child: SizedBox(
              width: 200.w,
              height: 250.w,
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Column(
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
                                    Utility.getTextFamily(currentLanguage)),
                          ),
                          Transform.scale(
                            scale: 1.w,
                            child: Checkbox(
                              value: _favoriteIsQuranChecked,
                              onChanged: (value) {
                                setState(() {
                                  _favoriteIsQuranChecked =
                                      !_favoriteIsQuranChecked;
                                });
                                AppDataPreferences.setFavoritePageQuranCheck(
                                    _favoriteIsQuranChecked);
                                checkboxValues.updateCheckboxValues(
                                    _favoriteIsQuranChecked,
                                    _favoriteIsHadithChecked,
                                    _favoriteIsTafseerChecked);
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
                                    Utility.getTextFamily(currentLanguage)),
                          ),
                          Transform.scale(
                            scale: 1.w,
                            child: Checkbox(
                              value: _favoriteIsHadithChecked,
                              onChanged: (value) {
                                setState(() {
                                  _favoriteIsHadithChecked =
                                      !_favoriteIsHadithChecked;
                                });
                                AppDataPreferences.setFavoritePageHadithCheck(
                                    _favoriteIsHadithChecked);
                                checkboxValues.updateCheckboxValues(
                                    _favoriteIsQuranChecked,
                                    _favoriteIsHadithChecked,
                                    _favoriteIsTafseerChecked);
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
                            AppLocalizations.of(context)!.tafseer,
                            style: TextStyle(
                                fontSize: 20.sp,
                                fontFamily:
                                    Utility.getTextFamily(currentLanguage)),
                          ),
                          Transform.scale(
                            scale: 1.w,
                            child: Checkbox(
                              value: _favoriteIsTafseerChecked,
                              onChanged: (value) {
                                setState(() {
                                  _favoriteIsTafseerChecked =
                                      !_favoriteIsTafseerChecked;
                                });
                                AppDataPreferences.setFavoritePageTafseerCheck(
                                    _favoriteIsTafseerChecked);
                                checkboxValues.updateCheckboxValues(
                                    _favoriteIsQuranChecked,
                                    _favoriteIsHadithChecked,
                                    _favoriteIsTafseerChecked);
                              },
                              activeColor: AppColor.black,
                              checkColor: AppColor.white,
                            ),
                          )
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSettingDialog(String currentLanguage) {
    var languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
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
                        fontFamily: Utility.getTextFamily(currentLanguage),
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
                          value: "en",
                          activeColor: Colors.black,
                          groupValue: _selectedLanguage,
                          onChanged: (String? value) {
                            setState(() {
                              _selectedLanguage = value!;
                            });
                            languageProvider.setCurrentLanguage('en');
                            AppDataPreferences.resetSearchPreferences();
                            Phoenix.rebirth(context);
                          },
                        ),
                        Text(
                          "English",
                          style:
                              TextStyle(fontSize: 15.sp, color: Colors.black),
                        ),
                        Radio<String>(
                          value: "ar",
                          activeColor: Colors.black,
                          groupValue: _selectedLanguage,
                          onChanged: (String? value) {
                            setState(() {
                              _selectedLanguage = value!;
                            });
                            languageProvider.setCurrentLanguage('ar');
                            AppDataPreferences.resetSearchPreferences();
                            Phoenix.rebirth(context);
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
                      onPressed: () {
                        AuthServices.signOut(context);
                      },
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
    return Consumer<MainPageProvider>(builder: (context, mainProvider, _) {
      return Stack(
        children: [
          // Background Image with Gradient Overlay
          ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.grey.withOpacity(0.1),
                  Colors.grey.withOpacity(0)
                ],
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
          // Conditional Banner Ad
          if (mainProvider.currentPageName ==
              AppLocalizations.of(context)!.home)
            Positioned(
              top: 0, // Set to top of the screen
              left: 0,
              right: 0,
              child: _bannerAd == null
                  ? const SizedBox.shrink()
                  : SizedBox(
                      width: width,
                      height: _bannerAd!.size.height.toDouble(),
                      child: AdWidget(ad: _bannerAd!),
                    ),
            ),
          // Header Content
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
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
                        mainProvider.currentPageName,
                        style: TextStyle(
                          fontFamily: Utility.getTextFamily(currentLanguage),
                          fontSize: mainProvider.currentPageName.length > 10
                              ? 30.sp
                              : 40.sp,
                          color: AppColor.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        width: width / 2,
                        child: Text(
                          _subTitleHeader(mainProvider.currentPageName),
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: Colors.grey,
                            fontFamily:
                                currentLanguage == Languages.EN.languageCode
                                    ? 'EnglishQuran'
                                    : 'Hafs',
                          ),
                        ),
                      ),
                    ],
                  ),
                  mainProvider.currentPageName !=
                          AppLocalizations.of(context)!.home
                      ? Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  isMobile == true ? 15.w : 10.w),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: AppColor.white,
                                  border: Border.all(
                                    color: AppColor.black,
                                    width: 1.w,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                      isMobile == true ? 15.w : 10.w),
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    _actionOfHeaderButton();
                                  },
                                  icon: Icon(
                                    _iconHeader(mainProvider.currentPageName),
                                    size: 35.w,
                                    color: AppColor.black,
                                  ),
                                ),
                              ),
                            ),
                            if (notificationCount > 0 &&
                                mainProvider.currentPageName ==
                                    AppLocalizations.of(context)!.home)
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
                      : Container(),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  void _actionOfHeaderButton() {
    String currentLanguage = Localizations.localeOf(context).languageCode;
    var mainProvider = Provider.of<MainPageProvider>(context, listen: false);

    if (mainProvider.currentPageName == AppLocalizations.of(context)!.search) {
      _showFilterSearchDialog(currentLanguage);
    } else if (mainProvider.currentPageName ==
        AppLocalizations.of(context)!.favorites) {
      _showFilterFavoriteDialog(currentLanguage);
    } else if (mainProvider.currentPageName ==
        AppLocalizations.of(context)!.profile) {
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
    var mainProvider = Provider.of<MainPageProvider>(context, listen: false);

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
                  fontFamily: Utility.getTextFamily(currentLanguage)),
              iconColor: AppColor.black,
              iconSize: 20.w,
              onPressed: () {
                mainProvider
                    .setCurrentPageName(AppLocalizations.of(context)!.home);
              },
            ),
            GButton(
              icon: Icons.search,
              text: AppLocalizations.of(context)!.search,
              textStyle: TextStyle(
                  fontSize: 15.sp,
                  fontFamily: Utility.getTextFamily(currentLanguage)),
              iconColor: AppColor.black,
              iconSize: 20.w,
              onPressed: () {
                mainProvider
                    .setCurrentPageName(AppLocalizations.of(context)!.search);
              },
            ),
            GButton(
              icon: Icons.favorite_border_outlined,
              text: AppLocalizations.of(context)!.favorites,
              textStyle: TextStyle(
                  fontSize: 15.sp,
                  fontFamily: Utility.getTextFamily(currentLanguage)),
              iconColor: AppColor.black,
              iconSize: 20.w,
              onPressed: () {
                mainProvider.setCurrentPageName(
                    AppLocalizations.of(context)!.favorites);
              },
            ),
            GButton(
              icon: Icons.person_outline,
              text: AppLocalizations.of(context)!.profile,
              textStyle: TextStyle(
                  fontSize: 15.sp,
                  fontFamily: Utility.getTextFamily(currentLanguage)),
              iconColor: AppColor.black,
              iconSize: 20.w,
              onPressed: () {
                mainProvider
                    .setCurrentPageName(AppLocalizations.of(context)!.profile);
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

  void _createBannerAd() {
    _bannerAd = BannerAd(
        size: AdSize.fullBanner,
        adUnitId: AdmobService.bannerAdUnitId(true),
        listener: AdmobService.bannerListener,
        request: const AdRequest())
      ..load();
  }

  void _createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: AdmobService.interstitialAdUnitId(true),
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(onAdLoaded: (ad) {
          _interstitialAd = ad;
          print('interstitial loaded');
          _showInterstitialAd();
        }, onAdFailedToLoad: (error) {
          _interstitialAd = null;
          print('interstitial failed');
        }));
  }

  void _showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
        },
      );

      _interstitialAd!.show();
      _interstitialAd = null;
    }
  }
}
