import 'package:firebase_auth/firebase_auth.dart';
import 'package:islamiclibrary/services/authentication.dart';

import '../models/favorite_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FireStoreService {

  static DocumentReference _getUserFavoritesDocument() {
    User? currentUser = AuthServices.getCurrentUser();
    if (currentUser != null) {
      print('User ID: ${currentUser.uid}'); // Debug print
      return FirebaseFirestore.instance
          .collection('favorites')
          .doc(currentUser.uid);
    } else {
      throw Exception("No user is currently signed in.");
    }
  }

  static Future<void> addFavorite(Favorite favorite) async {
    try {
      DocumentReference userFavoritesDoc = _getUserFavoritesDocument();
      await userFavoritesDoc.set({
        'favorites': FieldValue.arrayUnion([favorite.toMap()])
      }, SetOptions(merge: true));
      print('Favorite added successfully'); // Debug print
    } catch (e) {
      print('Error adding favorite: $e'); // Debug print
    }
  }

  static Future<List<Favorite>> getFavoritesIgnoringTypes(
      List<String> ignoreTypes) async {
    try {
      DocumentReference userFavoritesDoc = _getUserFavoritesDocument();
      DocumentSnapshot docSnapshot = await userFavoritesDoc.get();
      if (docSnapshot.exists) {
        List<dynamic> favoritesList = docSnapshot.get('favorites') ?? [];
        List<Favorite> favorites = favoritesList.map((item) {
          return Favorite.fromMap(item as Map<String, dynamic>);
        }).toList();
        print('Favorites fetched successfully'); // Debug print
        return favorites.where((favorite) {
          return !ignoreTypes.contains(favorite.type);
        }).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching favorites: $e'); // Debug print
      return [];
    }
  }

  static Future<void> addFeedback(String title, String description) async {
    try {
      CollectionReference feedbackCollection = FirebaseFirestore.instance.collection('feedback');
      await feedbackCollection.add({
        'title': title,
        'description': description,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('Feedback added successfully'); // Debug print
    } catch (e) {
      print('Error adding feedback: $e'); // Debug print
    }
  }

}
