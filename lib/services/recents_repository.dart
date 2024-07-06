import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../model/recents_model.dart';

class RecentsRepository extends GetxController {
  static RecentsRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveRecentSearches(String userId, RecentsModel recents) async {
    final collectionRef = _db.collection("Recents").doc(userId).collection("User Data").doc("Recent Searches").collection("GeoPoints").doc(recents.desc);
    try {
      await collectionRef.set(<String, dynamic>{
        "geo": recents.geoFirePoint!.data,
        "name": recents.name,
        "desc": recents.desc,
      });
    } catch (e) {
      print("Error saving recent searches: $e");
      rethrow; // Rethrow the error to handle it in the calling code
    }
  }


  Future<List<RecentsModel>> getRecentlySearched(String uid) async{
    final collectionRef = _db.collection("Recents").doc(uid).collection("User Data").doc("Recent Searches").collection("GeoPoints");
    final snapshot = await collectionRef.get();
    final recentsData = snapshot.docs.map((e) => RecentsModel.fromSnapshot(e)).toList();
    return recentsData;
  }

  // Future<RecentsModel?> getRecentSearches(String userId) async {
  //   try {
  //     final DocumentSnapshot doc = await _db.collection("RecentSearches").doc(userId).get();
  //     if (doc.exists) {
  //       return RecentsModel.fromJson(doc.data()!);
  //     } else {
  //       return null; // No recent searches found
  //     }
  //   } catch (e) {
  //     print("Error fetching recent searches: $e");
  //     return null; // Return null or handle the error as needed
  //   }
  // }
}
