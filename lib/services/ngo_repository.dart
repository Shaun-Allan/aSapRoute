import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/ngo_model.dart';

class NgoRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Fetch NGO details from Firestore
  Future<List<NgoModel>> getNgoDetails() async {
    final collectionRef = _db.collection("Relief");
    final snapshot = await collectionRef.get();
    final ngos = snapshot.docs.map((doc) => NgoModel.fromSnapshot(doc)).toList();
    print("detials fetched");
    return ngos;
  }
}
