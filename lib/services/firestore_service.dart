import '../models/favorite_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FireStoreService {
  static final CollectionReference favorites = FirebaseFirestore.instance.collection('favorites');

  static Future<void> addFavorite(Favorite favorite) async {
    await favorites.add(favorite.toMap());
  }


  static Future<List<Favorite>> getFavoritesIgnoringTypes(List<String> ignoreTypes) async {
    QuerySnapshot querySnapshot = await favorites.get();
    return querySnapshot.docs.map((doc) {
      return Favorite.fromMap(doc.data() as Map<String, dynamic>);
    }).where((favorite) {
      return !ignoreTypes.contains(favorite.type);
    }).toList();
  }

}