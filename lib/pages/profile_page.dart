import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../services/storage_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Uint8List? _profileImage;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Material(
      color: Colors.white.withOpacity(0.0),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: width / 20),
        child: Container(
          color: Colors.grey.withOpacity(0.0),
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.width > 600 ? 20.h : 50.h,
              ),
              _profilePicture(),
              SizedBox(
                height: 20.h,
              ),
              Text(
                "User test",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 30.sp,
                ),
              ),
              Text(
                "testEmail@gmail.com",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 15.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profilePicture() {
    return Stack(
      children: [
        InkWell(
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          hoverColor: Colors.transparent,
          onTap: _onProfilePressed,
          child: Container(
            height: 180.w,
            width: 180.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey,
              image: _profileImage != null
                  ? DecorationImage(
                image: MemoryImage(_profileImage!),
                fit: BoxFit.cover,
              )
                  : null,
            ),
            child: _profileImage == null
                ? Center(
              child: Icon(
                Icons.person_rounded,
                color: Colors.black,
                size: 100.w,
              ),
            )
                : null,
          ),
        ),
        Positioned(
          right: 5.w,
          bottom: 5.w,
          child: InkWell(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            hoverColor: Colors.transparent,
            onTap: _onProfilePressed,
            child: Container(
              height: 50.w,
              width: 50.w,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 30.w,
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  Future<void> _onProfilePressed() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image =
      await picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;
      final imageBytes = await StorageService.uploadProfileImage(image);

      setState(() {
        _profileImage = imageBytes;
      });
      _loadProfileImage();
    } catch (_) {}
  }

  Future<void> _loadProfileImage() async {
    final imageBytes = await StorageService.getProfileImage();
    setState(() {
      _profileImage = imageBytes;
    });
  }
}
