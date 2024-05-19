import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/config/app_languages.dart';
import 'package:freelancer/utilities/constants.dart';
import '../config/app_colors.dart';
import '../models/tafseer_content.dart';
import '../services/app_data_pref.dart';
import '../models/hadith_model.dart';
import 'package:quran/quran.dart' as quran;
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Hadith> _hadiths = [];
  List<dynamic> _searchResults = [];
  final TextEditingController _searchController = TextEditingController();
  late bool _searchIsQuranChecked;
  late bool _searchIsHadithChecked;
  late bool _searchIsTafseerChecked;
  late int _indexOfHadith;
  late int _mufseerId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadHadiths();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadSearchDialogData();
  }

  void _loadHadiths() async {
    String jsonString = await rootBundle
        .loadString("assets/json/abudawud.json");
    setState(() {
      _hadiths = parseHadiths(jsonString);
    });
  }

  void _search(String query) async {
    if (_searchController.text.trim().isEmpty) return;

    setState(() {
      print("loading.....");
      _isLoading = true;
      _searchResults.clear();
    });

    List<String> searchTerms = query.split(' ');

    late Map arabicSearchResults;
    late Map translationSearchResults ;

    List<Map<String, String>> quranResults = [];
    List<Map<String, String>> hadithResults = [];
    List<Map<String, String>> tafseerResults = [];

    if(_searchIsQuranChecked || _searchIsTafseerChecked)
      {
       arabicSearchResults = quran.searchWords(searchTerms);
       translationSearchResults = quran.searchWordsInTranslation(searchTerms);
      }

    if (_searchIsQuranChecked) {
      quranResults = await _getQuranSearchResult(
          arabicSearchResults, translationSearchResults);
    }
    if (_searchIsHadithChecked) {
      hadithResults = await _getHadithSearchResult(query);
    }
    if (_searchIsTafseerChecked) {
      tafseerResults = await _getTafseerResult(
          arabicSearchResults, translationSearchResults);
    }

    setState(() {
      // Combine all results
      _searchResults = quranResults + hadithResults + tafseerResults;
      _isLoading = false;
      print("end loading.....");
    });
  }

  List<Hadith> parseHadiths(String? jsonString) {
    final parsed = jsonDecode(jsonString!);
    return List<Hadith>.from(parsed['hadiths'].map((x) => Hadith.fromJson(x)));
  }

  String _cleanArabic(String text) {
    const charactersToRemove = [
      '\u064B', // Tanween Fathah
      '\u064C', // Tanween Dammah
      '\u064D', // Tanween Kasrah
      '\u064E', // Fathah
      '\u064F', // Dammah
      '\u0650', // Kasrah
      '\u0651', // Shaddah
      '\u0652', // Sukun
      '\u0653', // Maddah Above
      '\u0654', // Hamza Above
      '\u0655', // Hamza Below
    ];

    // Create a regular expression pattern from the list of characters
    final pattern = charactersToRemove.join('|');
    final regExp = RegExp(pattern);

    // Replace the specified characters with an empty string
    return text.replaceAll(regExp, '');
  }

  Future<void> _loadSearchDialogData() async {
    _searchIsQuranChecked = await AppDataPreferences.getSearchPageQuranCheck();
    _searchIsHadithChecked = await AppDataPreferences.getSearchPageHadithsCheck();
    _searchIsTafseerChecked = await AppDataPreferences.getSearchPageTafseerCheck();
    _indexOfHadith = await AppDataPreferences.getSearchPageHadithId();
    _mufseerId = await AppDataPreferences.getSearchPageMufseerId(
        Localizations.localeOf(context).languageCode);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    String currentLanguage = Localizations.localeOf(context).languageCode;

    return Material(
      color: Colors.white.withOpacity(0.0),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: width / 20),
        child: Container(
          color: Colors.grey.withOpacity(0.0),
          child: Column(
            children: [
              _searchBar(currentLanguage),
              _searchResults.isNotEmpty ? _buildSearchResults() : Container(),
              // Display search results if available
            ],
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
            padding: EdgeInsets.only(right: currentLanguage == Languages.EN.languageCode ? 5.w
            : 0 ,left: currentLanguage == Languages.EN.languageCode ? 0
                : 5.w),
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
                  hintStyle: TextStyle(fontFamily: Constants.getTextFamily(currentLanguage)),
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
          onPressed: () async{
            _loadSearchDialogData();
            _search(_searchController.text);
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

  Future<List<Map<String, String>>> _getQuranSearchResult(
      Map arabicSearchResults, Map translationSearchResults) async {
    List<Map<String, String>> quranResults = [];

    if (arabicSearchResults['result'] != null) {
      for (var result in arabicSearchResults['result']) {
        quranResults.add({
          'type': 'quran',
          'surah': quran.getSurahNameArabic(result['surah']),
          'verse': quran.getVerse(result['surah'], result['verse']),
        });
      }
    }

    if (translationSearchResults['result'] != null) {
      for (var result in translationSearchResults['result']) {
        quranResults.add({
          'type': 'quran_translation',
          'surah': quran.getSurahName(result['surah']),
          'verse': quran.getVerseTranslation(result['surah'], result['verse']),
        });
      }
    }

    return quranResults;
  }

  Future<List<Map<String, String>>> _getHadithSearchResult(String query) async {
    List<Map<String, String>> hadithResults = [];

    for (var hadith in _hadiths) {
      final cleanArabic = _cleanArabic(hadith.arabic!);
      final cleanEnglish = hadith.english!.toLowerCase();
      final cleanQuery = query.toLowerCase();

      if (cleanArabic.contains(cleanQuery) ||
          cleanEnglish.contains(cleanQuery)) {
        hadithResults.add({
          'type': 'hadith',
          'arabic': hadith.arabic!,
          'english': hadith.english!,
        });
      }
    }

    return hadithResults;
  }

  Future<List<Map<String, String>>> _getTafseerResult(
      Map arabicSearchResults, Map translationSearchResults) async {
    List<Map<String, String>> tafseerResult = [];

    if (arabicSearchResults['result'] != null) {
      for (var result in arabicSearchResults['result']) {
        var tafseer = await _fetchTafseerData(result['surah'], result['verse']);
        tafseerResult.add({
          'type': 'tafseer',
          'surah': quran.getSurahNameArabic(result['surah']),
          'verse': quran.getVerse(result['surah'], result['verse']),
          'tafseer': tafseer?.text ?? 'No Tafseer available',
        });
      }
    }

    if (translationSearchResults['result'] != null) {
      for (var result in translationSearchResults['result']) {
        var tafseer = await _fetchTafseerData(result['surah'], result['verse']);
        tafseerResult.add({
          'type': 'tafseer_translation',
          'surah': quran.getSurahName(result['surah']),
          'verse': quran.getVerseTranslation(result['surah'], result['verse']),
          'tafseer': tafseer?.text ?? 'No Tafseer available',
        });
      }
    }

    return tafseerResult;
  }

  Future<TafseerResponse?> _fetchTafseerData(
      int surahId, int verseNumber) async {
    final response = await http.get(Uri.parse(
        'http://api.quran-tafseer.com/tafseer/$_mufseerId/$surahId/$verseNumber'));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return TafseerResponse.fromJson(data);
    } else {
      return null;
    }
  }

  Widget _buildSearchResults() {
    print(_searchResults);
    return Container();
  }
}
