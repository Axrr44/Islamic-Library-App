import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:islamiclibrary/config/app_colors.dart';
import 'package:islamiclibrary/config/app_routes.dart';
import 'package:islamiclibrary/providers/main_page_provider.dart';
import 'package:islamiclibrary/utilities/utility.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
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

    if (AuthServices.getCurrentUser() == null) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context)!.guestMessage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15.sp, color: Colors.grey),
            ),
            SizedBox(
              height: 10.h,
            ),
            ElevatedButton(
              onPressed: () {
                var mainPageProvider =
                    Provider.of<MainPageProvider>(context, listen: false);
                mainPageProvider
                    .setCurrentPageName(AppLocalizations.of(context)!.home);
                Navigator.of(context)
                    .pushReplacementNamed(AppRoutes.SIGN_IN_ROUTES);
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(AppColor.primary1),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.w),
                  ),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.signIn,
                style: TextStyle(fontSize: 20.sp, color: Colors.white),
              ),
            ),
          ],
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
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error fetching user information'));
        } else if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('No user information available'));
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
                          textAlign: TextAlign.center,
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
                          textAlign: TextAlign.center,
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
                  FutureBuilder<bool>(
                    future: AuthServices.isSignedInWithGoogle(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      if (snapshot.hasData && !snapshot.data!) {
                        return Column(
                          children: [
                            SizedBox(
                              width: width,
                              child: Padding(
                                padding: EdgeInsets.all(5.w),
                                child: ListTile(
                                  leading:
                                      const Icon(Icons.lock_reset_outlined),
                                  title: TextButton(
                                    onPressed: () {
                                      Navigator.pushNamed(context,
                                          AppRoutes.PASSWORD_RESET_ROUTES);
                                    },
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .changePassword,
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontFamily: Utility.getTextFamily(
                                            currentLanguage),
                                        fontSize: 15.sp,
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
                        );
                      }
                      return const SizedBox.shrink();
                    },
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
                              fontSize: 15.sp,
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
          backgroundColor: Colors.white,
          content: Padding(
            padding: EdgeInsets.only(top: 10.h),
            child: Text(
              AppLocalizations.of(context)!.confirmDeletionMessage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15.sp),
            ),
          ),
          actions: <Widget>[
            Center(
              // Center the Row
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.grey),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.w),
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      AppLocalizations.of(context)!.cancel,
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
                          MaterialStateProperty.all(AppColor.primary1),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.w),
                        ),
                      ),
                    ),
                    onPressed: () async {
                      bool isDeleted =
                          await AuthServices.deleteAccount(context);
                      if (isDeleted) {
                        Phoenix.rebirth(context);
                      }
                    },
                    child: Text(
                      AppLocalizations.of(context)!.delete,
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
