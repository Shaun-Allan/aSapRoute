import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:route/model/user_model.dart';

class UserRepository extends GetxController {
  static User get instance => Get.find();

  final _db = FirebaseFirestore.instance;

  createUser(UserModel user) async{
    await _db.collection("Users").doc(user.id).set(user.toJson());
  }

  Future<UserModel?> getUserDetails(String uid) async{
    final DocumentSnapshot doc = await _db.collection("Users").doc(uid).get();
    if (doc.exists) {
      return UserModel(
        id: doc.id,
        Email: doc['Email'],
        Name: doc['Name'],
        Password: doc['Password'],
      );
    } else {
      return null; // User not found
    }
  }

}