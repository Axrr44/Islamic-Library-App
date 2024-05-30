import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/config/app_colors.dart';
import 'package:freelancer/config/app_routes.dart';
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

    User? currentUser = AuthServices.getCurrentUser();

    if (currentUser == null) {
      return Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).pushReplacementNamed(AppRoutes.SIGN_IN_ROUTES);
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(AppColor.primary1)
          ),
          child: Text(
            AppLocalizations.of(context)!.signIn,
            style: TextStyle(fontSize: 20.sp),
          ),
        ),
      );
    }

    return FutureBuilder<Map<String, dynamic>?>(
      future: AuthServices.fetchUserInfo(),
      builder: (BuildContext context,
          AsyncSnapshot<Map<String, dynamic>?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.black));
        }
        else if (snapshot.hasError) {
          return const Center(child: Text('Error fetching user information'));
        }
        else if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('No user information available'));
        }
        else {
          final userInfo = snapshot.data!;
          return Material(
            color: Colors.white.withOpacity(0.0),
            child: Container(
              color: Colors.grey.withOpacity(0.0),
              child: Column(
                children: [
                  SizedBox(
                    height: 15.h,
                    child: const Divider(color: Colors.grey),
                  ),
                  SizedBox(
                    width: width,
                    child: Padding(
                      padding: EdgeInsets.all(5.w),
                      child: ListTile(
                        leading: const Icon(Icons.person_rounded),
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
                    child: const Divider(color: Colors.grey),
                  ),
                  SizedBox(
                    width: width,
                    child: Padding(
                      padding: EdgeInsets.all(5.w),
                      child: ListTile(
                        leading: const Icon(Icons.email),
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
                    child: const Divider(color: Colors.grey),
                  ),
                  SizedBox(
                    width: width,
                    child: Padding(
                      padding: EdgeInsets.all(5.w),
                      child: ListTile(
                        leading: const Icon(Icons.lock_reset_outlined),
                        title: TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.PASSWORD_RESET_ROUTES);
                          },
                          child: Text(
                            AppLocalizations.of(context)!.changePassword,
                            style: TextStyle(
                              color: Colors.blue,
                              fontFamily:
                              Utility.getTextFamily(currentLanguage),
                              fontSize: 30.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15.h,
                    child: const Divider(color: Colors.grey),
                  ),
                  SizedBox(
                    width: width,
                    child: Padding(
                      padding: EdgeInsets.all(5.w),
                      child: ListTile(
                        leading: const Icon(Icons.delete),
                        title: TextButton(
                          onPressed: () {
                            _showDeleteConfirmationDialog(context);
                          },
                          child: Text(
                            AppLocalizations.of(context)!.deleteAccount,
                            style: TextStyle(
                              color: Colors.blue,
                              fontFamily:
                              Utility.getTextFamily(currentLanguage),
                              fontSize: 30.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15.h,
                    child: const Divider(color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(AppLocalizations.of(context)!.confirmDeletionMessage),
          actions: <Widget>[
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(AppColor.primary1)
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.cancel,style: TextStyle(
                fontSize: 15.sp,color: Colors.white
              ),),
            ),
            ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.grey)
              ),
              onPressed: () {
                AuthServices.deleteAccount(context);
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.delete,style: TextStyle(
                fontSize: 15.sp,color: Colors.white
              ),),
            ),
          ],
        );
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
