import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import 'authentication.dart';


class StorageService{

  static Future<Uint8List?> uploadProfileImage(XFile image) async {

    User? user = AuthServices.auth.currentUser;
    String uid = user!.uid;
    final storageRef = FirebaseStorage.instance.ref();
    final imageRef = storageRef.child("profile-picture/$uid/profile.jpg");
    final imageBytes = await image.readAsBytes();
    await imageRef.putData(imageBytes);

    return imageBytes;

  }
  static Future<Uint8List?> getProfileImage() async{
    try{
      User? user = AuthServices.auth.currentUser;
      String uid = user!.uid;
      final storageRef = FirebaseStorage.instance.ref();
      final imageRef = storageRef.child("profile-picture/$uid/profile.jpg");
      final imageBytes = await imageRef.getData();
      if(imageBytes == null) return null;
      return imageBytes;
    }catch(_){return null;}
  }

}