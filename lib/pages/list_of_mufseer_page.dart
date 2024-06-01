import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/config/app_languages.dart';
import 'package:freelancer/pages/tafseer_conent_page.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:quran/quran.dart' as quran;
import '../config/app_colors.dart';
import '../models/tafseer_books.dart';
import '../services/app_data.dart';

class ListOfMufseerPage extends StatefulWidget {
  final int surahId;

  const ListOfMufseerPage({super.key, required this.surahId});

  @override
  State<ListOfMufseerPage> createState() => _ListOfMufseerPageState();
}

class _ListOfMufseerPageState extends State<ListOfMufseerPage> {
  late Future<List<Tafseer>> _tafseerListFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    String currentLanguage = Localizations.localeOf(context).languageCode;
    _tafseerListFuture = AppData.fetchTafseerData(currentLanguage);
  }

  @override
  Widget build(BuildContext context) {
    String currentLanguage = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          currentLanguage == Languages.EN.languageCode
              ? quran.getSurahName(widget.surahId)
              : quran.getSurahNameArabic(widget.surahId),
          style: TextStyle(fontSize: 15.sp),
        ),
        centerTitle: true,
      ),
      body: _listOfTafseer(),
    );
  }

  FutureBuilder<List<Tafseer>> _listOfTafseer() {
    return FutureBuilder<List<Tafseer>>(
      future: _tafseerListFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          context.loaderOverlay.show();
          return Container();
        }
        else if (snapshot.hasError) {
          context.loaderOverlay.hide();
          return Text('Error: ${snapshot.error}');
        }
        else {
          context.loaderOverlay.hide();
          List<Tafseer>? tafseerList = snapshot.data;
          if (tafseerList != null && tafseerList.isNotEmpty) {
            return SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: MediaQuery.of(context).size.width / 2,
                    mainAxisExtent: MediaQuery.of(context).size.height / 5,
                    childAspectRatio: 1,
                    crossAxisSpacing: 5.w,
                    mainAxisSpacing: 5.h,
                  ),
                  itemCount: tafseerList.length,
                  itemBuilder: (_, index) {
                    Tafseer tafseer = tafseerList[index];
                    return Card(
                      color: AppColor.white,
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => TafseerContentPage(surahId: widget.surahId,
                            mufseer: Tafseer(id: tafseer.id,
                                name: tafseer.name,
                                language: tafseer.language,
                                author: tafseer.author,
                                bookName: tafseer.bookName),),
                          ));
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 10.h, horizontal: 10.w),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(
                                tafseer.name,
                                style: TextStyle(fontSize: 14.sp),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 15.w,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
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
}
