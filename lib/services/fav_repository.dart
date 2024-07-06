import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:route/model/fav_model.dart';
import '../model/recents_model.dart';

class FavoritesRepository extends GetxController {
  static FavoritesRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveFavorite(String userId, FavoriteModel favorite) async {
    final collectionRef = _db.collection("Recents").doc(userId).collection("User Data").doc("Favorites").collection("GeoPoints").doc(favorite.desc);
    try {
      await collectionRef.set(<String, dynamic>{
        "geo": favorite.geoFirePoint!.data,
        "locName": favorite.locName,
        "desc": favorite.desc,
        "title": favorite.title,
      });
    } catch (e) {
      print("Error saving recent searches: $e");
      rethrow; // Rethrow the error to handle it in the calling code
    }
  }


  Future<List<FavoriteModel>> getFavorites(String uid) async{
    final collectionRef = _db.collection("Recents").doc(uid).collection("User Data").doc("Favorites").collection("GeoPoints");
    final snapshot = await collectionRef.get();
    final favData = snapshot.docs.map((e) => FavoriteModel.fromSnapshot(e)).toList();
    return favData;
  }
}
