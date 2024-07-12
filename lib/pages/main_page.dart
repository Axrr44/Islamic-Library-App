import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:islamiclibrary/config/app_languages.dart';
import 'package:islamiclibrary/pages/favorites_page.dart';
import 'package:islamiclibrary/pages/profile_page.dart';
import 'package:islamiclibrary/pages/search_page.dart';
import 'package:islamiclibrary/providers/favorite_provider.dart';
import 'package:islamiclibrary/providers/main_page_provider.dart';
import 'package:islamiclibrary/services/admob_service.dart';
import 'package:islamiclibrary/services/authentication.dart';
import 'package:islamiclibrary/utilities/utility.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';
import '../config/app_colors.dart';
import '../models/drop_down_item.dart';
import '../models/tafseer_books.dart';
import '../providers/language_provider.dart';
import '../services/app_data.dart';
import '../services/app_data_pref.dart';
import 'home_page.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  BannerAd? _bannerAd;
  NativeAd? _nativeAd;
  bool _isAdLoaded = false;
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
  late TutorialCoachMark tutorialCoachMark;

  final quranKeyTutorial = GlobalKey();
  final hadithKeyTutorial = GlobalKey();
  final tafseerKeyTutorial = GlobalKey();
  final searchKeyTutorial = GlobalKey();
  final favoriteKeyTutorial = GlobalKey();
  final profileKeyTutorial = GlobalKey();
  late List<Widget> pages;

  @override
  void initState() {
    super.initState();
    pages = [
      HomePage(
        quranKeyTutorial: quranKeyTutorial,
        hadithKeyTutorial: hadithKeyTutorial,
        tafseerKeyTutorial: tafseerKeyTutorial,
      ),
      const SearchPage(),
      const FavoritesPage(),
      const ProfilePage(),
    ];
    _checkAndShowTutorial();
    _createBannerAd();
    _loadNativeAd();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    _isAdLoaded = false;
    super.dispose();
  }

  void _loadNativeAd() {
    _nativeAd = NativeAd(
        adUnitId: AdmobService.nativeAdUnitId(false),
        listener: NativeAdListener(onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
            print("is loaded");
          });
        }, onAdFailedToLoad: (ad, error) {
          setState(() {
            _isAdLoaded = false;
            print("failed to load");
          });
        }),
        request: const AdRequest(),
        nativeTemplateStyle:
            NativeTemplateStyle(templateType: TemplateType.medium));
    _nativeAd!.load();
  }

  Future<void> _checkAndShowTutorial() async {
    bool show = await AppDataPreferences.getShowTutorial();
    if (show) {
      createTutorial();
      Future.delayed(Duration.zero, showTutorial);
    } else {
      _createInterstitialAd();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Use Future.delayed to schedule the code to run after the build phase
    Future.delayed(Duration.zero, () {
      String currentLanguage = Localizations.localeOf(context).languageCode;
      var mainProvider = Provider.of<MainPageProvider>(context, listen: false);
      if (mainProvider.currentPageName == "Home" ||
          mainProvider.currentPageName == "الرئيسية") {
        mainProvider.setCurrentPageName(AppLocalizations.of(context)!.home);
      } else if (mainProvider.currentPageName ==
          AppLocalizations.of(context)!.search) {
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

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        final result = await _closeAppDialog(context);
        if (result == true) {
          SystemNavigator.pop();
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        body: Column(
          children: [
            _header(width, height, notificationCount, isMobile),
            if (_currentPage == 0)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                        onPressed: () {
                          createTutorial();
                          Future.delayed(Duration.zero, showTutorial);
                        },
                        icon: Icon(
                          Icons.info,
                          size: 20.w,
                        ))
                  ],
                ),
              ),
            Expanded(
              child: pages[_currentPage],
            ),
          ],
        ),
        bottomNavigationBar: _bottomNavigation(),
      ),
    );
  }

  void showTutorial() {
    tutorialCoachMark.show(context: context);
  }

  void createTutorial() {
    tutorialCoachMark = TutorialCoachMark(
      targets: _createTargets(),
      colorShadow: AppColor.black,
      onFinish: () {
        AppDataPreferences.setShowTutorial(false);
      },
      onSkip: () {
        AppDataPreferences.setShowTutorial(false);
        return true;
      },
      textSkip: AppLocalizations.of(context)!.skip,
      paddingFocus: 2.w,
      opacityShadow: 0.5,
      imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
    );
  }

  List<TargetFocus> _createTargets() {
    List<TargetFocus> targets = [];
    targets.add(
      TargetFocus(
        identify: "quran",
        keyTarget: quranKeyTutorial,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            padding: EdgeInsets.symmetric(vertical: 150.h),
            builder: (context, controller) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    textAlign: TextAlign.center,
                    AppLocalizations.of(context)!.quranTutorial,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "hadith",
        keyTarget: hadithKeyTutorial,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    AppLocalizations.of(context)!.hadithTutorial,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "tafseer",
        keyTarget: tafseerKeyTutorial,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    AppLocalizations.of(context)!.tafseerTutorial,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 100.h)
                ],
              );
            },
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "search",
        keyTarget: searchKeyTutorial,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    AppLocalizations.of(context)!.searchTutorial,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "favorite",
        keyTarget: favoriteKeyTutorial,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    AppLocalizations.of(context)!.favoriteTutorial,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "profile",
        keyTarget: profileKeyTutorial,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    AppLocalizations.of(context)!.profileTutorial,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );

    return targets;
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
          return const Center(child: Text('Error: No internet connection'));
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
                              _selectedFilterSearch = value!;
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
                              _selectedFilterSearch = value!;
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
                          items: List.generate(14, (index) {
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
                              _selectedFilterSearch = value!;
                            });
                          },
                          activeColor: AppColor.black,
                        ),
                      ],
                    ),
                    _listOfTafseer(),
                    SizedBox(
                      width: 200.w,
                      child: ElevatedButton(
                        onPressed: () {
                          AppDataPreferences.setFilterSearch(
                              _selectedFilterSearch);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.w),
                            ),
                            backgroundColor: Colors.black),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          child: Text(
                            AppLocalizations.of(context)!.set,
                            style:
                                TextStyle(fontSize: 20.sp, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      },
    ).then((_) => {_loadSearchDialogData()});
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
                height: AuthServices.getCurrentUser() != null ? 250.w : 100.w,
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
                    if (AuthServices.getCurrentUser() != null) ...[
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
                              WidgetStateProperty.all(AppColor.black),
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.w),
                            ),
                          ),
                          minimumSize:
                              WidgetStateProperty.all(Size(200.w, 50.h)),
                        ),
                        child: Text(
                          "Sign out",
                          style:
                              TextStyle(fontSize: 20.sp, color: AppColor.white),
                        ),
                      ),
                    ]
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
          if (mainProvider.currentPageName ==
                  AppLocalizations.of(context)!.home ||
              mainProvider.currentPageName ==
                  AppLocalizations.of(context)!.profile)
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
                          fontFamily: 'ATF',
                          fontSize: mainProvider.currentPageName.length > 10
                              ? 40.sp
                              : 50.sp,
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
                            fontWeight: FontWeight.bold,
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
                      ? ClipRRect(
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
                              icon: mainProvider.currentPageName !=
                                      AppLocalizations.of(context)!.search
                                  ? Icon(
                                      _iconHeader(mainProvider.currentPageName),
                                      size: 35.w,
                                      color: AppColor.black,
                                    )
                                  : SizedBox(
                                      width: 35.w,
                                      height: 35.w,
                                      child: Image.asset(
                                          "assets/images/filter.png"),
                                    ),
                            ),
                          ),
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
                  fontWeight: FontWeight.bold,
                  fontSize: 15.sp,
                  fontFamily: 'ATF'),
              iconColor: AppColor.black,
              iconSize: 20.w,
              onPressed: () {
                mainProvider
                    .setCurrentPageName(AppLocalizations.of(context)!.home);
              },
            ),
            GButton(
              key: searchKeyTutorial,
              icon: Icons.search,
              text: AppLocalizations.of(context)!.search,
              textStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15.sp,
                  fontFamily: 'ATF'),
              iconColor: AppColor.black,
              iconSize: 20.w,
              onPressed: () {
                mainProvider
                    .setCurrentPageName(AppLocalizations.of(context)!.search);
              },
            ),
            GButton(
              key: favoriteKeyTutorial,
              icon: Icons.favorite_border_outlined,
              text: AppLocalizations.of(context)!.favorites,
              textStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15.sp,
                  fontFamily: 'ATF'),
              iconColor: AppColor.black,
              iconSize: 20.w,
              onPressed: () {
                mainProvider.setCurrentPageName(
                    AppLocalizations.of(context)!.favorites);
              },
            ),
            GButton(
              key: profileKeyTutorial,
              icon: Icons.person_outline,
              text: AppLocalizations.of(context)!.profile,
              textStyle: TextStyle(
                  fontSize: 15.sp,
                  fontFamily: 'ATF',
                  fontWeight: FontWeight.bold),
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
        adUnitId: AdmobService.bannerAdUnitId(false),
        listener: AdmobService.bannerListener,
        request: const AdRequest())
      ..load();
  }

  void _createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: AdmobService.interstitialAdUnitId(false),
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

  Future<bool?> _closeAppDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isAdLoaded)
                    Container(
                      height: 150.h,
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: AdWidget(ad: _nativeAd!),
                    ),
                  Padding(
                    padding: EdgeInsets.only(top: 15.h),
                    child: Text(
                      AppLocalizations.of(context)!.exitDialog,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15.sp),
                    ),
                  ),
                ],
              );
            },
          ),
          actions: <Widget>[
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(Colors.grey),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.w),
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: Text(
                      'No',
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.all(AppColor.primary1),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.w),
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: Text(
                      'Yes',
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
