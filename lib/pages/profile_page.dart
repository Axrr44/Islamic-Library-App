import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/utilities/utility.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../services/authentication.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    String currentLanguage = Localizations.localeOf(context).languageCode;

    return FutureBuilder<Map<String, dynamic>?>(
      future: AuthServices.fetchUserInfo(),
      builder: (BuildContext context,
          AsyncSnapshot<Map<String, dynamic>?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error fetching user information'));
        } else if (!snapshot.hasData || snapshot.data == null) {
          return Center(child: Text('No user information available'));
        } else {
          final userInfo = snapshot.data!;
          return Material(
            color: Colors.white.withOpacity(0.0),
            child: Container(
              color: Colors.grey.withOpacity(0.0),
              child: Column(
                children: [
                  SizedBox(
                    height: 15.h,
                    child: Divider(color: Colors.grey),
                  ),
                  Container(
                    width: width,
                    child: Padding(
                      padding: EdgeInsets.all(5.w),
                      child: ListTile(
                        leading: Icon(Icons.person_rounded),
                        title: Text(
                          "${AppLocalizations.of(context)!.fullName} : ${userInfo['name']}",
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: Utility.getTextFamily(currentLanguage),
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15.h,
                    child: Divider(color: Colors.grey),
                  ),
                  Container(
                    width: width,
                    child: Padding(
                      padding: EdgeInsets.all(5.w),
                      child: ListTile(
                        leading: Icon(Icons.email),
                        title: Text(
                          "${AppLocalizations.of(context)!.email} : ${userInfo['email']}",
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: Utility.getTextFamily(currentLanguage),
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15.h,
                    child: Divider(color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

// Future<void> _onProfilePressed() async {
//   try {
//     final ImagePicker picker = ImagePicker();
//     final XFile? image =
//     await picker.pickImage(source: ImageSource.gallery);
//     if (image == null) return;
//     final imageBytes = await StorageService.uploadProfileImage(image);
//
//     setState(() {
//       _profileImage = imageBytes;
//     });
//     _loadProfileImage();
//   } catch (_) {}
// }
//
// Future<void> _loadProfileImage() async {
//   final imageBytes = await StorageService.getProfileImage();
//   setState(() {
//     _profileImage = imageBytes;
//   });
// }
}
